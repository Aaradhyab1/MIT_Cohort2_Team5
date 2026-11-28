import SwiftUI

/// 01 — At the Ice Cream Shop: title, picture slot for the boy and shopkeeper,
/// the "Meet your shopkeeper" card and Start Conversation.
struct ConversationIntroView: View {
    let onStart: () -> Void

    private let steps = ["Listen to the shopkeeper", "Pick one of the choices", "Take turns speaking"]

    var body: some View {
        VStack(alignment: .leading, spacing: EchoSpacing.l) {
            VStack(alignment: .leading, spacing: EchoSpacing.xs) {
                Text("At the Ice Cream Shop")
                    .echoFont(.heading, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Let's visit an ice cream shop!")
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textTertiary)
            }

            // Picture slot: boy and shopkeeper (Figma: 402 × 317).
            ConversationImageSlot(imageName: "img_conversation_intro")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            card

            Button("Start Conversation", action: onStart)
                .buttonStyle(.echoPrimary)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .padding(.bottom, EchoSpacing.bottomAction)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: EchoSpacing.m) {
            VStack(alignment: .leading, spacing: EchoSpacing.xs) {
                Text("Meet your shopkeeper")
                    .echoFont(.subheading, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                Text("Listen to the shopkeeper and tell them what you'd like.")
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textTertiary)
            }
            VStack(alignment: .leading, spacing: EchoSpacing.m) {
                ForEach(steps, id: \.self) { step in
                    Label {
                        Text(step)
                            .echoFont(.supporting)
                            .foregroundStyle(EchoColor.textPrimary)
                    } icon: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(EchoColor.accent)
                            .frame(width: 22, height: 22)
                            .background(EchoColor.accent.opacity(0.12), in: Circle())
                    }
                }
            }
            .padding(EchoSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.6), in: .rect(cornerRadius: EchoRadius.card))
        }
        .padding(EchoSpacing.l)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}

#Preview {
    ConversationIntroView(onStart: {})
        .echoExerciseBackground(.iceCreamShop)
}
