import Foundation
import Combine
import SwiftUI

@MainActor
final class PlantStore: ObservableObject {
    @Published private(set) var plants: [Plant] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("plants.json")
    }()

    init() {

        load()
        // Wenn der Nutzer die "Gegossen ✓"-Aktion in einer Benachrichtigung tippt,
        // wird das hier direkt im Store verarbeitet.
        
        NotificationManager.shared.onMarkWatered = { [weak self] plantID in
            self?.markAsWatered(plantID: plantID)
        }
    }

    func addPlant(_ plant: Plant) {
        plants.append(plant)
        save()
        NotificationManager.shared.scheduleReminder(for: plant)
    }

    func updatePlant(_ plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index] = plant
        save()
        NotificationManager.shared.scheduleReminder(for: plant)
    }

    func deletePlant(at offsets: IndexSet) {
        plants.remove(atOffsets: offsets)
    }

    func markAsWatered(plantID: UUID) {
        guard let index = plants.firstIndex(where: { $0.id == plantID }) else { return }
        plants[index].lastWatered = Date()
        save()
        NotificationManager.shared.scheduleReminder(for: plants[index])
    }

    /// Wird beim App-Start aufgerufen, um sicherzustellen, dass für alle
    /// Pflanzen aktuelle Erinnerungen geplant sind.
    func rescheduleAllReminders() {
        for plant in plants {
            NotificationManager.shared.scheduleReminder(for: plant)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([Plant].self, from: data) {
            plants = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(plants) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
