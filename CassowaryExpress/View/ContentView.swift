import SwiftUI

/// Main view managing a Z-stacked layout.
struct ContentView: View {
    
    var body: some View {

        ZStack {
            // A view containing a full screen map.
            MapView()
            // A view containing a button labelled "Refresh Buses".
            MapOverlayView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(BusLocationManager(ConfigUtility()))
        .environmentObject(SharedMapData())
}
