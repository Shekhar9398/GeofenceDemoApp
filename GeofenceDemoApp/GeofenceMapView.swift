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
                DrawnPathView(coordinates: drawnCoordinates, region: $locationManager.region, isCompleted: false)
            }

            // 🔹 Display all completed geofences with a faint fill
            ForEach(locationManager.geofences, id: \.self) { polygon in
                DrawnPathView(coordinates: polygon, region: $locationManager.region, isCompleted: true)
                    .overlay(
                        PolygonShape(coordinates: polygon)
                            .fill(Color.blue.opacity(0.3))
                    )
            }

            VStack {
                Spacer()
                HStack {
                    Button(action: { zoomIn() }) {
                        Image(systemName: "plus.magnifyingglass")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Button(action: { zoomOut() }) {
                        Image(systemName: "minus.magnifyingglass")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
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
    
    private func zoomIn() {
        locationManager.region.span = MKCoordinateSpan(latitudeDelta: locationManager.region.span.latitudeDelta / 2,
                                                       longitudeDelta: locationManager.region.span.longitudeDelta / 2)
    }

    private func zoomOut() {
        locationManager.region.span = MKCoordinateSpan(latitudeDelta: locationManager.region.span.latitudeDelta * 2,
                                                       longitudeDelta: locationManager.region.span.longitudeDelta * 2)
    }
}
