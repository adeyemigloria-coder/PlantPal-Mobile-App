import SwiftUI

@main
struct PlantPalApp: App {
    @State private var store: PlantStore
    @State private var router: AppRouter

    init() {
        let store = PlantStore()
        let router = AppRouter()
        // Debug deep-link so screens can be previewed directly: -demoScreen <name>
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-demoScreen"), args.indices.contains(i + 1) {
            switch args[i + 1] {
            case "schedule":
                router.selectedTab = .schedule
            case "detail":
                if let p = store.plants.first(where: { $0.name == "Monty" }) { router.plantsPath = [p] }
            case "watered":
                if let p = store.plants.first(where: { $0.name == "Fig" }) { router.wateredPlant = p }
            default:
                break
            }
        }
        _store = State(initialValue: store)
        _router = State(initialValue: router)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(router)
                .tint(Theme.leaf)
        }
    }
}
