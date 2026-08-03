import Foundation

// SEARCH RESPONSE
struct OPBSearchResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [OPBSearchItem]
}

struct OPBSearchItem: Codable {
    let pid: String
    let display_pid: String
    let alias: String?
    let category: String?
}

// DETAIL RESPONSE (direct object, no "data")
struct OPBPlantDetail: Codable {
    let pid: String
    let display_pid: String
    let alias: String?
    let category: String?

    let max_light_mmol: Int?
    let min_light_mmol: Int?
    let max_light_lux: Int?
    let min_light_lux: Int?

    let max_temp: Int?
    let min_temp: Int?

    let max_env_humid: Int?
    let min_env_humid: Int?

    let max_soil_moist: Int?
    let min_soil_moist: Int?

    let max_soil_ec: Int?
    let min_soil_ec: Int?

    let origin: String?
    let image_url: String?

    let common_names: [CommonName]?
}

struct CommonName: Codable {
    let name: String
    let language_code: String
}
