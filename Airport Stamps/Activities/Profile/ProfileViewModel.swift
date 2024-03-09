//
//  ProfileViewModel.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/1/24.
//

import Foundation

@Observable class ProfileViewModel {
    let collectorsCollection = "collectors"
    
    var collector: Collector? {
        didSet {
            if let collector = collector {
                firstName = collector.firstName
                lastName = collector.lastName
                email = collector.email
                stamps = collector.stamps
            }
        }
    }
    
    var firstName: String = "" {
        didSet {
            informationUpdated = true
        }
    }
    var lastName: String = "" {
        didSet {
            informationUpdated = true
        }
    }
    var email: String = "" {
        didSet {
            informationUpdated = true
        }
    }
    var stamps: [CollectedStamp] = []
    var informationUpdated: Bool = false

    func loadCollector(authManager: AuthManager) async {
        guard let id = await authManager.user?.uid else {
            print("User ID is nil")
            return
        }
        
        do {
            collector = try await FirebaseService.fetchDocument(from: "collectors", documentId: id)
            // Use the document
        } catch FirestoreError.documentNotFound {
            await save(authManager: authManager)
            print("Document not found.")
        } catch FirestoreError.other(let error) {
            print("An error occurred: \(error.localizedDescription)")
        } catch {
            print("An unexpected error occurred: \(error.localizedDescription)")
        }
    }

    func addStamp(id: String) -> Bool {
        if !stamps.contains(where: { $0.id == id }) {
            let newCollectedStamp = CollectedStamp(id: id, dateCollected: Date.now, stampPath: "stamps/\(id)")
            stamps.append(newCollectedStamp)
            return true
        }
        
        return false
    }
    
    func save(authManager: AuthManager) async {
        do {
            if let id = await authManager.user?.uid {
                let savedCollector = Collector(firstName: firstName, lastName: lastName, email: email, stamps: stamps)
                try await FirebaseService.addOrUpdateDocument(to: collectorsCollection, id: id, object: savedCollector)
                collector = savedCollector
            }
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    func signOut(authManager: AuthManager) async {
        do {
            try await authManager.signOut()
            reset()
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    
    func reset() {
        collector = nil
        firstName = ""
        lastName = ""
        email = ""
        stamps = []
    }
}
