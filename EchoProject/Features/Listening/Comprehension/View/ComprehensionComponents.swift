import SwiftUI

enum ComprehensionColor {
    static let correct = Color(hex: 0x1E9E5A)
    static let incorrect = Color(hex: 0xE0383E)
    static let correctFill = Color(hex: 0xEAF8EF, opacity: 0.92)
    static let incorrectFill = Color(hex: 0xFDEEEF, opacity: 0.92)

    static let slotFill = Color(hex: 0xF4F8FC, opacity: 0.7)
    static let slotStroke = Color(hex: 0xB9CCE0)
    static let slotBadge = Color(hex: 0xA1CCEB, opacity: 0.5)
    static let cardFill = Color.white.opacity(0.92)
    static let cardStroke = Color(hex: 0xDCE6F0)
    /// The numbered place a dragged card is hovering over.
    static let slotTargetFill = Color(hex: 0xEAF3FF)
    static let slotTargetStroke = Color(hex: 0x0A7AFF, opacity: 0.55)
    static let dragHandle = Color(hex: 0x618CA3, opacity: 0.58)

    static let tileFill = Color(hex: 0xE3F7FF, opacity: 0.52)
    static let tileStroke = Color.white.opacity(0.9)

    static let howToPlayText = Color(hex: 0x004FA8)
    static let questionLabel = Color(hex: 0x122E4A)
    static let frostedCard = Color.white.opacity(0.58)
    static let frostedCardShadow = EchoShadow(color: Color(hex: 0x305285, opacity: 0.11), radius: 9, y: 6)

    static let listenIconFill = Color(hex: 0xE0F2FE)
    static let answerIconFill = Color(hex: 0xD1FAE5)
    static let answerIcon = Color(hex: 0x10B981)

    static let tutorialSubtitle = Color(hex: 0x263B50)
    static let tutorialWaterThumb = Color(hex: 0xA1E0FF, opacity: 0.7)
    static let tutorialSeedThumb = Color(hex: 0xC7F099, opacity: 0.7)
    static let tutorialFlowerThumb = Color(hex: 0xFFEB85, opacity: 0.7)
    static let tutorialHandShadow = Color(red: 0.24, green: 0.15, blue: 0.08, opacity: 0.16)

    // Matching lines and dots (Figma "Matching" game and tutorial)
    static let matchLine = Color(hex: 0x0A7AFF)
    static let matchCorrect = Color(hex: 0x149E6B)
    static let matchIncorrect = Color(hex: 0xDB3038)
    static let matchDotIdleFill = Color(hex: 0xEDF6FE)
    static let matchDotIdleStroke = Color(hex: 0xBDDBF5)
    static let matchTileHighlight = Color(hex: 0x0573FF)
}

enum ComprehensionLayout {
    static let questionTop: CGFloat = 24
    static let bottomButtonSideInset: CGFloat = 61
    static let bottomButtonBottomInset: CGFloat = EchoSpacing.bottomAction
    static let orderingRowHeight: CGFloat = 75
    static let matchingTileHeight: CGFloat = 106
    static let tutorialButtonHeight: CGFloat = 44
    static let tutorialButtonTopInset: CGFloat = 4
    static let tutorialHeaderTopGap: CGFloat = 26
    static let tutorialHeaderToBoardGap: CGFloat = 90
    static let orderingTutorialHorizontalInset: CGFloat = 43
    static let orderingTutorialRowSpacing: CGFloat = 12
    static let orderingTutorialPoolTopGap: CGFloat = 36
    static let matchingTutorialHorizontalInset: CGFloat = 10
    static let matchingTutorialHeaderToBoardGap: CGFloat = 108
    static let matchingTutorialTileWidth: CGFloat = 140
    static let matchingTutorialTileHeight: CGFloat = 114
    static let matchingTutorialRowSpacing: CGFloat = 24
    static let matchingTutorialArtworkSize: CGFloat = 50
    static let matchingTutorialArtworkTop: CGFloat = 14
    static let matchingTutorialLabelBottom: CGFloat = 9
    static let matchingTutorialDotSize: CGFloat = 22
    static let matchingTutorialLineWidth: CGFloat = 4
    /// The hand artwork's canvas, and where its fingertip sits inside it.
    static let matchingTutorialHandSize = CGSize(width: 87, height: 96)
    static let matchingTutorialHandTip = CGPoint(x: 51, y: 15)
    /// The hand starts this far below the board and slides up, as in Figma Step 30 → 31.
    static let matchingTutorialHandStartDrop: CGFloat = 240

    // Matching game
    static let matchingTileGap: CGFloat = 50
    static let matchingRowSpacing: CGFloat = 20
    static let matchingDotSize: CGFloat = 19
    /// Dots sit half over the tile edge, 3.5 pt into the gap.
    static let matchingDotInset: CGFloat = 3.5
    static let matchingLineWidth: CGFloat = 6
    static let matchingDotStroke: CGFloat = 3
    static let matchingHighlightStroke: CGFloat = 1.8
    /// Extra room around a card that still counts as dropping on it.
    static let matchingDropSlop: CGFloat = 16
}

struct QuestionHeader: View {
    let title: String
    let subtitle: String
    let onHowToPlay: () -> Void
    var titleColor: Color = EchoColor.textPrimary
    var subtitleColor: Color = EchoColor.textSecondary

    var body: some View {
        VStack(spacing: EchoSpacing.xxs) {
            Text(title)
                .echoFont(.heading, .bold)
                .foregroundStyle(titleColor)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .echoFont(.body)
                .foregroundStyle(subtitleColor)
            HowToPlayPill(action: onHowToPlay)
                .padding(.top, 22)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

struct HowToPlayPill: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text("?")
                    .echoFont(.caption, .semibold)
                    .foregroundStyle(.white)
                    .frame(width: 16, height: 16)
                    .background(EchoColor.accentFill, in: .rect(cornerRadius: 8))
                    .accessibilityHidden(true)
                Text("How to play")
                    .echoFont(.caption, .semibold)
                    .foregroundStyle(ComprehensionColor.howToPlayText)
            }
            .padding(.horizontal, EchoSpacing.m)
            .frame(height: 36)
            .background(Color.white.opacity(0.7), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("How to play")
        .accessibilityHint("Shows instructions for this activity")
    }
}

struct ComprehensionBottomButton: View {
    let title: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.echoPrimary)
            .disabled(!isEnabled)
            .padding(.horizontal, ComprehensionLayout.bottomButtonSideInset)
            .padding(.bottom, ComprehensionLayout.bottomButtonBottomInset)
    }
}
