//
//  CollectedStamp.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//

import Foundation
import FirebaseFirestore

struct CollectedStamp {
    var dateCollected: Date
    var stampPath: String // Use a string to hold the path to the document
    
    // Assuming `stamp` is a DocumentReference, we'll convert it to and from a String path for Codable.
    var stamp: DocumentReference? {
        Firestore.firestore().document(stampPath)
    }
}

extension CollectedStamp: Codable {
    enum CodingKeys: String, CodingKey {
        case dateCollected
        case stampPath = "stamp"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dateCollected = try container.decode(Date.self, forKey: .dateCollected)
        
        // Decode the path as a string and use it to initialize the `stamp` property
        let stampPath = try container.decode(String.self, forKey: .stampPath)
        self.stampPath = stampPath
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dateCollected, forKey: .dateCollected)
        
        // Encode the document path instead of the DocumentReference object
        try container.encode(stamp?.path, forKey: .stampPath)
    }
}
