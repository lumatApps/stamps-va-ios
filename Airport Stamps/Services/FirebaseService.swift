//
//  FirebaseService.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/28/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseDatabase

enum FirebaseService {
    static let firestoreDatabase = Firestore.firestore()

    static func fetchAllDocuments<T: Decodable>(from collection: String) async throws -> [T] {
        let collectionRef = Firestore.firestore().collection(collection)
        let querySnapshot = try await collectionRef.getDocuments()
        
        var results: [T] = []
        
        for document in querySnapshot.documents {
            do {
                // Try to decode the document into type T
                let decodedObject = try document.data(as: T.self)
                results.append(decodedObject)
            } catch {
                // Handle the error. For example, you could print or log the error
                print("Error decoding document: \(error)")
            }
        }
        
        return results
    }

    
    static func fetchDocument<T: Decodable>(from collection: String, documentId: String, decodeKey: String) async throws -> T {
        let documentRef = firestoreDatabase.collection(collection).document(documentId)
        let documentSnapshot = try await documentRef.getDocument()

        guard let documentData = documentSnapshot.data(), let data = documentData[decodeKey] else {
            throw NSError(domain: "FirebaseServiceError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or key not found in document"])
        }

        // Convert the specific part of the document data to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        // Decode the JSON data to the specified Decodable type T
        let result = try JSONDecoder().decode(T.self, from: jsonData)
        return result
    }
}
