import SwiftUI
import MapKit

struct DrawnPathView: View {
    var coordinates: [CLLocationCoordinate2D]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !coordinates.isEmpty else { return }
                
                let start = convertToScreenPoint(from: coordinates.first!, in: geometry)
                path.move(to: start)
                
                for coord in coordinates.dropFirst() {
                    let nextPoint = convertToScreenPoint(from: coord, in: geometry)
                    path.addLine(to: nextPoint)
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
    
    private func convertToScreenPoint(from coordinate: CLLocationCoordinate2D, in geometry: GeometryProxy) -> CGPoint {
        let latOffset = coordinate.latitude - 37.7749
        let lonOffset = coordinate.longitude - (-122.4194)
        
        let x = (lonOffset * 5000) + geometry.size.width / 2
        let y = (latOffset * -5000) + geometry.size.height / 2
        
        return CGPoint(x: x, y: y)
    }
}
