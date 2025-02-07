import SwiftUI
import MapKit

struct DrawnPathView: View {
    var coordinates: [CLLocationCoordinate2D]
    @Binding var region: MKCoordinateRegion // Bind to the map region
    var isCompleted: Bool // Indicates when the path should be closed

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    guard let first = coordinates.first else { return }
                    let start = convertToScreenPoint(from: first, in: geometry)
                    path.move(to: start)

                    for coord in coordinates.dropFirst() {
                        let nextPoint = convertToScreenPoint(from: coord, in: geometry)
                        path.addLine(to: nextPoint)
                    }

                    if isCompleted {
                        path.closeSubpath() // ✅ Close the path when drawing is done
                    }
                }
                .stroke(Color.blue, lineWidth: 2)

                if isCompleted {
                    Path { path in
                        guard let first = coordinates.first else { return }
                        let start = convertToScreenPoint(from: first, in: geometry)
                        path.move(to: start)

                        for coord in coordinates.dropFirst() {
                            let nextPoint = convertToScreenPoint(from: coord, in: geometry)
                            path.addLine(to: nextPoint)
                        }
                        path.closeSubpath()
                    }
                    .fill(Color.blue.opacity(0.3)) // ✅ Faint fill applied after closing
                }
            }
        }
    }

    private func convertToScreenPoint(from coordinate: CLLocationCoordinate2D, in geometry: GeometryProxy) -> CGPoint {
        let mapWidth = geometry.size.width
        let mapHeight = geometry.size.height

        let latRatio = (coordinate.latitude - region.center.latitude) / region.span.latitudeDelta
        let lonRatio = (coordinate.longitude - region.center.longitude) / region.span.longitudeDelta

        let x = (lonRatio * mapWidth) + (mapWidth / 2)
        let y = (latRatio * -mapHeight) + (mapHeight / 2)

        return CGPoint(x: x, y: y)
    }
}
