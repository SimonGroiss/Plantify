import SwiftUI

struct PlantDetailView: View {
    let plant: Plant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Bild
                if let data = plant.imageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                }

                // MARK: - Grunddaten
                Group {
                    Text(plant.name)
                        .font(.largeTitle)
                        .bold()

                    if !plant.species.isEmpty {
                        Text("Art: \(plant.species)")
                    }

                    if let family = plant.family {
                        Text("Familie: \(family)")
                    }

                    if let origin = plant.origin {
                        Text("Herkunft: \(origin)")
                    }

                    if !plant.commonNames.isEmpty {
                        Text("Weitere Namen: \(plant.commonNames.joined(separator: ", "))")
                    }
                }

                Divider()

                // MARK: - API Lichtdaten
                Group {
                    Text("Licht")
                        .font(.title3)
                        .bold()

                    if let minLux = plant.minLightLux {
                        Text("Min. Licht (lux): \(minLux)")
                    }
                    if let maxLux = plant.maxLightLux {
                        Text("Max. Licht (lux): \(maxLux)")
                    }

                    if let minMMOL = plant.minLightMMOL {
                        Text("Min. Licht (mmol): \(minMMOL)")
                    }
                    if let maxMMOL = plant.maxLightMMOL {
                        Text("Max. Licht (mmol): \(maxMMOL)")
                    }
                }

                Divider()

                // MARK: - API Temperatur
                Group {
                    Text("Temperatur")
                        .font(.title3)
                        .bold()

                    if let minTemp = plant.minTemp {
                        Text("Min. Temperatur: \(minTemp)°C")
                    }
                    if let maxTemp = plant.maxTemp {
                        Text("Max. Temperatur: \(maxTemp)°C")
                    }
                }

                Divider()

                // MARK: - API Luftfeuchtigkeit
                Group {
                    Text("Luftfeuchtigkeit")
                        .font(.title3)
                        .bold()

                    if let minHum = plant.minEnvHumid {
                        Text("Min. Luftfeuchte: \(minHum)%")
                    }
                    if let maxHum = plant.maxEnvHumid {
                        Text("Max. Luftfeuchte: \(maxHum)%")
                    }
                }

                Divider()

                // MARK: - API Bodenfeuchte & EC
                Group {
                    Text("Boden")
                        .font(.title3)
                        .bold()

                    if let minMoist = plant.minSoilMoist {
                        Text("Min. Bodenfeuchte: \(minMoist)%")
                    }
                    if let maxMoist = plant.maxSoilMoist {
                        Text("Max. Bodenfeuchte: \(maxMoist)%")
                    }

                    if let minEC = plant.minSoilEC {
                        Text("Min. EC: \(minEC)")
                    }
                    if let maxEC = plant.maxSoilEC {
                        Text("Max. EC: \(maxEC)")
                    }
                }

                Divider()

                // MARK: - Pflegeinfos aus API
                Group {
                    Text("Pflegeinformationen")
                        .font(.title3)
                        .bold()

                    if let watering = plant.wateringInfo {
                        Text("Wasser: \(watering)")
                    }

                    if let light = plant.lightInfo {
                        Text("Licht: \(light)")
                    }

                    if let soil = plant.soilInfo {
                        Text("Boden: \(soil)")
                    }

                    if let fert = plant.fertilizationInfo {
                        Text("Düngung: \(fert)")
                    }

                    if let prune = plant.pruningInfo {
                        Text("Schnitt: \(prune)")
                    }
                }

                Divider()

                // MARK: - App-spezifische Daten
                Group {
                    Text("Eigene Pflegeparameter")
                        .font(.title3)
                        .bold()

                    Text("Standort: \(plant.location)")
                    Text("Lichtlevel: \(plant.light.rawValue)")
                    Text("Luftfeuchtigkeit: \(plant.humidity.rawValue)")
                    Text("Gießintervall: alle \(plant.wateringIntervalDays) Tage")

                    Text("Zuletzt gegossen: \(formattedDate(plant.lastWatered))")

                    Text("Nächste Bewässerung: \(formattedDate(plant.nextWateringDate))")
                        .foregroundColor(plant.isOverdue ? .red : .primary)
                }

                Divider()

                // MARK: - Notizen
                Group {
                    Text("Notizen")
                        .font(.title3)
                        .bold()

                    if plant.notes.isEmpty {
                        Text("Keine Notizen vorhanden.")
                            .foregroundColor(.secondary)
                    } else {
                        Text(plant.notes)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Datum formatieren
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
