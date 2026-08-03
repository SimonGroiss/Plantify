import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PlantStore
    @State private var showingAddPlant = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.plants) { plant in
                    NavigationLink(destination: PlantDetailView(plant: plant)) {
                        PlantRowView(plant: plant)
                    }
                }
                .onDelete(perform: store.deletePlant)   // jetzt korrekt
            }
            .navigationTitle("Meine Pflanzen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                AddPlantView()
                    .environmentObject(store)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PlantStore())
}
