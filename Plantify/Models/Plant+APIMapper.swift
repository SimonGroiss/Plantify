import Foundation

extension Plant {
    static func fromAPI(_ item: OPBPlantDetail) -> Plant {
        Plant(
            id: UUID(),
            name: item.display_pid,
            species: item.pid,
            family: item.category,
            origin: item.origin,
            imageData: nil,
            commonNames: item.common_names?.map { $0.name } ?? [],

            location: "",
            light: .mittel,
            humidity: .mittel,
            wateringIntervalDays: 7,
            lastWatered: Date(),
            notes: ""
        )
    }
}
