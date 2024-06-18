import SwiftUI
import SwiftData

@main
struct CassowaryExpressApp: App {
    /// The locationManager is used at startup to obtain the initial map position.
    private var locationManager = LocationManager()
    /// The busLocationManager obtains protobuf feed from the Transport of New South Wales and publishes them as Bus Entities.
    private var busLocationManager = BusLocationManager(ConfigUtility())
    /// The sharedMapData contains positioning and annotation data.
    private var sharedMapData = SharedMapData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(busLocationManager)
                .environmentObject(sharedMapData)
        }
    }
}
