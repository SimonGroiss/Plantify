import Foundation
import UserNotifications
import Combine 

/// Kümmert sich um Anfragen der Benachrichtigungsberechtigung sowie
/// das Planen / Löschen einzelner Gieß-Erinnerungen pro Pflanze.
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    @Published var dummy: Bool = false
    

    /// Wird aufgerufen, wenn der Nutzer in einer Benachrichtigung auf
    /// "Gegossen ✓" tippt, ohne die App zu öffnen.
    var onMarkWatered: ((UUID) -> Void)?

    private let markWateredActionID = "MARK_WATERED_ACTION"
    private let wateringCategoryID = "WATERING_REMINDER"

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerCategories()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Fehler bei Benachrichtigungsberechtigung: \(error)")
            }
        }
    }

    private func registerCategories() {
        let markWatered = UNNotificationAction(
            identifier: markWateredActionID,
            title: "Gegossen ✓",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: wateringCategoryID,
            actions: [markWatered],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    /// Plant (bzw. ersetzt) die Erinnerung für eine Pflanze anhand ihres
    /// Gieß-Intervalls. Die Erinnerung wird morgens um 9 Uhr am Fälligkeitstag ausgelöst.
    func scheduleReminder(for plant: Plant) {
        cancelReminder(for: plant.id)

        let content = UNMutableNotificationContent()
        content.title = "Zeit zum Gießen 💧"
        content.body = "\(plant.name) braucht wahrscheinlich Wasser."
        content.sound = .default
        content.categoryIdentifier = wateringCategoryID
        content.userInfo = ["plantID": plant.id.uuidString]

        var triggerDate = plant.nextWateringDate
        var components = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = 9
        components.minute = 0
        if let adjusted = Calendar.current.date(from: components) {
            triggerDate = adjusted
        }

        let request: UNNotificationRequest
        if triggerDate > Date() {
            let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            request = UNNotificationRequest(identifier: plant.id.uuidString, content: content, trigger: trigger)
        } else {
            // Falls die Pflanze bereits überfällig ist: kurzfristig erinnern
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            request = UNNotificationRequest(identifier: plant.id.uuidString, content: content, trigger: trigger)
        }

        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for plantID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plantID.uuidString])
    }

    // Benachrichtigung auch anzeigen, wenn die App gerade im Vordergrund ist
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .list]
    }

    // Reaktion auf Tap auf die Benachrichtigung bzw. auf die "Gegossen ✓"-Aktion
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let idString = response.notification.request.content.userInfo["plantID"] as? String,
              let plantID = UUID(uuidString: idString) else { return }

        if response.actionIdentifier == markWateredActionID {
            await MainActor.run {
                onMarkWatered?(plantID)
            }
        }
    }
}
