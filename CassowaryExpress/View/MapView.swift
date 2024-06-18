import SwiftUI
import MapKit

struct MapView: View {

    private var DEFAULT_SPAN_DELTA = 0.01
    
    @EnvironmentObject var locationManager : LocationManager
    @EnvironmentObject var busLocationManager : BusLocationManager
    @EnvironmentObject var sharedMapData : SharedMapData
    
    @State private var lastKnownUserPosition: CLLocationCoordinate2D
    
    init(lastKnownUserPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
        self._lastKnownUserPosition = State(initialValue: lastKnownUserPosition)
    }
    
    var body: some View {
        
        Map(position: $sharedMapData.position, interactionModes: .all) {
            // Generate the annotations from `busLocationManager.busEntities`.
            ForEach(busLocationManager.busEntities, id: \.self) { busEntity in
                Annotation(busEntity.busRoute, coordinate: CLLocationCoordinate2D(latitude: busEntity.latitude, longitude: busEntity.longitude)) {
                    VStack {
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(.green)
                            .font(.title)
                            .rotationEffect(Angle(degrees: (busEntity.angleDirection - sharedMapData.currentMapHeading)), anchor: .center)
                    }
                }
            }
            
            Annotation("You", coordinate: lastKnownUserPosition) {
                VStack {
                    Image(systemName: "figure.walk.circle")
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
        }
        // Request authorization to zoom on user's location.
        .onAppear {
            locationManager.requestLocation()
        }
        // Upon receiving an update on the user's location, the map's position and region bounds are updated.
        .onReceive(locationManager.$userLocation, perform: { newLocation in
            if let newLocation = newLocation {
                let region = MKCoordinateRegion(
                    center: newLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: DEFAULT_SPAN_DELTA, longitudeDelta: DEFAULT_SPAN_DELTA)
                )

                // adjust the map's initial position to the user's location.
                DispatchQueue.main.async {
                    sharedMapData.position = .region(region)
                    lastKnownUserPosition = region.center
                }
            }
        })
        // Upon receiving a position update, update the region boundaries for new annotations.
        .onMapCameraChange { cameraContext in
            DispatchQueue.main.async {
                sharedMapData.currentMapHeading = cameraContext.camera.heading
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView() // Default position for preview
            .environmentObject(LocationManager())
            .environmentObject(BusLocationManager(ConfigUtility()))
            .environmentObject(SharedMapData())
    }
}
