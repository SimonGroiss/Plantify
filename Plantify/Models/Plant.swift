import Foundation

struct Plant: Identifiable, Codable {
    let id: UUID

    // Basisdaten
    var name: String
    var species: String
    var family: String?
    var origin: String?
    var imageData: Data?
    var commonNames: [String]
    var category: String?

    // API Sensorwerte
    var minLightMMOL: Int?
    var maxLightMMOL: Int?
    var minLightLux: Int?
    var maxLightLux: Int?

    var minTemp: Int?
    var maxTemp: Int?

    var minEnvHumid: Int?
    var maxEnvHumid: Int?

    var minSoilMoist: Int?
    var maxSoilMoist: Int?

    var minSoilEC: Int?
    var maxSoilEC: Int?

    // API Pflegeinfos
    var lightInfo: String?
    var wateringInfo: String?
    var soilInfo: String?
    var fertilizationInfo: String?
    var pruningInfo: String?

    // App-spezifische Daten
    var location: String
    var light: LightLevel
    var humidity: HumidityLevel
    var wateringIntervalDays: Int
    var lastWatered: Date
    var notes: String

    // Berechnete Werte
    var nextWateringDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: recommendedWateringInterval,
            to: lastWatered
        ) ?? Date()
    }
    var canBeWatered: Bool {
        isOverdue || needsWaterNow
    }


    var isWateringButtonDisabled: Bool {
        !canBeWatered
    }
    
    var isOverdue: Bool {
        nextWateringDate < Calendar.current.startOfDay(for: Date())
    }

    var needsWaterNow: Bool {
        Calendar.current.isDateInToday(nextWateringDate)
    }

    var daysUntilNextWatering: Int {
        let start = Calendar.current.startOfDay(for: Date())
        let target = Calendar.current.startOfDay(for: nextWateringDate)
        let diff = Calendar.current.dateComponents([.day], from: start, to: target).day ?? 0
        return max(diff, 0)
    }

}

enum LightLevel: String, Codable {
    case direkteSonne = "Direkte Sonne"
    case mittel = "Mittel"
    case wenig = "Wenig"
}

enum HumidityLevel: String, Codable {
    case niedrig = "Niedrig"
    case mittel = "Mittel"
    case hoch = "Hoch"
}

extension Plant {

    var recommendedWateringInterval: Int {
        var interval = 7

        // Kategorie / Familie
        if let family = family?.lowercased() {
            if family.contains("solanaceae") {
                interval -= 6
            } else if family.contains("araceae") {
                interval += 0
            } else if family.contains("hedera") {
                interval -= 2
            } else if family.contains("dracaena") {
                interval += 1
            } else if family.contains("cactus") || family.contains("cactaceae") {
                interval += 10
            } else if family.contains("succulent") {
                interval += 7
            } else if family.contains("pteridaceae") || family.contains("fern") {
                interval -= 3
            }
        }

        // Bodenfeuchte
        if let min = minSoilMoist, let max = maxSoilMoist {
            let soilScore = (min + max) / 2
            switch soilScore {
            case ..<20: interval -= 3
            case 20..<40: interval -= 1
            case 40..<60: interval += 1
            default: interval += 3
            }
        }

        // Temperatur
        if let min = minTemp, let max = maxTemp {
            let avg = (min + max) / 2
            switch avg {
            case ..<12: interval += 4
            case 12..<20: interval += 2
            case 20..<28: break
            default: interval -= 2
            }
        }

        // Luftfeuchtigkeit
        if let minHum = minEnvHumid {
            switch minHum {
            case ..<30: interval -= 2
            case 30..<60: break
            default: interval += 1
            }
        }

        // Licht
        if let maxLux = maxLightLux {
            switch maxLux {
            case ..<1000: interval += 3
            case 1000..<5000: interval += 1
            case 5000..<20000: interval -= 1
            default: interval -= 2
            }
        }

        return max(1, min(interval, 21))
    }
}
