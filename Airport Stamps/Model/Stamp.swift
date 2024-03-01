//
//  Stamp.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//


import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

struct Stamp: Identifiable, Decodable {
    var id: String
    var name: String
    var coordinates: CLLocationCoordinate2D
    var type: String
    var icon: String
    var stampURL: String
    var notes: String
    var secondaryIdentifier: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coordinates
        case type
        case icon
        case stampURL
        case notes
        case secondaryIdentifier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // Decoding GeoPoint to CLLocationCoordinate2D
        let geoPoint = try container.decode(GeoPoint.self, forKey: .coordinates)
        coordinates = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        
        type = try container.decode(String.self, forKey: .type)
        icon = try container.decode(String.self, forKey: .icon)
        stampURL = try container.decode(String.self, forKey: .stampURL)
        notes = try container.decode(String.self, forKey: .notes)
        secondaryIdentifier = try container.decode(String.self, forKey: .secondaryIdentifier)
    }
}