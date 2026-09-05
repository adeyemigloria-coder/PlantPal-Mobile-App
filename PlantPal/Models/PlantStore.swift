import SwiftUI

/// Owns the user's plants and the watering actions performed on them.
@Observable
final class PlantStore {
    var plants: [Plant]

    init(plants: [Plant] = Plant.samples) {
        self.plants = plants
    }

    func plant(_ id: UUID) -> Plant? {
        plants.first { $0.id == id }
    }

    /// Records a fresh watering for the given plant.
    func water(_ id: UUID, on date: Date = .now) {
        guard let index = plants.firstIndex(where: { $0.id == id }) else { return }
        plants[index].lastWatered = date
    }

    /// Plants sorted with the most urgent first — the scan-at-a-glance order.
    var byUrgency: [Plant] {
        plants.sorted { $0.daysUntilWater < $1.daysUntilWater }
    }

    var needsAttentionCount: Int {
        plants.filter { $0.daysUntilWater <= 0 }.count
    }
}
