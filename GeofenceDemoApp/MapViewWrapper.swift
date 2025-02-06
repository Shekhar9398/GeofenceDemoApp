import SwiftUI
import MapKit

struct MapViewWrapper: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var drawnCoordinates: [CLLocationCoordinate2D]

    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        
        // Listen for touch conversions
        NotificationCenter.default.addObserver(forName: .convertPointToCoordinate, object: nil, queue: .main) { notification in
            if let point = notification.object as? CGPoint {
                let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                drawnCoordinates.append(coordinate)
            }
        }
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper

        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }
    }
}

// Notification for converting touch points to coordinates
extension Notification.Name {
    static let convertPointToCoordinate = Notification.Name("convertPointToCoordinate")
}
