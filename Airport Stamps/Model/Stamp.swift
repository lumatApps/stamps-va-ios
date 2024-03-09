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
    var elevation: Double
    var length: Double
    var type: StampType
    var icon: String
    var notes: String
    var secondaryIdentifier: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coordinates
        case elevation
        case length
        case type
        case icon
        case notes
        case secondaryIdentifier
    }
    
    init(id: String, name: String, latitude: Double, longitude: Double, elevation: Double, length: Double, type: StampType, icon: String, notes: String, secondaryIdentifier: String) {
        self.id = id
        self.name = name
        self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.elevation = elevation
        self.length = length
        self.type = type
        self.icon = icon
        self.notes = notes
        self.secondaryIdentifier = secondaryIdentifier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // Decoding GeoPoint to CLLocationCoordinate2D
        let geoPoint = try container.decode(GeoPoint.self, forKey: .coordinates)
        coordinates = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        
        elevation = try container.decode(Double.self, forKey: .elevation)
        length = try container.decode(Double.self, forKey: .length)
        type = try container.decode(StampType.self, forKey: .type)
        icon = try container.decode(String.self, forKey: .icon)
        notes = try container.decode(String.self, forKey: .notes)
        secondaryIdentifier = try container.decode(String.self, forKey: .secondaryIdentifier)
    }
    
    static let example = Stamp(
        id: "HWY",
        name: "Example Airport",
        latitude: 0,
        longitude: 0,
        elevation: 1148.0,
        length: 7000.0,
        type: .airport,
        icon: "airplane",
        notes: "Region 1",
        secondaryIdentifier: "1"
    )
}

enum StampType: String, Codable, CaseIterable {
    case airport = "Airport"
    case museum = "Museum"
    case seminar = "Seminar"
    case flyIn = "FlyIn"
    case test = "Test"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedString = try container.decode(String.self).lowercased() // Convert to lowercased for comparison
        
        // Attempt to initialize using a case-insensitive match
        if let value = StampType.allCases.first(where: { $0.rawValue.lowercased() == decodedString }) {
            self = value
        } else {
            self = .test
        }
    }
}

