import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        ZStack(alignment: .bottom) {
            PlantPalBackground()

            // Active tab content
            Group {
                switch router.selectedTab {
                case .plants: PlantsHomeView()
                case .schedule: ScheduleView()
                }
            }
            .transition(.opacity)

            FloatingTabBar(selection: $router.selectedTab)
                .padding(.horizontal, 40)
                .padding(.bottom, 8)
        }
        .fullScreenCover(item: $router.wateredPlant) { plant in
            WateredConfirmationView(plant: plant)
        }
    }
}

// MARK: - Floating glass tab bar

struct FloatingTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var glass

    var body: some View {
        let bar = HStack(spacing: 6) {
            tabButton(.plants, title: "Plants", icon: "leaf.fill")
            tabButton(.schedule, title: "Schedule", icon: "calendar")
        }
        .padding(6)

        Group {
            if #available(iOS 26, *) {
                GlassEffectContainer { bar.glassEffect(.regular, in: .capsule) }
            } else {
                bar
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 0.8))
                    .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
            }
        }
        .animation(Theme.flowSpring, value: selection)
    }

    private func tabButton(_ tab: AppTab, title: String, icon: String) -> some View {
        let isSelected = selection == tab
        return Button {
            withAnimation(Theme.flowSpring) { selection = tab }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                if isSelected {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .fixedSize()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                }
            }
            .foregroundStyle(isSelected ? .white : Theme.leafDeep)
            .padding(.vertical, 12)
            .padding(.horizontal, isSelected ? 20 : 16)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Theme.leaf)
                        .matchedGeometryEffect(id: "pill", in: glass)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.pressable(scale: 0.9))
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}

#Preview {
    RootView()
        .environment(PlantStore())
        .environment(AppRouter())
        .tint(Theme.leaf)
}
