import Foundation
import Observation

/// Differentiation game: Mia, Leo and Zoe each say a sound; the child taps the one
/// who sounded different. Used by every "Which One Sounds Different" exercise.
///
/// One round:
///   start → each friend speaks in turn → choose
///   wrong pick → "Almost! Try another friend!" → choose again (or replay)
///   right pick → "That's right!" → "Great listening!" → next round
/// After the last round the score is saved and the shared completion screen opens.
@Observable
@MainActor
final class OddOneOutViewModel {
    enum Phase: Equatable {
        case start
        case speaking(friend: Int, replay: Bool)
        case choosing
        case wrong(friendId: String)
        case correct
        case celebrate
    }

    /// Everything one friend card needs, already worked out for the View.
    struct Card: Identifiable {
        enum Highlight { case none, speaking, correct, wrong }
        let id: String
        let name: String
        let avatar: String
        let status: String
        let highlight: Highlight
        let canTap: Bool
    }

    private(set) var phase: Phase = .start
    private(set) var roundIndex = 0

    private let exerciseId: String
    private let items: [ExerciseItem]
    private let voice: any SpeechSynthesisService
    private let progress: any ProgressRepository
    private let router: AppRouter

    /// Rounds the child got right on the first try.
    private var firstTryCorrect = 0
    private var missedThisRound = false
    /// Goes up on every Start/Replay, so a sound sequence that was stopped can't move the screen on.
    private var playbackId = 0

    init(
        exerciseId: String,
        content: any ContentRepository,
        voice: any SpeechSynthesisService,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.exerciseId = exerciseId
        self.items = content.exercise(id: exerciseId)?.items ?? []
        self.voice = voice
        self.progress = progress
        self.router = router
    }

    // MARK: - Title card

    /// "word" when the friends say real words (Odd Sound Out), otherwise "sound".
    private var unit: String {
        OddOneOutSounds.saysWords(exerciseId: exerciseId) ? "word" : "sound"
    }

    var title: String {
        switch phase {
        case .start, .choosing:
            return unit == "word" ? "Who said a different word?" : "Who sounded different?"
        case .speaking(_, let replay): return replay ? "Listen again" : "Listen carefully"
        case .wrong: return "Almost!"
        case .correct: return "That’s right!"
        case .celebrate: return "Great listening!"
        }
    }

    var subtitle: String {
        switch phase {
        case .start: return "Three friends will each say a \(unit). Listen carefully!"
        case .speaking(let friend, _): return "Friend \(friend + 1) is saying a \(unit)"
        case .choosing: return "Tap the friend who was different."
        case .wrong: return "Try another friend!"
        case .correct: return unit == "word" ? "\(oddName) said a different word." : "\(oddName) sounded different."
        case .celebrate: return "\(oddName) said a different \(unit)."
        }
    }

    // MARK: - Friend cards

    var cards: [Card] {
        friends.enumerated().map { index, option in
            let id = option.id
            let highlight: Card.Highlight
            let status: String
            switch phase {
            case .start:
                highlight = .none; status = "Waiting"
            case .speaking(let friend, _):
                highlight = friend == index ? .speaking : .none
                status = friend == index ? "Speaking" : "Waiting"
            case .choosing:
                highlight = .none; status = "Tap to choose"
            case .wrong(let picked):
                highlight = picked == id ? .wrong : .none
                status = "Tap to choose"
            case .correct, .celebrate:
                highlight = id == oddId ? .correct : .none
                status = id == oddId ? "Correct!" : "Tap to choose"
            }
            return Card(
                id: id,
                name: option.label,
                avatar: "img_avatar_\(id)",
                status: status,
                highlight: highlight,
                canTap: canChoose && !(phase == .wrong(friendId: id))
            )
        }
    }

    /// The friend shown big on the "Great listening!" screen.
    var oddAvatar: String { "img_avatar_\(oddId)" }

    var showsCelebration: Bool { phase == .celebrate }
    var showsBackButton: Bool { phase != .celebrate }

    // MARK: - Bottom button

    enum BottomButton { case start, replay, replaying, next }

    /// "Replay words" or "Replay sounds".
    var replayTitle: String { "Replay \(unit)s" }

    var bottomButton: BottomButton? {
        switch phase {
        case .start: return .start
        case .speaking(_, let replay): return replay ? .replaying : nil
        case .choosing, .wrong: return .replay
        case .correct: return nil          // the celebration follows by itself
        case .celebrate: return .next
        }
    }

    // MARK: - Actions

    func startTapped() { playSequence(replay: false) }

    func replayTapped() { playSequence(replay: true) }

    func cardTapped(_ friendId: String) {
        guard canChoose, phase != .wrong(friendId: friendId) else { return }
        if friendId == oddId {
            if !missedThisRound { firstTryCorrect += 1 }
            phase = .correct
            showCelebrationSoon()
        } else {
            missedThisRound = true
            phase = .wrong(friendId: friendId)
        }
    }

    func continueTapped() {
        switch phase {
        case .correct:
            phase = .celebrate
        case .celebrate:
            if roundIndex >= items.count - 1 {
                let outcome = progress.finish(exerciseId: exerciseId, correct: firstTryCorrect, total: items.count)
                router.go(.completion(exerciseId: exerciseId, outcome: outcome))
            } else {
                roundIndex += 1
                missedThisRound = false
                phase = .start
            }
        default:
            break
        }
    }

    func backTapped() {
        stopAll()
        router.presentLeavePractice()
    }

    func stopAll() {
        playbackId += 1
        voice.stop()
        if case .speaking(_, let replay) = phase {
            phase = replay ? .choosing : .start
        }
    }

    // MARK: - Private

    private var currentItem: ExerciseItem? {
        items.indices.contains(roundIndex) ? items[roundIndex] : nil
    }

    private var friends: [Option] { currentItem?.options ?? [] }
    private var oddId: String { currentItem?.correctOptionId ?? "" }
    private var oddName: String { friends.first { $0.id == oddId }?.label ?? "" }

    private var canChoose: Bool {
        switch phase {
        case .choosing, .wrong: return true
        default: return false
        }
    }

    /// After a right answer, show the green card for a moment, then the celebration.
    /// Uses the playback id so a late timer can't fire after leaving or moving on.
    private func showCelebrationSoon() {
        playbackId += 1
        let id = playbackId
        Task {
            try? await Task.sleep(for: .seconds(1))
            guard id == playbackId, phase == .correct else { return }
            phase = .celebrate
        }
    }

    /// Each friend says their sound in turn, with a short pause between them.
    private func playSequence(replay: Bool) {
        playbackId += 1
        let id = playbackId
        let friends = friends
        Task {
            for index in friends.indices {
                guard id == playbackId else { return }
                phase = .speaking(friend: index, replay: replay)
                let sound = OddOneOutSounds.sound(
                    exerciseId: exerciseId,
                    roundIndex: roundIndex,
                    isOdd: friends[index].id == oddId
                )
                if let ipa = sound.ipa {
                    await voice.speakSound(sound.text, ipa: ipa)
                } else {
                    await voice.speak(sound.text, slowly: sound.slowly)
                }
                try? await Task.sleep(for: .milliseconds(500))
            }
            guard id == playbackId else { return }
            phase = .choosing
        }
    }
}
