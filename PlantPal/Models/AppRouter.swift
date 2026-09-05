import SwiftUI

enum AppTab: Hashable {
    case plants, schedule
}

/// App-wide navigation state so any screen can drive the flow
/// (e.g. the watered-confirmation screen can jump to the Schedule tab).
@Observable
final class AppRouter {
    var selectedTab: AppTab = .plants
    var plantsPath: [Plant] = []
    var schedulePath: [Plant] = []

    /// When non-nil, the celebratory "watered" confirmation is presented.
    var wateredPlant: Plant?

    func goToSchedule() {
        wateredPlant = nil
        plantsPath = []
        selectedTab = .schedule
    }
}
