import SwiftUI

/// "Where should we start?": Leo and Echo waving, the 4 levels at a glance,
/// then Start the Quick Check or choose a level yourself.
/// Figma: Precoding_FINAL › 02 · Onboarding › "Onboarding / Choose assessment or custom level".
struct ChoosePathView: View {
    @State private var vm: ChoosePathViewModel

    init(vm: ChoosePathViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        // The overlays sit next to the screen in a ZStack (not inside it), so they don't
        // inherit the space reserved for the bottom buttons.
        ZStack {
            mainScreen

            switch vm.overlay {
            case .customLevel:
                CustomLevelOverlay(vm: vm)
                    .transition(.opacity)
            case .levelInfo:
                LevelInfoOverlay(levels: vm.levels, onClose: vm.didDismissOverlay)
                    .transition(.opacity)
            case nil:
                EmptyView()
            }
        }
        .animation(.easeOut(duration: 0.2), value: vm.overlay)
        .echoScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var mainScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Figma: "Art · Duo · Waving hello".
                EchoAssetImage(name: "img_duo_waving")
                    .frame(width: 176, height: 176)

                Text("Where should we start?")
                    .echoFont(.heading, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 14)

                Text("8 quick questions show which of these 4 levels fits your child best.")
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textTertiary)
                    .padding(.top, EchoSpacing.xs)

                LevelOverviewGrid(levels: vm.levels)
                    .padding(.top, 23)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 31)
            .padding(.bottom, EchoSpacing.xl)
        }
        .scrollBounceBehavior(.basedOnSize)
        .overlay(alignment: .top) {
            HStack {
                EchoIconButton(systemImage: "chevron.left", accessibilityLabel: "Back", action: vm.didTapBack)
                Spacer()
                Button("Understand the levels", systemImage: "info.circle", action: vm.didTapLevelInfo)
                    .labelStyle(.iconOnly)
                    .font(.system(size: 22))
                    .foregroundStyle(EchoColor.accent)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.9), in: Circle())
                    .echoShadow(.badge)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, EchoSpacing.screenHorizontal)
            .padding(.top, 3)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: EchoSpacing.buttonStack) {
                Button("Start the Quick Check", action: vm.didTapQuickCheck)
                    .buttonStyle(.echoPrimary)
                Button("I\u{2019}ll choose the level myself", action: vm.didTapChooseLevel)
                    .buttonStyle(.echoSecondary)
            }
            .frame(maxWidth: EchoSize.buttonWidth)
            .padding(.bottom, EchoSpacing.bottomAction)
        }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: false)
    return NavigationStack {
        ChoosePathView(vm: container.makeChoosePathViewModel())
    }
    .environment(container)
    .environment(container.router)
}
