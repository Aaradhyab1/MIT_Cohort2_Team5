import SwiftUI

/// "Great start!": Leo and Echo celebrating, then the recommended starting level,
/// lit step by step, and Continue to Home.
/// Figma: Precoding_FINAL › 02 · Onboarding › "Assessment / Result reveal" and "Great start / Level 3".
struct QuickCheckResultView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var vm: QuickCheckResultViewModel

    init(vm: QuickCheckResultViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Figma: "Art · Duo · Celebrating", exported as one picture with its grass mound.
                EchoAssetImage(name: "img_duo_celebrating")
                    .frame(width: 373, height: 259)
                    .padding(.top, 30)
                    .frame(height: 305, alignment: .top)

                Text("Great start!")
                    .echoFont(.display, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, EchoSpacing.s)

                Text("Here\u{2019}s where your child will begin.")
                    .echoFont(.body)
                    .foregroundStyle(EchoColor.textSecondary)
                    .padding(.top, EchoSpacing.s)

                if let recommendation = vm.recommendation {
                    RecommendationCard(
                        recommendation: recommendation,
                        levelCount: vm.levelCount,
                        revealedStep: vm.revealedStep,
                        progressDescription: vm.progressDescription,
                        onInfo: vm.didTapScoringInfo
                    )
                    .padding(.top, 18)
                    .padding(.horizontal, 4)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, EchoSpacing.screenHorizontal)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            Button("Continue", action: vm.didTapContinue)
                .buttonStyle(.echoPrimary)
                .frame(maxWidth: EchoSize.buttonWidth)
                .padding(.bottom, EchoSpacing.bottomAction)
                // Fades and rises into place once the reveal finishes.
                .opacity(vm.isContinueVisible ? 1 : 0)
                .offset(y: vm.isContinueVisible || reduceMotion ? 0 : 18)
                .disabled(!vm.isContinueVisible)
        }
        .animation(.easeOut(duration: 0.45), value: vm.revealedStep)
        .animation(.easeOut(duration: 0.5), value: vm.isContinueVisible)
        .echoScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .task {
            await vm.didAppear(reduceMotion: reduceMotion)
        }
        .sheet(isPresented: $vm.isScoringInfoPresented) {
            HowScoringWorksSheet(
                answerValueRows: vm.answerValueRows,
                placementRows: vm.placementRows,
                onClose: vm.didCloseScoringInfo
            )
            .presentationDetents([.height(500)])
            .presentationDragIndicator(.visible)
            .presentationBackground(EchoColor.sheetSurface)
            .presentationCornerRadius(28)
        }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: false)
    container.profile.saveQuickCheck(QuickCheckResult(answers: [:], recommendedLevel: 3))
    return NavigationStack {
        QuickCheckResultView(vm: container.makeQuickCheckResultViewModel())
    }
    .environment(container)
    .environment(container.router)
}
