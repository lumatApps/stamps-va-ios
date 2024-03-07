//
//  MKMapItem-Extension.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/7/24.
//

import Foundation
import MapKit

extension MKMapItem {
    /// Convenience initializer to create an MKMapItem with a specific latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude of the location.
    ///   - longitude: The longitude of the location.
    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        self.init(placemark: placemark)
    }
}
