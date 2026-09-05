import SwiftUI

/// Remote Unsplash image with a graceful loading + failure state.
struct PlantThumbnail: View {
    let url: URL
    var cornerRadius: CGFloat = 18

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.35))) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                placeholder(icon: "leaf")
            case .empty:
                placeholder(icon: nil)
                    .overlay(ProgressView().tint(Theme.leaf))
            @unknown default:
                placeholder(icon: "leaf")
            }
        }
        .clipShape(.rect(cornerRadius: cornerRadius))
    }

    private func placeholder(icon: String?) -> some View {
        ZStack {
            LinearGradient(
                colors: [Theme.happy.opacity(0.35), Theme.leaf.opacity(0.2)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            if let icon {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

/// Compact status chip — colour + icon + label make watering state scannable.
struct StatusPill: View {
    let status: WateringStatus
    /// When shown over a photo, the tinted hues are hard to read, so render the
    /// pill white for legibility across every status.
    var onImage: Bool = false

    private var useWhite: Bool { onImage }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.icon)
                .font(.system(size: 11, weight: .bold))
            Text(status.label)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(useWhite ? Color.white : status.tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            (useWhite ? Color.white : status.tint).opacity(useWhite ? 0.28 : 0.16),
            in: Capsule()
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(status.label)
    }
}

/// Circular moisture indicator — full ring means it's time to water.
struct MoistureRing: View {
    let plant: Plant
    var size: CGFloat = 52
    var lineWidth: CGFloat = 6

    var body: some View {
        ZStack {
            Circle()
                .stroke(plant.status.tint.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.02, plant.moisture))
                .stroke(
                    plant.status.tint,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(Theme.flowSpring, value: plant.moisture)
            Image(systemName: "drop.fill")
                .font(.system(size: size * 0.28, weight: .bold))
                .foregroundStyle(plant.status.tint)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
