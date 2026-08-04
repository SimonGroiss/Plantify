import Foundation

extension Plant {
    static func fromAPI(_ item: OPBPlantDetail, imageData: Data? = nil) -> Plant {
        Plant(
            id: UUID(),

            // Basisdaten
            name: item.display_pid,
            species: item.pid,
            family: item.category,
            origin: item.origin,
            imageData: imageData,
            commonNames: item.common_names?.map { $0.name } ?? [],
            category: item.category,

            // API Sensorwerte
            minLightMMOL: item.min_light_mmol,
            maxLightMMOL: item.max_light_mmol,
            minLightLux: item.min_light_lux,
            maxLightLux: item.max_light_lux,

            minTemp: item.min_temp,
            maxTemp: item.max_temp,

            minEnvHumid: item.min_env_humid,
            maxEnvHumid: item.max_env_humid,

            minSoilMoist: item.min_soil_moist,
            maxSoilMoist: item.max_soil_moist,

            minSoilEC: item.min_soil_ec,
            maxSoilEC: item.max_soil_ec,

            // Pflegeinfos → Plantbook liefert diese NICHT
            lightInfo: nil,
            wateringInfo: nil,
            soilInfo: nil,
            fertilizationInfo: nil,
            pruningInfo: nil,

            // App-spezifische Daten
            location: "",
            light: .mittel,
            humidity: .mittel,
            wateringIntervalDays: 7,
            lastWatered: Date(),
            notes: ""
        )
    }
}
