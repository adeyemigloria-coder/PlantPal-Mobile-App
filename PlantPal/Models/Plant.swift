import SwiftUI

/// A single plant the user is caring for.
struct Plant: Identifiable, Hashable {
    let id: UUID
    var name: String
    var species: String
    var imageURL: URL
    var room: String
    var wateringIntervalDays: Int
    var lastWatered: Date
    var light: String
    var potSize: String
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        species: String,
        imageURL: URL,
        room: String,
        wateringIntervalDays: Int,
        lastWatered: Date,
        light: String,
        potSize: String,
        notes: String
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.imageURL = imageURL
        self.room = room
        self.wateringIntervalDays = wateringIntervalDays
        self.lastWatered = lastWatered
        self.light = light
        self.potSize = potSize
        self.notes = notes
    }
}

// MARK: - Watering math

extension Plant {
    var nextWaterDate: Date {
        Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: lastWatered) ?? lastWatered
    }

    /// Whole days until the next watering (negative = overdue).
    var daysUntilWater: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        let due = cal.startOfDay(for: nextWaterDate)
        return cal.dateComponents([.day], from: start, to: due).day ?? 0
    }

    var status: WateringStatus {
        switch daysUntilWater {
        case ..<0: return .overdue
        case 0: return .today
        case 1...2: return .soon
        default: return .healthy
        }
    }

    /// 0 = just watered, 1 = fully due. Drives the progress ring.
    var moisture: Double {
        let elapsed = Date.now.timeIntervalSince(lastWatered)
        let span = Double(wateringIntervalDays) * 86_400
        guard span > 0 else { return 1 }
        return min(max(elapsed / span, 0), 1)
    }
}

// MARK: - Status

enum WateringStatus {
    case overdue, today, soon, healthy

    var label: String {
        switch self {
        case .overdue: "Overdue"
        case .today: "Water today"
        case .soon: "Due soon"
        case .healthy: "Healthy"
        }
    }

    var tint: Color {
        switch self {
        case .overdue: Theme.thirsty
        case .today: Theme.thirsty
        case .soon: Theme.soon
        case .healthy: Theme.happy
        }
    }

    var icon: String {
        switch self {
        case .overdue: "drop.triangle.fill"
        case .today: "drop.fill"
        case .soon: "drop"
        case .healthy: "leaf.fill"
        }
    }
}

// MARK: - Sample data (Unsplash imagery)

extension Plant {
    static func unsplash(_ id: String) -> URL {
        URL(string: "https://images.unsplash.com/\(id)?w=800&q=80&auto=format&fit=crop")!
    }

    static let samples: [Plant] = [
        Plant(
            name: "Fig",
            species: "Fiddle Leaf Fig",
            imageURL: unsplash("photo-1512428813834-c702c7702b78"),
            room: "Living Room",
            wateringIntervalDays: 7,
            lastWatered: daysAgo(7),
            light: "Bright, indirect",
            potSize: "10\" ceramic",
            notes: "Rotate weekly so it grows evenly toward the window."
        ),
        Plant(
            name: "Monty",
            species: "Monstera Deliciosa",
            imageURL: unsplash("photo-1614594975525-e45190c55d0b"),
            room: "Living Room",
            wateringIntervalDays: 9,
            lastWatered: daysAgo(3),
            light: "Medium, indirect",
            potSize: "12\" terracotta",
            notes: "Wipe the leaves monthly to keep them glossy."
        ),
        Plant(
            name: "Snek",
            species: "Snake Plant",
            imageURL: unsplash("photo-1593482892290-f54927ae1bb6"),
            room: "Bedroom",
            wateringIntervalDays: 18,
            lastWatered: daysAgo(4),
            light: "Low to bright",
            potSize: "8\" stoneware",
            notes: "Nearly unkillable — let the soil dry fully between drinks."
        ),
        Plant(
            name: "Aloe",
            species: "Aloe Vera",
            imageURL: unsplash("photo-1596547609652-9cf5d8d76921"),
            room: "Windowsill",
            wateringIntervalDays: 14,
            lastWatered: daysAgo(13),
            light: "Bright, direct",
            potSize: "5\" clay",
            notes: "Loves sun. Water deeply but infrequently."
        ),
        Plant(
            name: "Ferny",
            species: "Boston Fern",
            imageURL: unsplash("photo-1597305877032-0668b3c6413a"),
            room: "Bathroom",
            wateringIntervalDays: 4,
            lastWatered: daysAgo(2),
            light: "Medium, indirect",
            potSize: "8\" hanging",
            notes: "Thrives on humidity — mist between waterings."
        )
    ]

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
    }
}
