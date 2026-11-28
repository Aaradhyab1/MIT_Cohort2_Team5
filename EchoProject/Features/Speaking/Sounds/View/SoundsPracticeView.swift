import SwiftUI

/// Sounds practice: listen to the sound, then record it, ten times.
/// Figma: Precoding_FINAL › 11 · Speech — Sounds.
/// TODO: Build the real game from Figma.
struct SoundsPracticeView: View {
    @State private var vm: SoundsPracticeViewModel

    init(vm: SoundsPracticeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: vm.title, note: "Listen, then record the sound")
            .safeAreaInset(edge: .bottom) {
                Button("Finish (demo)", action: vm.didTapFinishDemo)
                    .buttonStyle(.echoPrimary)
                    .padding(.horizontal, EchoSpacing.screenHorizontal)
                    .padding(.bottom, EchoSpacing.bottomAction)
            }
            .exerciseChrome(onBack: vm.didTapBack)
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        SoundsPracticeView(vm: container.makeSoundsPracticeViewModel(exerciseId: "sounds.vowel"))
    }
    .environment(container)
    .environment(container.router)
}
