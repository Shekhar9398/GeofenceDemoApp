import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var isInsideGeofence = false
    @Published var geofences: [[CLLocationCoordinate2D]] = [] // Stores multiple geofences

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func addGeofencePolygon(_ coordinates: [CLLocationCoordinate2D]) {
        DispatchQueue.main.async {
            self.geofences.append(coordinates)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.region.center = location.coordinate
            self.checkIfInsideGeofence(location.coordinate)
        }
    }

    private func checkIfInsideGeofence(_ userLocation: CLLocationCoordinate2D) {
        for polygon in geofences {
            if isPointInsidePolygon(point: userLocation, polygon: polygon) {
                DispatchQueue.main.async {
                    self.isInsideGeofence = true
                }
                return
            }
        }
        DispatchQueue.main.async {
            self.isInsideGeofence = false
        }
    }

    private func isPointInsidePolygon(point: CLLocationCoordinate2D, polygon: [CLLocationCoordinate2D]) -> Bool {
        guard polygon.count > 2 else { return false }
        var isInside = false
        var j = polygon.count - 1
        for i in 0..<polygon.count {
            let xi = polygon[i].longitude, yi = polygon[i].latitude
            let xj = polygon[j].longitude, yj = polygon[j].latitude
            if ((yi > point.latitude) != (yj > point.latitude)) &&
                (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi) {
                isInside.toggle()
            }
            j = i
        }
        return isInside
    }
}
