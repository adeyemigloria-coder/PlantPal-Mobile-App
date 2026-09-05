import SwiftUI

struct WateredConfirmationView: View {
    let plant: Plant

    @Environment(AppRouter.self) private var router
    @State private var animateIn = false
    @State private var ringTrim: CGFloat = 0

    var body: some View {
        ZStack {
            PlantPalBackground()

            // Floating celebratory leaves
            ForEach(Confetti.pieces) { piece in
                Image(systemName: piece.symbol)
                    .font(.system(size: piece.size))
                    .foregroundStyle(piece.color.opacity(0.7))
                    .offset(x: piece.x, y: animateIn ? piece.y : piece.y - 60)
                    .opacity(animateIn ? 0.9 : 0)
                    .rotationEffect(.degrees(animateIn ? piece.rotation : 0))
                    .animation(Theme.bouncy.delay(piece.delay), value: animateIn)
            }

            VStack(spacing: 28) {
                Spacer()

                badge

                VStack(spacing: 10) {
                    Text("All done!")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.leafDeep)
                    Text("\(plant.name) has been watered.\nGreat job keeping it happy.")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 12)
                .animation(Theme.flowSpring.delay(0.15), value: animateIn)

                nextWateringCard
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 16)
                    .animation(Theme.flowSpring.delay(0.25), value: animateIn)

                Spacer()

                buttons
                    .opacity(animateIn ? 1 : 0)
                    .animation(Theme.flowSpring.delay(0.35), value: animateIn)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 40)
        }
        .onAppear {
            animateIn = true
            withAnimation(Theme.flowSpring.delay(0.1)) { ringTrim = 1 }
        }
    }

    private var badge: some View {
        ZStack {
            Circle()
                .fill(Theme.happy.opacity(0.15))
                .frame(width: 150, height: 150)
            Circle()
                .trim(from: 0, to: ringTrim)
                .stroke(Theme.happy, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 150, height: 150)
            Image(systemName: "checkmark")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(Theme.happy)
                .scaleEffect(animateIn ? 1 : 0.4)
                .animation(Theme.bouncy.delay(0.2), value: animateIn)
        }
        .scaleEffect(animateIn ? 1 : 0.7)
        .animation(Theme.bouncy, value: animateIn)
        .sensoryFeedback(.success, trigger: animateIn)
    }

    private var nextWateringCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.leaf)
                .frame(width: 44, height: 44)
                .background(Theme.leaf.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Next watering")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text(plant.nextWaterDate.formatted(.dateTime.weekday(.wide).month().day()))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.leafDeep)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface()
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button {
                router.goToSchedule()
            } label: {
                Label("View schedule", systemImage: "calendar")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Theme.leaf, in: Capsule())
                    .foregroundStyle(.white)
                    .shadow(color: Theme.leaf.opacity(0.4), radius: 12, y: 6)
            }
            .buttonStyle(.pressable(scale: 0.95))

            Button {
                withAnimation(Theme.flowSpring) { router.wateredPlant = nil }
            } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.leafDeep)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .glassSurface(cornerRadius: 28)
            }
            .buttonStyle(.pressable(scale: 0.95))
        }
    }
}

private struct Confetti: Identifiable {
    let id = UUID()
    let symbol: String
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let rotation: Double
    let delay: Double

    static let pieces: [Confetti] = [
        Confetti(symbol: "leaf.fill", color: Theme.happy, x: -120, y: -220, size: 26, rotation: -30, delay: 0.1),
        Confetti(symbol: "drop.fill", color: Theme.leaf, x: 130, y: -180, size: 20, rotation: 25, delay: 0.2),
        Confetti(symbol: "sparkle", color: Theme.soon, x: 90, y: -260, size: 22, rotation: 15, delay: 0.15),
        Confetti(symbol: "leaf.fill", color: Theme.leaf, x: -140, y: 120, size: 22, rotation: 40, delay: 0.3),
        Confetti(symbol: "drop.fill", color: Theme.happy, x: 140, y: 90, size: 18, rotation: -20, delay: 0.25),
        Confetti(symbol: "sparkle", color: Theme.happy, x: -90, y: 260, size: 20, rotation: -15, delay: 0.35)
    ]
}

#Preview {
    WateredConfirmationView(plant: Plant.samples[0])
        .environment(AppRouter())
        .tint(Theme.leaf)
}
