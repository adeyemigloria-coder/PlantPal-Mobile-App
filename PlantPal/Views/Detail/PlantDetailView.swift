import SwiftUI

struct PlantDetailView: View {
    let plantID: UUID

    @Environment(PlantStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    @State private var didTapWater = false

    var body: some View {
        if let plant = store.plant(plantID) {
            content(for: plant)
        } else {
            ContentUnavailableView("Plant not found", systemImage: "leaf")
        }
    }

    private func content(for plant: Plant) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                hero(for: plant)

                VStack(spacing: 16) {
                    wateringCard(for: plant)
                    careGrid(for: plant)
                    notesCard(for: plant)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .background(Color.clear)
    }

    // MARK: Hero

    private func hero(for plant: Plant) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: plant.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                LinearGradient(colors: [Theme.happy.opacity(0.4), Theme.leaf.opacity(0.25)],
                               startPoint: .top, endPoint: .bottom)
                    .overlay(ProgressView().tint(.white))
            }
            .frame(height: 360)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.15), .black.opacity(0.55)],
                    startPoint: .center, endPoint: .bottom
                )
            )

            VStack(alignment: .leading, spacing: 10) {
                StatusPill(status: plant.status, onImage: true)
                Text(plant.name)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("\(plant.species) · \(plant.room)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(20)
            .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
        }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.leafDeep)
                    .frame(width: 44, height: 44)
                    .glassSurface(cornerRadius: 22)
            }
            .buttonStyle(.pressable(scale: 0.88))
            .padding(.leading, 16)
            .padding(.top, 56)
            .accessibilityLabel("Back")
        }
    }

    // MARK: Watering card + CTA

    private func wateringCard(for plant: Plant) -> some View {
        VStack(spacing: 18) {
            HStack(spacing: 16) {
                MoistureRing(plant: plant, size: 64, lineWidth: 8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.dueLong)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.leafDeep)
                    Text("Last watered \(plant.lastWatered.formatted(.dateTime.month().day()))")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Text("Every \(plant.wateringIntervalDays) days")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }

            Button {
                waterNow(plant)
            } label: {
                Label("Mark as Watered", systemImage: "drop.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Theme.leaf, in: Capsule())
                    .foregroundStyle(.white)
                    .shadow(color: Theme.leaf.opacity(0.4), radius: 12, y: 6)
            }
            .buttonStyle(.pressable(scale: 0.95))
            .sensoryFeedback(.success, trigger: didTapWater)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .glassSurface()
    }

    private func careGrid(for plant: Plant) -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            StatTile(icon: "sun.max.fill", tint: Theme.soon, title: "Light", value: plant.light)
            StatTile(icon: "calendar", tint: Theme.leaf, title: "Schedule", value: "Every \(plant.wateringIntervalDays)d")
            StatTile(icon: "circle.grid.cross.fill", tint: Theme.happy, title: "Pot", value: plant.potSize)
            StatTile(icon: "house.fill", tint: Theme.thirsty, title: "Room", value: plant.room)
        }
    }

    private func notesCard(for plant: Plant) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Care notes", systemImage: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.leaf)
            Text(plant.notes)
                .font(.system(size: 15))
                .foregroundStyle(Theme.leafDeep)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface()
    }

    private func waterNow(_ plant: Plant) {
        didTapWater.toggle()
        store.water(plant.id)
        if let updated = store.plant(plant.id) {
            router.wateredPlant = updated
        }
    }
}

/// Small square glass stat tile for the care grid.
struct StatTile: View {
    let icon: String
    let tint: Color
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.16), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.leafDeep)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(cornerRadius: 22)
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(plantID: Plant.samples[0].id)
            .environment(PlantStore())
            .environment(AppRouter())
    }
    .tint(Theme.leaf)
}
