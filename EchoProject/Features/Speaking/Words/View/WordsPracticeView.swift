import SwiftUI
import UIKit    // UIApplication.openSettingsURLString

/// Words practice with real speech checking. Figma: PRECODING › 12 · Speech — Words.
/// Draws one layout per `WordsPracticePhase`; all decisions live in WordsPracticeViewModel.
struct WordsPracticeView: View {
    @State private var vm: WordsPracticeViewModel
    @Environment(\.openURL) private var openURL

    init(vm: WordsPracticeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        practiceView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .echoExerciseBackground()
            .exerciseChrome(showsBack: !isFinished, onBack: vm.didTapBack)
            .task { await vm.onAppear() }
            .onDisappear { vm.stopAll() }
    }

    private var isFinished: Bool {
        if case .finished = vm.phase { return true }
        return false
    }

    // MARK: - Practice

    private var practiceView: some View {
        VStack(spacing: EchoSpacing.l) {
            Text(vm.positionText)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.speakingBody)
                .frame(maxWidth: .infinity, alignment: .trailing)

            SpeakingHeader(title: vm.word, subtitle: vm.instruction)
            SpeakingAvatar(imageName: "img_mia_calling", size: 200)
            middle
            Spacer(minLength: 0)
            bottomButtons
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .padding(.bottom, EchoSpacing.bottomAction)
    }

    /// The control under the character, which changes with each step.
    @ViewBuilder
    private var middle: some View {
        switch vm.phase {
        case .preparing, .checking:
            ProgressView()
                .controlSize(.large)
        case .listen:
            SpeakingControlButton(control: .play, label: "Play", action: vm.didTapPlay)
        case .playing:
            SpeakingControlButton(control: .pause, action: vm.didTapPause)
        case .listened:
            SpeakingReplayButton(label: "Listen Again", action: vm.didTapPlay)
        case .readyToRecord, .noVoice, .recordingFailed:
            SpeakingControlButton(control: .microphone, action: vm.didTapMicrophone)
        case .notUnderstood:
            RecordingReplayRow(duration: vm.recordingDuration, isPlaying: vm.isPlayingRecording,
                               action: vm.didTapPlayRecording)
        case .recording:
            SpeakingControlButton(control: .stop, action: vm.didTapStop)
            RecordingWaveform()
        case .result(.correct):
            RecordingReplayRow(duration: vm.recordingDuration, isPlaying: vm.isPlayingRecording,
                               action: vm.didTapPlayRecording)
            heardLabel
        case .result:
            SpeakingReplayButton(label: "Retry", action: vm.didTapTryAgain)
            heardLabel
        case .help, .guidedHelp:
            SoundChipsCard(chips: vm.soundChips, hint: vm.hint,
                           highlightedIndex: vm.highlightedSoundIndex, onTapChip: vm.didTapSound)
        case .micDenied, .unavailable, .finished:
            EmptyView()
        }
    }

    @ViewBuilder
    private var heardLabel: some View {
        if let heard = vm.heardDescription {
            Text(heard)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.speakingBody)
        }
    }

    // MARK: - Bottom buttons

    @ViewBuilder
    private var bottomButtons: some View {
        VStack(spacing: EchoSpacing.buttonStack) {
            switch vm.phase {
            case .listened:
                Button("Record", action: vm.didTapRecord)
                    .buttonStyle(.echoPrimary)
            case .result(.correct):
                Button(vm.isLastItem ? "Finish" : "Next word", action: vm.didTapNext)
                    .buttonStyle(.echoPrimary)
                Button("Hear pronunciation", action: vm.didTapHearPronunciation)
                    .buttonStyle(.speakingSecondary)
            case .result:
                Button("Continue", action: vm.didTapNext)
                    .buttonStyle(.echoPrimary)
                Button("Hear pronunciation", action: vm.didTapHearPronunciation)
                    .buttonStyle(.speakingSecondary)
            case .help, .guidedHelp, .noVoice, .notUnderstood, .recordingFailed:
                Button("Try again", action: vm.didTapTryAgain)
                    .buttonStyle(.echoPrimary)
            case .micDenied:
                Button("Try microphone again", action: vm.didTapMicrophone)
                    .buttonStyle(.echoPrimary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                .buttonStyle(.speakingSecondary)
            case .unavailable:
                Button("Go back", action: vm.didTapGoBack)
                    .buttonStyle(.echoPrimary)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 40)
    }
}

#Preview("Words") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        WordsPracticeView(vm: container.makeWordsPracticeViewModel(exerciseId: "words.two-syllable"))
    }
    .environment(container)
    .environment(container.router)
}
