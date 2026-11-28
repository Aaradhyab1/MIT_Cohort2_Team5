import SwiftUI
import UIKit    // UIApplication.openSettingsURLString

/// Sentences practice: read aloud while each word lights up, tap a word to hear it.
/// Figma: Precoding_FINAL › 13 · Speech — Paragraphs.
/// Layout only; every decision lives in SentencesPracticeViewModel.
struct SentencesPracticeView: View {
    @State private var vm: SentencesPracticeViewModel
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    init(vm: SentencesPracticeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        Group {
            if let result = vm.result {
                SentencesCompletionView(
                    result: result,
                    continueTitle: vm.continueTitle,
                    onTryAgain: vm.didTapTryAgain,
                    onContinue: vm.didTapContinue
                )
            } else {
                practice
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .echoExerciseBackground()
        .exerciseChrome(showsBack: vm.result == nil, onBack: vm.didTapBack)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: vm.readCount)
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: vm.phase)
        .sheet(item: $vm.selectedWord, onDismiss: vm.didCloseSheet) { word in
            PronunciationSheet(
                word: word,
                isPlaying: vm.isSayingWord,
                onHear: vm.didTapHearPronunciation,
                onClose: vm.didCloseSheet
            )
        }
        .onDisappear { vm.stopAll() }
        // Leaving the app stops the microphone; reading carries on from the current word.
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background { vm.pause() }
        }
    }

    // MARK: - Reading

    private var practice: some View {
        VStack(spacing: 0) {
            if let position = vm.positionText {
                Text(position)
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.speakingBody)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, EchoSpacing.screenHorizontal)
            }

            ScrollView {
                VStack(spacing: 20) {
                    passage
                    controls
                }
                .padding(.horizontal, EchoSpacing.screenHorizontal + 4)
                .padding(.top, 20)
                .padding(.bottom, EchoSpacing.xl)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom) { bottomButtons }
    }

    // MARK: - Leo and the passage (Figma "Reading content")

    private var passage: some View {
        ReadingPassageCard(words: vm.words, highlight: vm.highlight(for:), onTapWord: vm.didTapWord)
            .padding(.top, 84)
            .overlay(alignment: .topLeading) {
                // Leo sits on the card's top edge, like the mascot in Figma.
                Image("img_leo_speaking_3d")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 104)
                    // A soft contact shadow so Leo sits on the card instead of floating.
                    .shadow(color: Color(hex: 0x0D2E1A, opacity: 0.18), radius: 4, y: 3)
                    .padding(.leading, 8)
                    .accessibilityHidden(true)
            }
    }

    // MARK: - Microphone and status (Figma "Reading controls")

    private var controls: some View {
        VStack(spacing: 12) {
            if vm.showsMicrophone {
                // Recording: red pause (square) button. Paused or idle: blue microphone.
                SpeakingControlButton(control: vm.isReading ? .stop : .microphone, action: vm.didTapMicrophone)
                    .accessibilityLabel(vm.isReading ? "Pause reading" : "Read aloud")
                    .contentTransition(.symbolEffect(.replace))
            }
            if let status = vm.status {
                HStack(spacing: EchoSpacing.s) {
                    if vm.isReading {
                        // A live "recording" dot, so reading looks different from paused.
                        Circle()
                            .fill(EchoColor.speakingStop)
                            .frame(width: 10, height: 10)
                            .phaseAnimator([1.0, 0.35]) { dot, opacity in
                                dot.opacity(reduceMotion ? 1 : opacity)
                            } animation: { _ in .easeInOut(duration: 0.7) }
                            .accessibilityHidden(true)
                    }
                    Text(status)
                        .echoFont(.body, .semibold)
                        .foregroundStyle(vm.isReading ? Color.black : EchoColor.speakingBody)
                        .multilineTextAlignment(.center)
                        .contentTransition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Bottom buttons

    @ViewBuilder
    private var bottomButtons: some View {
        VStack(spacing: EchoSpacing.buttonStack) {
            switch vm.phase {
            case .micDenied:
                Button("Try microphone again", action: vm.startReading)
                    .buttonStyle(.echoPrimary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                .buttonStyle(.speakingSecondary)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, EchoSpacing.bottomAction)
    }
}

/// Whole Sentences flow in the canvas with the pretend reader, which reads one word
/// every half second. Run the app to use the real microphone.
private struct SentencesFlowPreview: View {
    @State private var container = AppContainer.dummy(startPastOnboarding: true)

    var body: some View {
        @Bindable var router = container.router
        NavigationStack(path: $router.speakingPath) {
            RouteDestinationView(route: .exercise(exerciseId: "sentences.paragraphs"))
                .navigationDestination(for: Route.self) { route in
                    RouteDestinationView(route: route)
                }
        }
        .environment(container)
        .environment(container.router)
    }
}

#Preview("Sentences · full flow") {
    SentencesFlowPreview()
}
