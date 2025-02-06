import SwiftUI
import MapKit

struct GeofenceMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var drawnCoordinates: [CLLocationCoordinate2D] = []

    var body: some View {
        ZStack {
            // Map View with Custom MKMapView Wrapper
            MapViewWrapper(region: $locationManager.region, drawnCoordinates: $drawnCoordinates)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            NotificationCenter.default.post(
                                name: .convertPointToCoordinate,
                                object: value.location
                            )
                        }
                        .onEnded { _ in
                            printCoordinates()
                        }
                )

            // Overlay Path to Show the Drawn Shape
            DrawnPathView(coordinates: drawnCoordinates)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func printCoordinates() {
        for coordinate in drawnCoordinates {
            print("Lat: \(coordinate.latitude), Lng: \(coordinate.longitude)")
        }
    }
}
