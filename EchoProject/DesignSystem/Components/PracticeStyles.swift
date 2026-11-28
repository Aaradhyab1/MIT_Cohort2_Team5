import SwiftUI

// Colours, a shadow and a button style for the shared practice screens
// (Before you start and the leave overlay). Any screen may use them.

extension EchoColor {
    /// Light blue pill fill, for pills sitting straight on the screen background.
    static let pillSurfaceTinted = Color(hex: 0x0A7CFF, opacity: 0.10)

    /// Warm yellow box holding the "Tip for grown-ups", and its label colour.
    static let tipSurface = Color(hex: 0xFFC757, opacity: 0.22)
    static let tipLabel = Color(hex: 0x7A5200)

    /// Dims the screen behind a confirmation card.
    static let scrim = Color(hex: 0x0D1F3D, opacity: 0.22)
    /// Frosted white fill of a confirmation card.
    static let alertSurface = Color.white.opacity(0.86)
    /// Red ✕ on the leave card, and the pale pink circle behind it.
    static let danger = Color(hex: 0xFF3B30)
    static let dangerSurface = Color(hex: 0xFFF1F2)
}

extension EchoShadow {
    /// Confirmation cards floating over a dimmed screen.
    static let alert = EchoShadow(color: Color(hex: 0x142337, opacity: 0.24), radius: 35, y: 24)
}

/// Style for the second choice under a primary button, such as "Hear an example first" or "Leave".
///
/// Full-width Liquid Glass capsule with dark text, the same height as `.echoPrimary`.
///
///     Button("Leave", action: vm.leave)
///         .buttonStyle(.echoSecondary)
struct EchoSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .echoFont(.body, .medium)
            .foregroundStyle(EchoColor.textPrimary)
            .frame(maxWidth: EchoSize.buttonWidth, minHeight: EchoSize.buttonHeight)
            .glassEffect(.regular.interactive(), in: .capsule)
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == EchoSecondaryButtonStyle {
    /// See `EchoSecondaryButtonStyle`.
    static var echoSecondary: EchoSecondaryButtonStyle { .init() }
}
