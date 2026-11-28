import SwiftUI

/// Style for the main call to action on a screen, such as "Start" or "Continue".
///
/// Blue capsule with a soft glow, `EchoSize.buttonWidth` wide (narrower if its container
/// is) and 56 pt tall, the same on every screen. Dims when disabled and shrinks slightly
/// while pressed.
///
///     Button("Start", action: viewModel.start)
///         .buttonStyle(.echoPrimary)
struct EchoPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .echoFont(.body, .semibold)
            .foregroundStyle(EchoColor.textOnAccent)
            .frame(maxWidth: EchoSize.buttonWidth, minHeight: EchoSize.buttonHeight)
            .background(EchoColor.accentFill, in: Capsule())
            .echoShadow(isEnabled ? .primaryButton : .none)
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == EchoPrimaryButtonStyle {
    /// See `EchoPrimaryButtonStyle`.
    static var echoPrimary: EchoPrimaryButtonStyle { .init() }
}

/// Blue Liquid Glass capsule for the main action on exercise and result screens.
/// Same size as `echoPrimary` (`EchoSize.buttonWidth` × `EchoSize.buttonHeight`).
struct EchoGlassProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .echoFont(.body, .semibold)
            .foregroundStyle(EchoColor.textOnAccent)
            .frame(maxWidth: EchoSize.buttonWidth, minHeight: EchoSize.buttonHeight)
            .contentShape(Capsule())
            .glassEffect(.regular.tint(EchoColor.accent).interactive(), in: .capsule)
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == EchoGlassProminentButtonStyle {
    /// See `EchoGlassProminentButtonStyle`.
    static var echoGlassProminent: EchoGlassProminentButtonStyle { .init() }
}

extension ButtonStyle where Self == SpeakingSecondaryButtonStyle {
    /// Clear Liquid Glass capsule for the second action under `echoGlassProminent`.
    static var echoGlass: SpeakingSecondaryButtonStyle { .init() }
}

extension View {
    /// Pins a screen's main buttons to the bottom, centred and `EchoSpacing.bottomAction`
    /// above the home indicator, the same on every screen. Content scrolls above them.
    func echoBottomActions<Actions: View>(@ViewBuilder _ actions: () -> Actions) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: EchoSpacing.buttonStack) {
                actions()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, EchoSpacing.screenHorizontal)
            .padding(.top, EchoSpacing.m)
            .padding(.bottom, EchoSpacing.bottomAction)
        }
    }
}

/// Round 44 pt Liquid Glass button showing an SF Symbol.
/// Used for profile, back and close actions that float over content.
struct EchoIconButton: View {
    /// SF Symbol name, e.g. `"person.fill"`.
    let systemImage: String
    /// Spoken by VoiceOver, since the button has no visible text.
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .accessibilityLabel(accessibilityLabel)
    }
}
