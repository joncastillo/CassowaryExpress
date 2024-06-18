import SwiftUI

/// This view is a composite view of interactive elements to be placed over the map. At this time, there is only one interactive element, a button at the bottom of the screen.
struct MapOverlayView: View {
    
    @EnvironmentObject var locationManager : LocationManager;
    
    var body: some View {
        
        VStack {
            Spacer()
            
            Button(action: {
                locationManager.requestLocation()
            }) {
                Text("Center on current location")
            }.padding(.all, 10.0).foregroundColor(Color.white).background(Color.black.opacity(0.75)).cornerRadius(10.0)
            .padding()
        }
    }
}

#Preview {
    MapOverlayView()
        .environmentObject(LocationManager())
}
