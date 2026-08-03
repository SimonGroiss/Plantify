import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PlantStore
    @State private var showingAddPlant = false

    var body: some View {
        NavigationStack {
            Group {
                if store.plants.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Pflanzen",
                        systemImage: "leaf",
                        description: Text("Füge deine erste Zimmerpflanze hinzu.")
                    )
                } else {
                    List {
                        ForEach(store.plants.sorted(by: { $0.nextWateringDate < $1.nextWateringDate })) { plant in
                            NavigationLink(destination: PlantDetailView(plant: plant)) {
                                PlantRowView(plant: plant)
                            }
                        }
                    }
                }
            }

            .navigationTitle("Meine Pflanzen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                AddPlantView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PlantStore())
}
