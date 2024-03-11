//
//  Stamp.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import SwiftUI

struct Stamp: Identifiable, Decodable {
    var id: String
    var name: String
    var coordinates: CLLocationCoordinate2D
    var elevation: Double
    var length: Double
    var type: StampType
    var icon: String
    var notes: String
    var secondaryIdentifier: RegionType
    var alert: String
    var date: Date? // Optional date property

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
        case alert
        case date
    }

    init(id: String, name: String, latitude: Double, longitude: Double, elevation: Double, length: Double, type: StampType, icon: String, notes: String, secondaryIdentifier: RegionType, alert: String, date: Date? = Date()) {
        self.id = id
        self.name = name
        self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.elevation = elevation
        self.length = length
        self.type = type
        self.icon = icon
        self.notes = notes
        self.secondaryIdentifier = secondaryIdentifier
        self.alert = alert
        self.date = date // Initialize with current date as default
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        let geoPoint = try container.decode(GeoPoint.self, forKey: .coordinates)
        coordinates = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)

        elevation = try container.decode(Double.self, forKey: .elevation)
        length = try container.decode(Double.self, forKey: .length)
        type = try container.decode(StampType.self, forKey: .type)
        icon = try container.decode(String.self, forKey: .icon)
        notes = try container.decode(String.self, forKey: .notes)
        secondaryIdentifier = try container.decode(RegionType.self, forKey: .secondaryIdentifier)
        alert = try container.decode(String.self, forKey: .alert)

        // Handle optional 'date' decoding with a default to current date
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
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
        secondaryIdentifier: .region1,
        alert: "Weather advisory",
        date: nil // Example with no specific date, will default to current date
    )
}

enum StampType: String, Codable, CaseIterable {
    case airport = "Airport"
    case museum = "Museum"
    case seminar = "Seminar"
    case flyIn = "Fly-In"
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

extension StampType {
    var key: String {
        switch self {
        case .airport:
            return "airport"
        case .museum:
            return "museum"
        case .seminar:
            return "seminar"
        case .flyIn:
            return "flyIn"
        case .test:
            return "test"
        }
    }
}


enum StampVisibility: String, CaseIterable {
    case all = "All Stamps"
    case collected = "Collected Stamps"
    case uncollected = "Uncollected Stamps"
    case airports = "Airports"
    case museums = "Museums"
    case seminars = "Safety Seminars"
    case flyIns = "Fly-Ins"
}

extension StampVisibility {
    var icon: (systemName: String, color: Color) {
        switch self {
        case .all:
            return ("mappin", Color.primary)
        case .collected:
            return ("mappin", .green)
        case .uncollected:
            return ("mappin", .red)
        case .airports:
            return ("airplane", .secondary)
        case .museums:
            return ("building.columns", .secondary)
        case .seminars:
            return ("book.closed", .secondary)
        case .flyIns:
            return ("airplane.departure", .secondary)
        }
    }
}


enum RegionType: String, Codable, CaseIterable {
    case region1 = "1"
    case region2 = "2"
    case region3 = "3"
    case region4 = "4"
    case region5 = "5"
    case region6 = "6"
    case region7 = "7"
    case unknown // Default case for unmatched regions

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedString = try container.decode(String.self)
        
        // Attempt to initialize using a match, defaulting to 'unknown' for unmatched cases
        self = RegionType.allCases.first(where: { $0.rawValue == decodedString }) ?? .unknown
    }
}
