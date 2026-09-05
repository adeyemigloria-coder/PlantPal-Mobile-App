import SwiftUI

struct PlantsHomeView: View {
    @Environment(PlantStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.plantsPath) {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    attentionBanner
                    ForEach(store.byUrgency) { plant in
                        NavigationLink(value: plant) {
                            PlantRowCard(plant: plant)
                        }
                        .buttonStyle(.pressable(scale: 0.97))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120) // clear the floating tab bar
            }
            .scrollIndicators(.hidden)
            .background(Color.clear)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .navigationDestination(for: Plant.self) { plant in
                PlantDetailView(plantID: plant.id)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Good morning 🌿")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline) {
                Text("My Plants")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.leafDeep)
                Spacer()
                Text("\(store.plants.count)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.leaf)
                    .frame(width: 40, height: 40)
                    .glassSurface(cornerRadius: 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var attentionBanner: some View {
        let count = store.needsAttentionCount
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(count > 0 ? "\(count) plant\(count == 1 ? " needs" : "s need") water" : "All caught up!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.leafDeep)
                    .fixedSize(horizontal: false, vertical: true)
                Text(count > 0 ? "Tap a plant to give it a drink" : "Every plant is happy and hydrated")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 12)
            Image(systemName: count > 0 ? "drop.fill" : "checkmark.seal.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(count > 0 ? Theme.thirsty : Theme.happy)
                .frame(width: 46, height: 46)
                .background((count > 0 ? Theme.thirsty : Theme.happy).opacity(0.16), in: Circle())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface()
    }
}

// MARK: - Row card

struct PlantRowCard: View {
    let plant: Plant

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            PlantThumbnail(url: plant.imageURL, cornerRadius: 16)
                .frame(width: 66, height: 88)

            VStack(alignment: .leading, spacing: 6) {
                Text(plant.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.leafDeep)
                    .lineLimit(1)
                Text(plant.species)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                StatusPill(status: plant.status)
            }

            Spacer(minLength: 8)

            VStack(spacing: 6) {
                MoistureRing(plant: plant, size: 46, lineWidth: 5)
                Text(plant.dueShort)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(plant.status.tint)
            }
            .fixedSize()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface()
        .contentShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plant.name), \(plant.species). \(plant.status.label). \(plant.dueLong)")
    }
}

extension Plant {
    /// Short badge under the ring, e.g. "3d", "Today", "2d late".
    var dueShort: String {
        switch daysUntilWater {
        case ..<0: "\(-daysUntilWater)d late"
        case 0: "Today"
        default: "in \(daysUntilWater)d"
        }
    }

    var dueLong: String {
        switch daysUntilWater {
        case ..<0: "Watering was due \(-daysUntilWater) day\(daysUntilWater == -1 ? "" : "s") ago"
        case 0: "Water today"
        case 1: "Water tomorrow"
        default: "Water in \(daysUntilWater) days"
        }
    }
}

#Preview {
    ZStack {
        PlantPalBackground()
        PlantsHomeView()
            .environment(PlantStore())
            .environment(AppRouter())
    }
    .tint(Theme.leaf)
}
