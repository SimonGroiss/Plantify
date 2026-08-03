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
                    Button("Speichern") {
                        save()
                    }
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

            let apiItem = try? await PlantAPIService().searchPlant(named: name)

            var plant: Plant

            if let item = apiItem {
                plant = Plant.fromAPI(item)

                // Bild laden (falls nicht upgrade_access)
                if let urlString = item.default_image?.medium_url,
                   !urlString.contains("upgrade_access"),
                   let url = URL(string: urlString),
                   let data = try? Data(contentsOf: url) {
                    plant.imageData = data
                }
            } else {
                plant = Plant(
                    id: UUID(),
                    name: name,
                    species: "",
                    otherNames: [],
                    perenualID: 0,
                    location: "",
                    light: .mittel,
                    humidity: .mittel,
                    wateringIntervalDays: 7,
                    lastWatered: Date(),
                    notes: "",
                    imageData: nil
                )
            }

            store.addPlant(plant)
            isLoading = false
            dismiss()
        }
    }
}
