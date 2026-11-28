import SwiftUI

/// Differentiation game: Mia, Leo and Zoe each say a sound; tap the one who was different.
/// Figma: edit_cl › 07 · Level 2 — Differentiation. Layout only; decisions live in the ViewModel.
struct OddOneOutView: View {
    @State private var vm: OddOneOutViewModel

    init(vm: OddOneOutViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if vm.showsBackButton {
                    EchoIconButton(systemImage: "chevron.left", accessibilityLabel: "Back", action: vm.backTapped)
                }
                Spacer()
            }
            .frame(height: 44)

            header
                .padding(.top, 17)

            // One fixed-size stage for the cards and the celebration, so nothing
            // below it (or the header above) moves when the content changes.
            ZStack(alignment: .top) {
                if vm.showsCelebration {
                    celebration
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                } else {
                    friendCards
                        .transition(.opacity)
                }
            }
            .frame(height: Layout.stageHeight, alignment: .top)
            .padding(.top, Layout.gap)

            Spacer(minLength: Layout.gap)

            bottomButton
                .frame(height: 50)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .echoExerciseBackground()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .animation(.easeInOut(duration: 0.25), value: vm.phase)
        .onDisappear { vm.stopAll() }
    }

    // MARK: - Layout constants (shared so spacing stays the same in every phase)

    private enum Layout {
        /// Space between header, cards and the button.
        static let gap: CGFloat = 24
        static let cardWidth: CGFloat = 171
        static let cardHeight: CGFloat = 207
        static let cardSpacing: CGFloat = 20
        /// Two rows of cards; the celebration (300 tall) fits inside this too.
        static let stageHeight: CGFloat = cardHeight * 2 + cardSpacing
    }

    // MARK: - Header: plain title and helper text, no card behind it (matches the other flows)

    private var header: some View {
        VStack(spacing: EchoSpacing.s) {
            Text(vm.title)
                .echoFont(.title, .bold)
                .foregroundStyle(Color(hex: 0x181F2F))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            // Always reserve two lines so a longer or shorter line never pushes the cards.
            Text(vm.subtitle)
                .echoFont(.body)
                .foregroundStyle(Color(hex: 0x455269))
                .lineLimit(2, reservesSpace: true)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 362)
    }

    // MARK: - Friend cards: Mia and Leo in a row, Zoe centred below

    private var friendCards: some View {
        let cards = vm.cards
        return VStack(spacing: Layout.cardSpacing) {
            HStack(spacing: Layout.cardSpacing) {
                ForEach(cards.prefix(2)) { card in friendCard(card) }
            }
            ForEach(cards.dropFirst(2)) { card in friendCard(card) }
        }
    }

    /// Figma "Friend card": 171 × 207, frosted white, outline shows the card's state.
    private func friendCard(_ card: OddOneOutViewModel.Card) -> some View {
        Button {
            vm.cardTapped(card.id)
        } label: {
            VStack(spacing: EchoSpacing.s) {
                avatar(card.avatar, size: 120, border: 3)
                Text(card.name)
                    .echoFont(.subheading, .semibold)
                    .foregroundStyle(Color(hex: 0x181F2F))
                Text(card.status)
                    .echoFont(.caption, card.highlight == .correct ? .semibold : .regular)
                    .foregroundStyle(Color(hex: 0x455269))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(14)
            .frame(width: Layout.cardWidth, height: Layout.cardHeight)
            .background(.ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 30))
            .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 30))
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(outline(card.highlight), lineWidth: card.highlight == .none ? 2 : 2.6)
            )
        }
        .buttonStyle(.plain)
        .allowsHitTesting(card.canTap)
        .accessibilityLabel("\(card.name), \(card.status)")
    }

    private func outline(_ highlight: OddOneOutViewModel.Card.Highlight) -> Color {
        switch highlight {
        case .none: return .white.opacity(0.8)
        case .speaking: return Color(hex: 0x0A85FF)
        case .correct: return Color(hex: 0x34C759)
        case .wrong: return Color(hex: 0xFF3B30)
        }
    }

    private func avatar(_ name: String, size: CGFloat, border: CGFloat) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: border))
            .shadow(color: Color(hex: 0x003333, opacity: 0.2), radius: 6, y: 4)
    }

    // MARK: - "Great listening!" (Figma "Differentiation / correct")

    private var celebration: some View {
        ZStack {
            avatar(vm.oddAvatar, size: 236, border: 5.9)
                .frame(width: 280, height: 280)
                .background(.ultraThinMaterial.opacity(0.5), in: Circle())
                .background(.white.opacity(0.35), in: Circle())
                .overlay(Circle().stroke(Color(hex: 0x33C759), lineWidth: 5))
                .shadow(color: Color(hex: 0x1A4D40, opacity: 0.2), radius: 12, y: 8)

            Image(systemName: "checkmark")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color(hex: 0x33C759), in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 4))
                .offset(x: 93, y: 122)

            // Sparkles around the ring, at the Figma positions.
            sparkle(26).offset(x: -148, y: -147)
            sparkle(22).offset(x: 140, y: -139)
            sparkle(18).offset(x: -164, y: 29)
            sparkle(28).offset(x: 163, y: 24)
            sparkle(20).offset(x: -131, y: 160)
            sparkle(24).offset(x: 131, y: 192)
        }
        .frame(width: 362, height: 300)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(vm.subtitle)
    }

    private func sparkle(_ size: CGFloat) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundStyle(Color(hex: 0xFFC857))
    }

    // MARK: - Bottom button

    @ViewBuilder
    private var bottomButton: some View {
        switch vm.bottomButton {
        case .start:
            wideButton("Start", prominent: true, action: vm.startTapped)
        case .replay:
            wideButton(vm.replayTitle, prominent: true, action: vm.replayTapped)
        case .replaying:
            wideButton("Replaying…", prominent: false) {}
                .disabled(true)
        case .next:
            wideButton("Continue", prominent: true, action: vm.continueTapped)
        case nil:
            Color.clear
        }
    }

    @ViewBuilder
    private func wideButton(_ title: String, prominent: Bool, action: @escaping () -> Void) -> some View {
        if prominent {
            Button(action: action) { Text(title).frame(maxWidth: .infinity) }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .frame(width: 280)
        } else {
            Button(action: action) { Text(title).frame(maxWidth: .infinity) }
                .buttonStyle(.glass)
                .controlSize(.large)
                .frame(width: 280)
        }
    }
}

/// Whole exercise in the canvas: Start → friends speak → choose → Great listening → … → completion.
private struct OddOneOutFlowPreview: View {
    @State private var container = AppContainer.dummy(startPastOnboarding: true)

    var body: some View {
        @Bindable var router = container.router
        NavigationStack(path: $router.listeningPath) {
            RouteDestinationView(route: .exercise(exerciseId: "differentiation.odd-sound-out"))
                .navigationDestination(for: Route.self) { route in
                    RouteDestinationView(route: route)
                }
        }
        .environment(container)
        .environment(container.router)
    }
}

#Preview("Differentiation · Odd Sound Out") {
    OddOneOutFlowPreview()
}
