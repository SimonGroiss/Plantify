import SwiftUI

struct PlantRowView: View {
    let plant: Plant

    var body: some View {
        HStack(spacing: 16) {

            // Bild
            if let data = plant.imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(plant.name)
                    .font(.headline)

                if plant.needsWaterNow {
                    Label("Heute gießen", systemImage: "drop.fill")
                        .foregroundColor(.orange)
                } else if plant.isOverdue {
                    Label("Überfällig!", systemImage: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                } else {
                    Label("In \(plant.daysUntilNextWatering) Tagen", systemImage: "clock")
                        .foregroundColor(.blue)
                }

            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}
