import SwiftUI

struct PlantRowView: View {
    let plant: Plant

    var body: some View {
        HStack(spacing: 16) {
            plantImage

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.headline)

                if !plant.species.isEmpty {
                    Text(plant.species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if !plant.otherNames.isEmpty {
                    Text(plant.otherNames.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("Alle \(plant.wateringIntervalDays) Tage")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if plant.isOverdue {
                    Text("Fällig")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var plantImage: some View {
        Group {
            if let data = plant.imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.green)
                    .padding(12)
            }
        }
        .frame(width: 60, height: 60)
        .background(Color.green.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
