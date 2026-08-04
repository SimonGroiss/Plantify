import SwiftUI

struct PlantDetailView: View {
    @EnvironmentObject var store: PlantStore
    @Environment(\.dismiss) private var dismiss

    let plant: Plant
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Header Image
                if let data = plant.imageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 240)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.black.opacity(0.6), .clear],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .overlay(
                            VStack(alignment: .leading) {
                                Spacer()
                                Text(plant.name)
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.white)
                                    .shadow(radius: 4)
                            }
                            .padding(),
                            alignment: .bottomLeading
                        )
                }

                // MARK: - Basic Info Card
                infoCard {
                    if let origin = plant.origin {
                        infoRow(icon: "globe.europe.africa", title: "Herkunft", value: origin)
                    }

                    if !plant.commonNames.isEmpty {
                        infoRow(icon: "tag", title: "Weitere Namen",
                                value: plant.commonNames.joined(separator: ", "))
                    }
                }

                // MARK: - Watering Recommendation
                infoCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Gieß-Empfehlung", systemImage: "drop.fill")
                            .font(.title3.bold())

                        Text("Alle \(plant.recommendedWateringInterval) Tage gießen")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        if plant.needsWaterNow {
                            Label("Heute gießen!", systemImage: "drop.fill")
                                .foregroundColor(.orange)
                                .font(.headline)
                        } else if plant.isOverdue {
                            Label("Überfällig!", systemImage: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.headline)
                        } else {
                            Label("In \(plant.daysUntilNextWatering) Tagen", systemImage: "clock")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }


                        
                        Button(action: {
                            store.markWatered(plant)
                        }) {
                            Label("Gegossen ✓", systemImage: "drop.fill")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(plant.needsWaterNow || plant.isOverdue ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(!(plant.needsWaterNow || plant.isOverdue))
                        .padding(.top, 6)
                        
                        Text("Zuletzt gegossen: \(plant.lastWatered.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)

                        Text("Nächste Bewässerung: \(plant.nextWateringDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                    }
                }

                // MARK: - Light
                infoCard {
                    sectionHeader("Licht", icon: "sun.max.fill")

                    if let min = plant.minLightLux { infoRow(title: "Min. Licht (lux)", value: "\(min)") }
                    if let max = plant.maxLightLux { infoRow(title: "Max. Licht (lux)", value: "\(max)") }
                    if let min = plant.minLightMMOL { infoRow(title: "Min. Licht (mmol)", value: "\(min)") }
                    if let max = plant.maxLightMMOL { infoRow(title: "Max. Licht (mmol)", value: "\(max)") }
                }

                // MARK: - Temperature
                infoCard {
                    sectionHeader("Temperatur", icon: "thermometer")

                    if let min = plant.minTemp { infoRow(title: "Min. Temperatur", value: "\(min)°C") }
                    if let max = plant.maxTemp { infoRow(title: "Max. Temperatur", value: "\(max)°C") }
                }

                // MARK: - Humidity
                infoCard {
                    sectionHeader("Luftfeuchtigkeit", icon: "humidity.fill")

                    if let min = plant.minEnvHumid { infoRow(title: "Min. Luftfeuchte", value: "\(min)%") }
                    if let max = plant.maxEnvHumid { infoRow(title: "Max. Luftfeuchte", value: "\(max)%") }
                }

                // MARK: - Soil
                infoCard {
                    sectionHeader("Boden", icon: "leaf.fill")

                    if let min = plant.minSoilMoist { infoRow(title: "Min. Bodenfeuchte", value: "\(min)%") }
                    if let max = plant.maxSoilMoist { infoRow(title: "Max. Bodenfeuchte", value: "\(max)%") }
                    if let min = plant.minSoilEC { infoRow(title: "Min. EC", value: "\(min)") }
                    if let max = plant.maxSoilEC { infoRow(title: "Max. EC", value: "\(max)") }
                }

                // MARK: - Notes
                infoCard {
                    sectionHeader("Notizen", icon: "square.and.pencil")

                    Text(plant.notes.isEmpty ? "Keine Notizen vorhanden." : plant.notes)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Pflanze wirklich löschen?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                deletePlant()
            }
            Button("Abbrechen", role: .cancel) { }
        }
    }

    // MARK: - Actions
    private func markAsWatered() {
        store.markWatered(plant)
    }
    

    private func deletePlant() {
        store.remove(plant)
        dismiss()
    }

    // MARK: - UI Helpers
    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.title3.bold())
    }

    private func infoRow(icon: String? = nil, title: String, value: String) -> some View {
        HStack {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(.green)
            }
            Text(title)
                .font(.body)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
