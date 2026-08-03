import Foundation

extension Plant {
    static func fromAPI(_ item: PlantAPIItem) -> Plant {
        Plant(
            id: UUID(),
            name: item.common_name ?? "",
            species: item.scientific_name?.first ?? "",
            otherNames: item.other_name ?? [],
            perenualID: item.id ?? 0,
            location: "",
            light: .mittel,
            humidity: .mittel,
            wateringIntervalDays: 7,
            lastWatered: Date(),
            notes: "",
            imageData: nil
        )
    }
}
