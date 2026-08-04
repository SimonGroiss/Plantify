import SwiftUI

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: PlantStore

    @State private var name: String = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Pflanze") {
                    TextField("Name (z. B. Monstera)", text: $name)
                }

                if isLoading {
                    ProgressView("Lade Pflanzendaten…")
                }
            }
            .navigationTitle("Pflanze hinzufügen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }

    private func save() {
        Task {
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

            isLoading = true

            // API liefert jetzt direkt Plant
            let apiPlant = try? await PlantAPIService().searchPlant(named: name)

            var plant: Plant

            if let apiPlant {
                plant = apiPlant
            } else {
                plant = Plant(
                    id: UUID(),
                    name: name,
                    species: "",
                    family: nil,
                    origin: nil,
                    imageData: nil,
                    commonNames: [],
                    location: "",
                    light: .mittel,
                    humidity: .mittel,
                    wateringIntervalDays: 7,
                    lastWatered: Date(),
                    notes: ""
                )
            }

            store.addPlant(plant)
            NotificationManager.shared.scheduleReminder(for: plant)
            isLoading = false
            dismiss()
        }
    }

}
