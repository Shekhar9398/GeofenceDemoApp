import SwiftUI
import MapKit

struct GeofenceMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var drawnCoordinates: [CLLocationCoordinate2D] = []
    @State private var showAlert = false
    @State private var isDrawing = false

    var body: some View {
        ZStack {
            MapViewWrapper(region: $locationManager.region, drawnCoordinates: $drawnCoordinates)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if isDrawing {
                                NotificationCenter.default.post(
                                    name: .convertPointToCoordinate,
                                    object: value.location
                                )
                            }
                        }
                        .onEnded { _ in
                            if isDrawing {
                                locationManager.addGeofencePolygon(drawnCoordinates)
                                drawnCoordinates.removeAll()  // Clear after adding
                                isDrawing = false
                            }
                        }
                )

            // 🔹 Show the real-time drawing while dragging
            if isDrawing {
                DrawnPathView(coordinates: drawnCoordinates)
            }

            // 🔹 Display all completed geofences with a faint fill
            ForEach(locationManager.geofences, id: \.self) { polygon in
                DrawnPathView(coordinates: polygon)
                    .overlay(
                        PolygonShape(coordinates: polygon)
                            .fill(Color.blue.opacity(0.3))
                    )
            }

            VStack {
                Spacer()
                Button(action: { isDrawing.toggle() }) {
                    Text(isDrawing ? "Stop Drawing" : "Draw Geofence")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Geofence Alert"), message: Text("You entered a geofenced area!"), dismissButton: .default(Text("OK")))
        }
        .onChange(of: locationManager.isInsideGeofence) { isInside in
            if isInside {
                showAlert = true
            }
        }
    }
}
