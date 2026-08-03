import Foundation

struct Plant: Identifiable, Codable {
    let id: UUID
    var name: String
    var species: String
    var otherNames: [String]
    var perenualID: Int
    var location: String
    var light: LightLevel
    var humidity: HumidityLevel
    var wateringIntervalDays: Int
    var lastWatered: Date
    var notes: String
    var imageData: Data?        // API-Bild wird hier gespeichert

    var isOverdue: Bool {
        nextWateringDate < Date()
    }

    var nextWateringDate: Date {
        Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: lastWatered) ?? Date()
    }
}

enum LightLevel: String, Codable {
    case direkteSonne = "Direkte Sonne"
    case mittel = "Mittel"
    case wenig = "Wenig"

    var symbolName: String {
        switch self {
        case .direkteSonne: return "sun.max.fill"
        case .mittel: return "sun.max"
        case .wenig: return "cloud"
        }
    }
}

enum HumidityLevel: String, Codable {
    case niedrig = "Niedrig"
    case mittel = "Mittel"
    case hoch = "Hoch"
}
