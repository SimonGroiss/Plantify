import SwiftUI

@main
struct PflanzenPflegeApp: App {
    @StateObject private var plantStore = PlantStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(plantStore)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                    plantStore.rescheduleAllReminders()
                }
        }
    }
}

