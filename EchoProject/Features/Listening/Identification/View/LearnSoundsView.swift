import SwiftUI

/// "Meet the instruments": tap each picture to hear its sound before the game starts.
/// Figma: edit_cl › 08 · Level 3 — Instruments, "L1–L4 · Learn" (blue progress).
/// Layout only; decisions live in LearnSoundsViewModel.
struct LearnSoundsView: View {
    let vm: LearnSoundsViewModel

    var body: some View {
        ZStack {
            meadow

            // Same positions as the game screen, so nothing jumps when the game starts:
            // header at 66, progress where the play button sits (164), title at 250, helper at 298.
            VStack(spacing: 0) {
                header
                    .padding(.top, 4)

                progress
                    .frame(height: 64)
                    .padding(.top, 48)

                Text(vm.title)
                    .echoFont(.heading, .bold)
                    .foregroundStyle(Color(hex: 0x181F2F))
                    .padding(.top, 22)

                Text(vm.helper)
                    .echoFont(.supporting, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .padding(.top, 20)

                Spacer(minLength: 0)

                if vm.showsStart {
                    // Standard bottom action, the same size and position as the app's other buttons.
                    Button("Start the game", action: vm.startTapped)
                        .buttonStyle(.echoGlassProminent)
                        .padding(.bottom, EchoSpacing.bottomAction)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, EchoSpacing.screenHorizontal)
        }
        .animation(.easeInOut(duration: 0.25), value: vm.playingId)
        .animation(.easeInOut(duration: 0.25), value: vm.showsStart)
        .onAppear { vm.startAutoPlay() }
        .onDisappear { vm.stopAll() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            EchoIconButton(systemImage: "chevron.left", accessibilityLabel: "Back", action: vm.backTapped)
            Spacer()
            Text(vm.headerText)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textPrimary)
        }
        .frame(height: 50)
    }

    // MARK: - Progress (native linear progress view)

    private var progress: some View {
        VStack(spacing: EchoSpacing.s) {
            ProgressView(value: Double(vm.heardCount), total: Double(max(vm.total, 1)))
                .tint(Color(hex: 0x0A85FF))
                .frame(width: 220)
            Text(vm.progressCaption)
                .echoFont(.caption)
                .foregroundStyle(EchoColor.textTertiary)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Meadow

    private var meadow: some View {
        MeadowCanvas {
            ForEach(vm.items) { item in
                GroundView(ground: item.ground)
            }

            ForEach(vm.items) { item in
                artButton(item).placed(in: item.artFrame)
            }

            // Little yellow sound waves beside the picture that's playing.
            ForEach(vm.items.filter { $0.state == .playing }) { item in
                Image(systemName: "wave.3.right")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xF6C453))
                    .symbolEffect(.variableColor.iterative)
                    .position(x: item.artFrame.maxX + 12, y: item.artFrame.minY + 14)
                    .accessibilityHidden(true)
            }

            // Name labels under the mats; their job is done once everything is heard.
            if !vm.showsStart {
                ForEach(vm.items) { item in
                    namePill(item)
                        .position(item.labelCenter)
                }
            }
        }
    }

    private func artButton(_ item: LearnSoundsViewModel.Item) -> some View {
        Button {
            vm.itemTapped(item.id)
        } label: {
            if let art = item.art {
                ZStack {
                    if item.state == .playing {
                        OutlineBehind(art: art, color: Color(hex: 0x0A85FF))
                    }
                    Image(art)
                        .resizable()
                        .scaledToFit()
                }
            } else {
                Color.clear
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.label). Tap to hear it.")
    }

    /// Figma "Name pill": white with a speaker, blue while playing, green with a tick once heard.
    private func namePill(_ item: LearnSoundsViewModel.Item) -> some View {
        let style: (fill: Color, text: Color, icon: Color, symbol: String) = switch item.state {
        case .new: (.white.opacity(0.92), Color(hex: 0x181F2F), Color(hex: 0x0A85FF), "speaker.wave.2.fill")
        case .playing: (Color(hex: 0x0A85FF), .white, .white, "speaker.wave.2.fill")
        case .heard: (Color(hex: 0xE6F6EA), Color(hex: 0x248A3D), Color(hex: 0x34C759), "checkmark.circle.fill")
        }

        return Button {
            vm.itemTapped(item.id)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: style.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style.icon)
                Text(item.label)
                    .echoFont(.supporting, .semibold)
                    .foregroundStyle(style.text)
            }
            .padding(.leading, 10)
            .padding(.trailing, 12)
            .padding(.vertical, 5)
            .background(style.fill, in: Capsule())
            .overlay {
                if item.state == .heard {
                    Capsule().stroke(Color(hex: 0x34C759), lineWidth: 1.5)
                }
            }
            .shadow(color: Color(hex: 0x3D2A14, opacity: 0.12), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.state == .heard ? "\(item.label), heard. Tap to hear it again." : "\(item.label). Tap to hear it.")
    }
}
