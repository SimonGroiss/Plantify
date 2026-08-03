import SwiftUI

struct PlantDetailView: View {
    @EnvironmentObject var store: PlantStore
    @Environment(\.dismiss) private var dismiss
    @State var plant: Plant
    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                imageHeader

                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name).font(.largeTitle.bold())
                    Text(plant.species).foregroundStyle(.secondary)
                }

                wateringCard
                infoGrid

                if !plant.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notizen").font(.headline)
                        Text(plant.notes)
                    }
                }

                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Label("Pflanze löschen", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.top, 24)
            }
            .padding()
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Bearbeiten") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddPlantView()
        }
        .confirmationDialog("Diese Pflanze wirklich löschen?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Löschen", role: .destructive) {
                store.deletePlant(plant)
                dismiss()
            }
            Button("Abbrechen", role: .cancel) {}
        }
    }

    private var imageHeader: some View {
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
                    .padding(40)
                    .foregroundStyle(.green)
                    .background(Color.green.opacity(0.15))
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var wateringCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "drop.fill").foregroundStyle(.blue)
                Text(plant.isOverdue
                     ? "Gießen ist fällig!"
                     : "Nächstes Gießen: \(plant.nextWateringDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .foregroundStyle(plant.isOverdue ? .red : .primary)
            }
            Text("Zuletzt gegossen: \(plant.lastWatered.formatted(date: .abbreviated, time: .omitted))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Intervall: alle \(plant.wateringIntervalDays) Tage")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                store.markAsWatered(plantID: plant.id)
                plant.lastWatered = Date()
            } label: {
                Label("Jetzt gegossen", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var infoGrid: some View {
        VStack(spacing: 0) {
            infoRow(icon: "mappin.and.ellipse", title: "Standort", value: plant.location)
            Divider()
            infoRow(icon: plant.light.symbolName, title: "Licht", value: plant.light.rawValue)
            Divider()
            infoRow(icon: "humidity", title: "Luftfeuchte", value: plant.humidity.rawValue)
            Divider()
            infoRow(icon: "leaf", title: "Wissenschaftlicher Name", value: plant.species)

            if !plant.otherNames.isEmpty {
                Divider()
                infoRow(icon: "tag", title: "Andere Namen", value: plant.otherNames.joined(separator: ", "))
            }

            Divider()
            infoRow(icon: "number", title: "Perenual ID", value: "\(plant.perenualID)")
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon).frame(width: 24).foregroundStyle(.green)
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
        .padding()
    }
}
