import SwiftUI

/// Detection screen: speech bubble, the hiding place (bush or house), then Play / "I heard it" / Next.
/// Layout only; every decision lives in ListenAndRespondViewModel.
struct ListenAndRespondView: View {
    @State private var vm: ListenAndRespondViewModel

    init(vm: ListenAndRespondViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ExerciseScaffold(title: vm.title, subtitle: vm.subtitle, onBack: vm.backTapped) {
            // Positions below the heading come straight from the Figma frames:
            // speech bubble at 14, hiding place standing on the hill (ground line at 414), buttons at 472.
            ZStack(alignment: .top) {
                scene
                bubble
                    .padding(.top, 14)
                controls
                    .padding(.top, 472)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onDisappear { vm.stopAll() }
    }

    // MARK: - Scene

    @ViewBuilder
    private var scene: some View {
        switch vm.story.hidingSpot {
        case .bush: bushScene
        case .house: houseScene
        }
    }

    // MARK: Bush (Figma "Hiding spot / Bush")

    /// The bush stands on the green hill of the background. It never moves while the
    /// sound plays, so the child answers from what they heard, not from what they saw.
    /// After the answer the animal rises up from behind it; on Next it just fades away.
    private var bushScene: some View {
        ZStack(alignment: .top) {
            // Clipped just below the bush, so while the animal is still low
            // it stays hidden behind the bush instead of showing underneath it.
            ZStack(alignment: .top) {
                if let image = vm.revealImage {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 160, alignment: .bottom)
                        .padding(.top, 200)
                        .transition(.asymmetric(
                            insertion: .offset(y: 120),     // starts hidden behind the bush, rises up
                            removal: .opacity               // leaves without sliding back down
                        ))
                        .accessibilityLabel(vm.title)
                }
            }
            .frame(width: 362, height: 400, alignment: .top)
            .clipped()

            Image("img_hide_bush")
                .padding(.top, 290)
                .accessibilityHidden(true)
        }
        .frame(width: 362, alignment: .top)
        .animation(.spring(duration: 0.5, bounce: 0.25), value: vm.revealImage)
    }

    // MARK: House (Figma "Hiding spot / Front door")

    /// The house stays the same while the sound plays. After the answer the picture
    /// cross-fades to the doorbell ringing. On a silent round it stays the same.
    private var houseScene: some View {
        ZStack(alignment: .top) {
            Image(vm.houseImage)
                .id(vm.houseImage)                  // a new picture fades in over the old one
                .transition(.opacity)
                .padding(.top, 174)                 // ground line of the house (240) sits at 414
                .accessibilityLabel(vm.phase == .reveal ? vm.title : "A house with a doorbell")
        }
        .frame(width: 362, alignment: .top)
        .animation(.easeInOut(duration: 0.35), value: vm.houseImage)
    }

    // MARK: - Speech bubble (Figma "Encouragement")

    @ViewBuilder
    private var bubble: some View {
        if let title = vm.bubbleTitle {
            VStack(spacing: EchoSpacing.xs) {
                Text(title)
                    .echoFont(.body, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                if let detail = vm.bubbleDetail {
                    Text(detail)
                        .echoFont(.supporting)
                        .foregroundStyle(EchoColor.textTertiary)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.vertical, EchoSpacing.l)
            .padding(.horizontal, EchoSpacing.xl)
            .frame(width: 280)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
            .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 30))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.8), lineWidth: 2))
            .shadow(color: Color(hex: 0x14334D, opacity: 0.14), radius: 12, y: 8)
        }
    }

    // MARK: - Buttons (Figma "Actions")

    @ViewBuilder
    private var controls: some View {
        switch vm.phase {
        case .ready, .playing:
            VStack(spacing: EchoSpacing.xs) {
                Button {
                    vm.playTapped()
                } label: {
                    Image(systemName: vm.phase == .playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .accessibilityLabel(vm.phase == .playing ? "Pause" : "Play")

                if vm.phase == .playing {
                    Text("Pause")
                        .echoFont(.caption, .semibold)
                        .foregroundStyle(EchoColor.textPrimary)
                }
            }

        case .asking:
            VStack(spacing: EchoSpacing.buttonStack) {
                Button("I Heard It") {
                    vm.answer(heardIt: true)
                }
                .buttonStyle(.echoGlassProminent)

                Button("I Didn’t Hear It") {
                    vm.answer(heardIt: false)
                }
                .buttonStyle(.echoGlass)
            }
            .frame(width: EchoSize.buttonWidth)

        case .reveal:
            Button("Next", action: vm.nextTapped)
                .buttonStyle(.echoGlassProminent)
                .frame(width: EchoSize.buttonWidth)
        }
    }
}

/// Whole Detection flow in the canvas: Play → answer → Next → … → completion screen.
/// Uses the real router stack so Next and Try Again work. The leave overlay is drawn by
/// RootView, so run the app to see it.
private struct DetectionFlowPreview: View {
    var exerciseId = "detection.hide-and-seek.animal"
    @State private var container = AppContainer.dummy(startPastOnboarding: true)

    var body: some View {
        @Bindable var router = container.router
        NavigationStack(path: $router.listeningPath) {
            RouteDestinationView(route: .exercise(exerciseId: exerciseId))
                .navigationDestination(for: Route.self) { route in
                    RouteDestinationView(route: route)
                }
        }
        .environment(container)
        .environment(container.router)
    }
}

#Preview("Detection · full flow") {
    DetectionFlowPreview()
}

#Preview("Detection · Hear the Doorbell") {
    DetectionFlowPreview(exerciseId: "detection.hide-and-seek.doorbell")
}
