import SwiftUI

/// Vowel sounds practice: meet a sound friend, say its sound 3 times to bring it home.
/// Figma: speech_temp › 14 · Speech — Sounds flow v2.
///
/// Artwork comes from Assets.xcassets; the path's goal falls back to a native drawing
/// (`GoalArt`) until its picture is added.
struct VowelPracticeView: View {
    @State private var vm: VowelPracticeViewModel

    init(vm: VowelPracticeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            positionLabel
            header
                .padding(.top, EchoSpacing.s)
            artwork
                .frame(maxHeight: .infinity)
            controls
                // Same height as the mic button in every state, so swapping buttons never
                // moves the artwork above.
                // Bottom-aligned, so its buttons line up with every other screen's.
                .frame(minHeight: 84, alignment: .bottom)
                .padding(.bottom, EchoSpacing.bottomAction)
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .echoExerciseBackground()
        .exerciseChrome(onBack: vm.didTapBack)
        .animation(.easeInOut(duration: 0.25), value: vm.phase)
        .onDisappear(perform: vm.onDisappear)
    }

    // MARK: - Top

    @ViewBuilder
    private var positionLabel: some View {
        let showsPosition = ![.intro, .finished].contains(vm.phase)
        Text(vm.positionText)
            .echoFont(.supporting)
            .foregroundStyle(EchoColor.speakingBody)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(showsPosition ? 1 : 0)
            .accessibilityHidden(!showsPosition)
    }

    /// Title and subtitle. A hidden two-line copy reserves the same height in every state,
    /// so a one-line subtitle ("Say “aaa” again!") doesn't pull the path up.
    private var header: some View {
        ZStack(alignment: .top) {
            SpeakingHeader(title: "Title", subtitle: "Line one\nLine two")
                .hidden()
                .accessibilityHidden(true)
            SpeakingHeader(title: vm.title, subtitle: vm.subtitle)
        }
    }

    // MARK: - Middle

    @ViewBuilder
    private var artwork: some View {
        switch vm.phase {
        case .intro:
            VStack(spacing: EchoSpacing.m) {
                ForEach(vm.introSteps) { step in
                    VowelIntroRow(step: step)
                }
            }
            .padding(.top, EchoSpacing.xl)
            .frame(maxHeight: .infinity, alignment: .top)

        case .meet, .playing, .micDenied:
            VStack(spacing: EchoSpacing.l) {
                EchoAssetImage(name: vm.friend.meetImage)
                    .frame(width: 260, height: 240)
                VowelPill(vowel: vm.friend.vowel)
            }

        case .ready, .listening, .tryAgain:
            pathWithCounter

        case .reachedGoal:
            if let image = vm.friend.celebrateImage {
                VStack(spacing: EchoSpacing.l) {
                    EchoAssetImage(name: image)
                        .frame(width: 260, height: 240)
                    SayItCounter(count: vm.goodTries, total: VowelPracticeViewModel.triesPerFriend)
                }
            } else {
                pathWithCounter
            }

        case .finished:
            VStack(spacing: EchoSpacing.xl) {
                EchoAssetImage(name: "img_vowel_leo_celebrate")
                    .frame(width: 300, height: 260)
                HStack(spacing: EchoSpacing.l) {
                    ForEach(vm.friends) { friend in
                        FriendSticker(image: friend.travelImage)
                    }
                }
            }
        }
    }

    private var pathWithCounter: some View {
        VStack(spacing: EchoSpacing.xl) {
            SoundPathView(stops: vm.stops, progress: vm.pathProgress,
                          travelImage: vm.friend.travelImage, goalImage: vm.friend.goalImage)
                .frame(height: 220)
            // After a try that didn't count, "Listen again" sits above the stars (Figma).
            // Its space is always kept, so the path and stars never shift when it appears.
            let showsReplay = vm.phase == .tryAgain
            SpeakingReplayButton(label: "Listen again", action: vm.didTapListenAgain)
                .opacity(showsReplay ? 1 : 0)
                .disabled(!showsReplay)
                .accessibilityHidden(!showsReplay)
            SayItCounter(count: vm.goodTries, total: VowelPracticeViewModel.triesPerFriend)
        }
    }

    // MARK: - Bottom

    @ViewBuilder
    private var controls: some View {
        switch vm.phase {
        case .intro:
            Button("Let’s start", action: vm.didTapStart)
                .buttonStyle(.echoPrimary)
        case .meet:
            SpeakingControlButton(control: .play, action: vm.didTapPlay)
        case .playing:
            SpeakingControlButton(control: .pause, action: vm.didTapPause)
        case .ready, .listening:
            VowelMicButton(isActive: vm.isMicActive, action: vm.didTapMicrophone)
        case .tryAgain:
            VowelMicButton(isActive: false, action: vm.didTapMicrophone)
        case .reachedGoal:
            Button(vm.nextButtonTitle, action: vm.didTapNext)
                .buttonStyle(.echoPrimary)
        case .micDenied:
            Button("Try again", action: vm.didTapMicrophone)
                .buttonStyle(.echoPrimary)
        case .finished:
            Button("Done", action: vm.didTapDone)
                .buttonStyle(.echoPrimary)
        }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        VowelPracticeView(vm: container.makeVowelPracticeViewModel(exerciseId: "sounds.vowel"))
    }
    .environment(container)
    .environment(container.router)
}
