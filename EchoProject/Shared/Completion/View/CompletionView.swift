import SwiftUI

/// "Great Job!" / "Almost There!" / "Exercise Completed" over the landscape background.
/// Shared by every exercise; the characters come from `CompletionArtwork` for the level.
/// Matches the Figma completion frames: characters peek over a frosted card,
/// with Continue and Try Again below.
struct CompletionView: View {
    @State private var vm: CompletionViewModel

    init(vm: CompletionViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                friends
                card
                    .padding(.top, 119)     // the card overlaps the bottom of the friends
            }
            .padding(.top, 160)

            Spacer()

            buttons
        }
        .padding(.bottom, EchoSpacing.bottomAction)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .echoExerciseBackground()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Characters (or a symbol when the level has no art yet)

    @ViewBuilder
    private var friends: some View {
        if vm.friendImages.isEmpty {
            Image(systemName: vm.symbol)
                .font(.system(size: 64))
                .foregroundStyle(EchoColor.accent)
                .frame(width: 120, height: 120)
                .background(.white.opacity(0.8), in: Circle())
                .padding(.top, 20)
                .accessibilityHidden(true)
        } else {
            HStack(alignment: .bottom, spacing: 18) {
                ForEach(vm.friendImages, id: \.self) { name in
                    if vm.artwork.circular {
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: vm.artwork.width, height: vm.artwork.height)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 4))
                    } else {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: vm.artwork.width, height: vm.artwork.height)
                    }
                }
            }
            .offset(y: -vm.artwork.lift)
            .accessibilityHidden(true)
        }
    }

    // MARK: - Frosted card (Figma "Glass card", 342 × 211)

    private var card: some View {
        VStack(spacing: EchoSpacing.l) {
            Text(vm.title)
                .echoFont(.display, .bold)
                .foregroundStyle(Color(hex: 0x0A2472))      // Figma title navy
            Text(vm.message)
                .echoFont(.body)
                .foregroundStyle(Color(hex: 0x4A4F80))      // Figma message colour
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, EchoSpacing.xl)
        .frame(width: 342, height: 211)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: EchoRadius.cardLarge))
        .background(Color(hex: 0xD6F2FF, opacity: 0.74), in: RoundedRectangle(cornerRadius: EchoRadius.cardLarge))
        .overlay(RoundedRectangle(cornerRadius: EchoRadius.cardLarge).stroke(.white.opacity(0.85), lineWidth: 1))
        .shadow(color: Color(hex: 0x2173B2, opacity: 0.12), radius: 12, y: 8)
    }

    // MARK: - Continue / Try Again

    private var buttons: some View {
        VStack(spacing: EchoSpacing.buttonStack) {
            Button(vm.primaryTitle, action: vm.primaryTapped)
                .buttonStyle(.echoGlassProminent)

            if vm.showsTryAgain {
                Button("Try Again", action: vm.tryAgainTapped)
                    .buttonStyle(.echoGlass)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Great Job") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return CompletionView(vm: container.makeCompletionViewModel(exerciseId: "detection.hide-and-seek.animal", outcome: .greatJob))
}

#Preview("Almost There") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return CompletionView(vm: container.makeCompletionViewModel(exerciseId: "detection.hide-and-seek.animal", outcome: .almostThere))
}

#Preview("Exercise Completed") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return CompletionView(vm: container.makeCompletionViewModel(exerciseId: "detection.hide-and-seek.animal", outcome: .keepPractising))
}
