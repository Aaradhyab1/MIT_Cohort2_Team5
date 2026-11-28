import SwiftUI

/// Shown after every sentence or paragraph: cheering kids over a frosted card with the
/// result and the real accuracy in a ring. One view for all four categories and all four
/// results; only the words, the ring colour and the buttons change.
/// Figma: Precoding_FINAL › 13 · Speech — Paragraphs › "Paragraphs / Completion".
struct SentencesCompletionView: View {
    let result: SentencesResult
    /// "Next sentence", or "Back to home" after the last passage.
    var continueTitle = "Back to home"
    let onTryAgain: () -> Void
    let onContinue: () -> Void

    /// How far the card covers the bottom of the kids.
    private static let cardOverlap: CGFloat = 22

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Fills the ring from empty when the screen appears.
    @State private var ringFill = 0.0

    var body: some View {
        VStack(spacing: 0) {
            // The kids stand behind the card, which covers the bottom of their shirts
            // (Figma: kids at y 140–356, card from y 334, so a 22 pt overlap).
            ZStack(alignment: .top) {
                Image("img_duo_cheering")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 305, height: 172)
                    // Fade the cut edge, so no hard line shows through the frosted card.
                    .mask {
                        LinearGradient(
                            stops: [.init(color: .black, location: 0.8), .init(color: .clear, location: 1)],
                            startPoint: .top, endPoint: .bottom
                        )
                    }
                    .accessibilityHidden(true)
                card
                    .padding(.top, 172 - Self.cardOverlap)
            }
            .padding(.top, 78 + Self.cardOverlap)

            Spacer(minLength: EchoSpacing.l)

            buttons
        }
        .padding(.bottom, EchoSpacing.bottomAction)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.9).delay(0.2)) {
                ringFill = result.fraction
            }
        }
        .sensoryFeedback(.success, trigger: ringFill) { _, _ in result.tier == .amazing }
    }

    // MARK: - Frosted card (Figma "frosted results", 342 × 286, 42 pt corners)

    private var card: some View {
        VStack(spacing: 4) {
            Text(result.tier.title)
                .echoFont(.title, .bold)
                .foregroundStyle(Color(hex: 0x0B1F5C))
                .accessibilityAddTraits(.isHeader)
            Text(result.tier.message)
                .echoFont(.body)
                .foregroundStyle(Color(hex: 0x1F3D59))
                .frame(minHeight: 44, alignment: .top)
            accuracyRing
                .frame(height: 131)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 12)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .frame(width: 342)
        .background(Color(hex: 0xD6F2FF, opacity: 0.72), in: .rect(cornerRadius: 42))
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 42))
        .overlay(RoundedRectangle(cornerRadius: 42).strokeBorder(.white.opacity(0.7)))
        .shadow(color: Color(hex: 0x2173B2, opacity: 0.12), radius: 12, y: 8)
    }

    // MARK: - Accuracy ring (116 pt, filled to the real percentage)

    private var accuracyRing: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.6), lineWidth: 16)
            Circle()
                .trim(from: 0, to: ringFill)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(result.percent)%")
                    .echoFont(.title, .bold)
                    .foregroundStyle(Color(hex: 0x0B1F5C))
                    .monospacedDigit()
                Text("Accuracy")
                    .echoFont(.supporting)
                    .foregroundStyle(Color(hex: 0x526694))
            }
        }
        .frame(width: 116, height: 116)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Accuracy \(result.percent) percent")
    }

    private var ringColor: Color {
        switch result.tier {
        case .keepTrying: Color(hex: 0xF4A261)     // soft orange
        case .almostThere: Color(hex: 0xF4C542)    // yellow
        case .greatJob: Color(hex: 0xA3D977)       // light green
        case .amazing: Color(hex: 0x34C997)        // green
        }
    }

    // MARK: - Try again / Next sentence or Back to home (Figma "Completion actions", 280 wide)

    private var buttons: some View {
        VStack(spacing: EchoSpacing.buttonStack) {
            if result.tier.offersTryAgain {
                Button("Try again", action: onTryAgain)
                    .buttonStyle(.echoGlassProminent)
            }
            Button(continueTitle, action: onContinue)
                .buttonStyle(.echoGlass)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Amazing · 95%") {
    SentencesCompletionView(result: SentencesResult(correctWords: 19, totalWords: 20), onTryAgain: {}, onContinue: {})
        .echoExerciseBackground()
}

#Preview("Great job · 75%") {
    SentencesCompletionView(result: SentencesResult(correctWords: 15, totalWords: 20), onTryAgain: {}, onContinue: {})
        .echoExerciseBackground()
}

#Preview("Almost there · 50%") {
    SentencesCompletionView(result: SentencesResult(correctWords: 10, totalWords: 20), onTryAgain: {}, onContinue: {})
        .echoExerciseBackground()
}

#Preview("Keep trying · 20%") {
    SentencesCompletionView(result: SentencesResult(correctWords: 4, totalWords: 20), onTryAgain: {}, onContinue: {})
        .echoExerciseBackground()
}
