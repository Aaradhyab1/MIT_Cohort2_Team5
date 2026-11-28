import SwiftUI

/// Spacing scale, in points. Use these instead of literal numbers for padding and stack spacing.
enum EchoSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 28

    /// Leading and trailing margin of every screen.
    static let screenHorizontal: CGFloat = 20
    /// Vertical gap between sections of a scrolling screen.
    static let section: CGFloat = 28
}

/// Fixed component sizes, in points.
enum EchoSize {
    /// Width of the main and secondary buttons on every screen (Figma: 280 pt, centred).
    static let buttonWidth: CGFloat = 280
}

/// Corner radii, in points. Pills and buttons are capsules and use `Capsule()` instead.
enum EchoRadius {
    /// Artwork inside small cards.
    static let thumbnailSmall: CGFloat = 14
    /// Standalone thumbnails, e.g. in list rows.
    static let thumbnail: CGFloat = 16
    /// Standard cards.
    static let card: CGFloat = 22
    /// Wide, full-width cards.
    static let cardLarge: CGFloat = 24
    /// The hero card on Home.
    static let hero: CGFloat = 32
}

/// Drop shadow tokens.
///
/// Figma specifies shadows by blur, while SwiftUI takes a radius of roughly half the blur,
/// so the radii here are half the Figma values.
struct EchoShadow {
    let color: Color
    let radius: CGFloat
    let y: CGFloat

    /// Standard cards.
    static let card = EchoShadow(color: Color(hex: 0x0C3373, opacity: 0.10), radius: 12, y: 8)
    /// The hero card.
    static let hero = EchoShadow(color: Color(hex: 0x0C3373, opacity: 0.12), radius: 14, y: 10)
    /// Small floating elements such as the level badge.
    static let badge = EchoShadow(color: Color(hex: 0x0C3373, opacity: 0.12), radius: 6, y: 4)
    /// Blue glow under the primary button.
    static let primaryButton = EchoShadow(color: Color(hex: 0x007AFF, opacity: 0.28), radius: 15, y: 10)
    /// No shadow. Useful for disabled states.
    static let none = EchoShadow(color: .clear, radius: 0, y: 0)
}

extension View {
    /// Applies an `EchoShadow` token.
    func echoShadow(_ shadow: EchoShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}
