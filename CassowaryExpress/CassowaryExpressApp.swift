import SwiftUI
import SwiftData

@main
struct CassowaryExpressApp: App {
    /// The locationManager is used at startup to obtain the initial map position.
    private var locationManager = LocationManager()
    /// The sharedMapData contains positioning and annotation data.
    private var sharedMapData = SharedMapData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(sharedMapData)
        }
    }
}
