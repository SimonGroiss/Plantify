import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PlantStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.sortedPlants) { plant in
                    NavigationLink(destination: PlantDetailView(plant: plant)) {
                        PlantRowView(plant: plant)
                    }
                }
                .onDelete(perform: store.deletePlant)
            }
            .navigationTitle("Meine Pflanzen")
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(PlantStore())
}
