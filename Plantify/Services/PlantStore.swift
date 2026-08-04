import Foundation
import Combine
import SwiftUI

@MainActor
final class PlantStore: ObservableObject {
    @Published private(set) var plants: [Plant] = []

    // SORTIERTE LISTE FÜR DIE OVERVIEW
    var sortedPlants: [Plant] {
        plants.sorted {

            // 1. Überfällig zuerst
            if $0.isOverdue != $1.isOverdue {
                return $0.isOverdue
            }

            // 2. Heute gießen
            if $0.needsWaterNow != $1.needsWaterNow {
                return $0.needsWaterNow
            }

            // 3. Sonst nach Tagen bis zum Gießen
            return $0.daysUntilNextWatering < $1.daysUntilNextWatering
        }
    }

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("plants.json")
    }()

    init() {
        load()

        NotificationManager.shared.onMarkWatered = { [weak self] plantID in
            self?.markAsWatered(plantID: plantID)
        }
    }

    func remove(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants.remove(at: index)
        }
    }

    func markWatered(_ plant: Plant) {
        if let index = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[index].lastWatered = Date()

            // UI sofort aktualisieren
            objectWillChange.send()

            // speichern
            save()

            // neuen Reminder planen
            NotificationManager.shared.scheduleReminder(for: plants[index])
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
        save()
    }

    func markAsWatered(plantID: UUID) {
        guard let index = plants.firstIndex(where: { $0.id == plantID }) else { return }
        plants[index].lastWatered = Date()
        save()
        NotificationManager.shared.scheduleReminder(for: plants[index])
    }

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
