import SwiftUI

struct ScheduleView: View {
    @Environment(PlantStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.schedulePath) {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    weekStrip
                    ForEach(ScheduleBucket.allCases, id: \.self) { bucket in
                        let plants = plants(in: bucket)
                        if !plants.isEmpty {
                            section(bucket, plants: plants)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
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
            Text("Stay on top of it 💧")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            Text("Schedule")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.leafDeep)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var weekStrip: some View {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        return HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { offset in
                let day = cal.date(byAdding: .day, value: offset, to: today)!
                let count = store.plants.filter {
                    cal.isDate($0.nextWaterDate, inSameDayAs: day)
                }.count
                dayChip(day, count: count, isToday: offset == 0)
            }
        }
    }

    private func dayChip(_ day: Date, count: Int, isToday: Bool) -> some View {
        VStack(spacing: 6) {
            Text(day.formatted(.dateTime.weekday(.abbreviated)))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isToday ? .white : .secondary)
            Text(day.formatted(.dateTime.day()))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(isToday ? .white : Theme.leafDeep)
            Circle()
                .fill(count > 0 ? (isToday ? Color.white : Theme.thirsty) : .clear)
                .frame(width: 6, height: 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            if isToday {
                RoundedRectangle(cornerRadius: 18).fill(Theme.leaf)
            }
        }
        .glassSurface(cornerRadius: 18)
        .opacity(isToday ? 1 : 0.96)
    }

    private func section(_ bucket: ScheduleBucket, plants: [Plant]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle().fill(bucket.tint).frame(width: 8, height: 8)
                Text(bucket.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.leafDeep)
                Text("\(plants.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            ForEach(plants) { plant in
                NavigationLink(value: plant) {
                    ScheduleRow(plant: plant)
                }
                .buttonStyle(.pressable(scale: 0.97))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func plants(in bucket: ScheduleBucket) -> [Plant] {
        store.byUrgency.filter { bucket.contains(daysUntilWater: $0.daysUntilWater) }
    }
}

// MARK: - Row

struct ScheduleRow: View {
    let plant: Plant

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            PlantThumbnail(url: plant.imageURL, cornerRadius: 13)
                .frame(width: 48, height: 62)
            VStack(alignment: .leading, spacing: 3) {
                Text(plant.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.leafDeep)
                    .lineLimit(1)
                Text(plant.species)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text(plant.dueShort)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(plant.status.tint)
                Image(systemName: plant.status.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(plant.status.tint)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(cornerRadius: 22)
        .contentShape(RoundedRectangle(cornerRadius: 22))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plant.name), \(plant.dueLong)")
    }
}

// MARK: - Buckets

enum ScheduleBucket: CaseIterable {
    case now, thisWeek, later

    var title: String {
        switch self {
        case .now: "Needs water now"
        case .thisWeek: "Coming up this week"
        case .later: "Later"
        }
    }

    var tint: Color {
        switch self {
        case .now: Theme.thirsty
        case .thisWeek: Theme.soon
        case .later: Theme.happy
        }
    }

    func contains(daysUntilWater days: Int) -> Bool {
        switch self {
        case .now: days <= 0
        case .thisWeek: (1...4).contains(days)
        case .later: days > 4
        }
    }
}

#Preview {
    ZStack {
        PlantPalBackground()
        ScheduleView()
            .environment(PlantStore())
            .environment(AppRouter())
    }
    .tint(Theme.leaf)
}
