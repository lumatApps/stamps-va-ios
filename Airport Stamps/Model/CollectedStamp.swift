//
//  CollectedStamp.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct CollectedStamp: Identifiable, Codable {
    var id: String
    var dateCollected: Date
    var stampPath: String // Holds the path to the document as a string

    // Lazy property to get a DocumentReference from the path
    var stamp: DocumentReference? {
        return Firestore.firestore().document(stampPath)
    }
}
