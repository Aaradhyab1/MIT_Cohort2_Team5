import SwiftUI

// Building blocks for the Speaking practice screens: Words uses them now, and Sounds,
// Sentences and Conversation should reuse them. Measurements come from the "Speech —"
// sections on the PRECODING page in Figma.

extension EchoColor {
    /// Instruction text under the screen titles.
    static let speakingBody = Color(hex: 0x2B3B54)
    /// Red stop-recording button.
    static let speakingStop = Color(hex: 0xF23B3B)
}

// MARK: - Header

/// Large centred title with one line of instructions, e.g. "Sun" / "Tap play to hear the word."
struct SpeakingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: EchoSpacing.s) {
            Text(title)
                .echoFont(.title, .bold)
                .foregroundStyle(EchoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .echoFont(.body)
                .foregroundStyle(EchoColor.speakingBody)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Round controls

/// The big round button in the middle of a practice screen.
enum SpeakingControl {
    case play, pause, microphone, stop

    var systemImage: String {
        switch self {
        case .play: "play.fill"
        case .pause: "pause.fill"
        case .microphone: "mic.fill"
        case .stop: "stop.fill"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .play: "Play"
        case .pause: "Pause"
        case .microphone: "Start recording"
        case .stop: "Stop recording"
        }
    }
}

/// 80 pt round button with an optional label underneath ("Play").
/// Blue, except the stop button, which is red.
struct SpeakingControlButton: View {
    let control: SpeakingControl
    var label: String? = nil
    let action: () -> Void

    var body: some View {
        VStack(spacing: EchoSpacing.s) {
            Button(action: action) {
                Image(systemName: control.systemImage)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(EchoColor.textOnAccent)
                    .frame(width: 80, height: 80)
                    .background(control == .stop ? EchoColor.speakingStop : EchoColor.accentFill, in: Circle())
                    .echoShadow(.primaryButton)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(control.accessibilityLabel)

            if let label {
                Text(label)
                    .echoFont(.body, .semibold)
                    .foregroundStyle(EchoColor.speakingBody)
            }
        }
    }
}

/// Small glass circle with a curved arrow: "Listen Again" or "Retry".
struct SpeakingReplayButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: EchoSpacing.s) {
            Button(action: action) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(EchoColor.textPrimary)
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
            .accessibilityLabel(label)

            Text(label)
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.speakingBody)
        }
    }
}

// MARK: - Recording feedback

/// Moving waveform shown while the microphone is recording.
struct RecordingWaveform: View {
    var body: some View {
        Image(systemName: "waveform")
            .font(.system(size: 40, weight: .medium))
            .foregroundStyle(EchoColor.accent)
            .symbolEffect(.variableColor.iterative, options: .repeating)
            .accessibilityLabel("Recording")
    }
}

/// White pill to replay the child's own recording: ▶︎ ∿∿∿ 0:03.
struct RecordingReplayRow: View {
    let duration: String
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: EchoSpacing.m) {
                Image(systemName: isPlaying ? "speaker.wave.2.fill" : "play.fill")
                    .foregroundStyle(EchoColor.accent)
                Image(systemName: "waveform")
                    .font(.system(size: 28))
                    .foregroundStyle(EchoColor.accent.opacity(0.7))
                    .frame(maxWidth: .infinity)
                Text(duration)
                    .echoFont(.caption)
                    .foregroundStyle(EchoColor.textSecondary)
            }
            .padding(.horizontal, EchoSpacing.l)
            .frame(height: 56)
            .background(.white, in: Capsule())
            .echoShadow(.card)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Play your recording")
    }
}

/// Round character portrait in the middle of a practice screen.
struct SpeakingAvatar: View {
    let imageName: String
    var size: CGFloat = 200

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(.circle)                                     // the square art is cut into a circle
            .overlay(Circle().stroke(.white, lineWidth: size * 0.03))   // white ring, as in Figma
            .accessibilityHidden(true)
    }
}

// MARK: - Buttons and navigation

/// Secondary action under the main button, e.g. "Hear pronunciation":
/// a full-width Liquid Glass capsule.
///
///     Button("Hear pronunciation", action: vm.didTapHearPronunciation)
///         .buttonStyle(.speakingSecondary)
struct SpeakingSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .echoFont(.body, .semibold)
            .foregroundStyle(EchoColor.textPrimary)
            .frame(maxWidth: EchoSize.buttonWidth, minHeight: EchoSize.buttonHeight)
            .contentShape(Capsule())
            .glassEffect(.regular.interactive(), in: .capsule)
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

extension ButtonStyle where Self == SpeakingSecondaryButtonStyle {
    static var speakingSecondary: SpeakingSecondaryButtonStyle { .init() }
}
