
import SwiftUI
import CoreLocation
import MapKit

struct PolygonShape: Shape {
    var coordinates: [CLLocationCoordinate2D]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !coordinates.isEmpty else { return path }
        
        let start = convertToScreenPoint(from: coordinates.first!, in: rect)
        path.move(to: start)
        
        for coord in coordinates.dropFirst() {
            let nextPoint = convertToScreenPoint(from: coord, in: rect)
            path.addLine(to: nextPoint)
        }
        path.closeSubpath()
        
        return path
    }
    
    private func convertToScreenPoint(from coordinate: CLLocationCoordinate2D, in rect: CGRect) -> CGPoint {
        let latOffset = coordinate.latitude - 37.7749
        let lonOffset = coordinate.longitude - (-122.4194)
        
        let x = (lonOffset * 5000) + rect.width / 2
        let y = (latOffset * -5000) + rect.height / 2
        
        return CGPoint(x: x, y: y)
    }
}
