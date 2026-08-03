import Foundation

struct PlantAPIResponse: Codable {
    let data: [PlantAPIItem]?
    let error: String?
    let message: String?
}

struct PlantAPIItem: Codable {
    let id: Int?
    let common_name: String?
    let scientific_name: [String]?
    let other_name: [String]?
    let default_image: PlantAPIImage?
}

struct PlantAPIImage: Codable {
    let medium_url: String?
}
