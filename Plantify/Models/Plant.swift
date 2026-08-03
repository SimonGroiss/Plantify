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

    // API Pflegeinfos (optional)
    var lightInfo: String?
    var wateringInfo: String?
    var soilInfo: String?
    var fertilizationInfo: String?
    var pruningInfo: String?

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

    // App-spezifische Daten
    var location: String
    var light: LightLevel
    var humidity: HumidityLevel
    var wateringIntervalDays: Int
    var lastWatered: Date
    var notes: String

    // Berechnete Werte
    var isOverdue: Bool {
        nextWateringDate < Date()
    }

    var nextWateringDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: wateringIntervalDays,
            to: lastWatered
        ) ?? Date()
    }
}

// Lichtlevel
enum LightLevel: String, Codable {
    case direkteSonne = "Direkte Sonne"
    case mittel = "Mittel"
    case wenig = "Wenig"
}

// Luftfeuchtigkeit
enum HumidityLevel: String, Codable {
    case niedrig = "Niedrig"
    case mittel = "Mittel"
    case hoch = "Hoch"
}
