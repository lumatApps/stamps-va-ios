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
    
    
    static func addOrUpdateDocument<T: Encodable>(to collection: String, id: String, object: T, merge: Bool = true) async throws {
        do {
            // Encode the object of type T
            let encodedObject = try Firestore.Encoder().encode(object)
            // Update the document with the provided id in the specified collection
            // If merge is true, it updates fields in the document or creates it if doesn't exist
            try await firestoreDatabase.collection(collection)
                .document(id)
                .setData(encodedObject, merge: merge)
        } catch {
            // If encoding fails or setting the data fails, throw the error
            throw error
        }
    }


    static func fetchAllDocuments<T: Decodable>(from collection: String) async throws -> [T] {
        let collectionRef = firestoreDatabase.collection(collection)
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
    

    static func fetchDocument<T: Decodable>(from collection: String, documentId: String) async throws -> T {
        let documentRef = firestoreDatabase.collection(collection).document(documentId)
        let documentSnapshot = try await documentRef.getDocument()

        guard documentSnapshot.exists else {
            throw FirestoreError.documentNotFound
        }

        do {
            // Try to directly decode the document into type T
            let decodedDocument = try documentSnapshot.data(as: T.self)
            return decodedDocument
        } catch {
            // If there's a decoding error, throw it as a FirestoreError.other
            throw FirestoreError.other(error)
        }
    }
}


enum FirestoreError: Error {
    case documentNotFound
    case other(Error) // To encapsulate other Firestore errors
}
