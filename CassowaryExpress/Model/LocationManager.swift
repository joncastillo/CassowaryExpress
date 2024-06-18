import SwiftUI
import MapKit

/// A delegate to CLLocationManager. Handles user-location access authorization and publishes the user-location once.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    /// The CLLocationManager is the object to start and stop the delivery of location-related events.
    private var locationManager = CLLocationManager()

    /// The user's location published for the views.
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Request permission to access user's location while the app is in use.
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    /// A callback function that responds to user-location updates.
    /// Usually occurs when user has moved for a certain distance but with kCLLocationAccuracyBest, the location manager tries to get the most accurate positioning data and may result in frequent updates.
    /// - Parameters:
    ///   - clLocationManager: instance of CLLocationManager calling this callback.
    ///   - clLocations: list of location updates that were cached between two locationManager calls.
    func locationManager(_ clLocationManager: CLLocationManager, didUpdateLocations clLocations: [CLLocation]) {

        if let location = clLocations.first {
            DispatchQueue.main.async {
                self.userLocation = location
                self.locationManager.stopUpdatingLocation()
            }
        }
    }

}
