import SwiftUI
import MapKit

/// This is a container for data shared between views.
class SharedMapData: ObservableObject {
    /// This is the central position of the visible map region.
    @Published var position: MapCameraPosition = .automatic
}
