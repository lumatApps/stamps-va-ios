//
//  StampLocation.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

struct StampLocation: Identifiable, Decodable {
    var id: String
    var name: String
    var type: String
    var coordinates: CLLocationCoordinate2D
    var icon: String
    var stampURL: String
    var notes: String
    var secondaryIdentifier: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case coordinates
        case icon
        case stampURL
        case notes
        case secondaryIdentifier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        
        // Decoding GeoPoint to CLLocationCoordinate2D
        let geoPoint = try container.decode(GeoPoint.self, forKey: .coordinates)
        coordinates = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        
        icon = try container.decode(String.self, forKey: .icon)
        stampURL = try container.decode(String.self, forKey: .stampURL)
        notes = try container.decode(String.self, forKey: .notes)
        secondaryIdentifier = try container.decode(String.self, forKey: .secondaryIdentifier)
    }
}
