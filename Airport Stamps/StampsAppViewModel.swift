//
//  StampsAppViewModel.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/10/24.
//

import Foundation
import SwiftUI
import Firebase
import MapKit

@Observable class StampsAppViewModel {
    
    // MARK: - CONSTANTS
    
    let stampsCollection = "stamps"
    let collectorsCollection = "collectors"
    let rewardsCollection = "rewards"
    
    
    
    // MARK: - COMMON VARIABLES
    
    var stamps: [Stamp] = []
    var collector: Collector? {
        didSet {
            if let collector = collector {
                firstName = collector.firstName
                lastName = collector.lastName
                email = collector.email
                collectedStampReferences = collector.stamps
            }
        }
    }
    var collectedStampReferences: [CollectedStamp] = [] {
        didSet {
            print("Collected Stamps Updated: \(collectedStampReferences.count)")
        }
    }
    
    var filteredStamps: [Stamp] {
        switch stampVisibility {
        case .all:
            return stamps
        case .collected:
            return collectedStamps
        case .uncollected:
            return stamps.filter { stamp in
                !collectedStampReferences.contains(where: { profileStamp in
                    profileStamp.id == stamp.id
                })
            }
        case .airports:
            return stamps.filter { stamp in
                stamp.type == .airport
            }
        case .museums:
            return stamps.filter { stamp in
                stamp.type == .museum
            }
        case .seminars:
            return stamps.filter { stamp in
                stamp.type == .seminar
            }
        case .flyIns:
            return stamps.filter { stamp in
                stamp.type == .flyIn
            }
        }
    }
    
    var collectedStamps: [Stamp] {
        return stamps.filter { stamp in
            checkCollected(stamp: stamp)
        }
    }
    
    var collectedStampsDictionary: [String: Stamp] {
        return stamps.reduce(into: [:]) { (result, stamp) in
            if checkCollected(stamp: stamp) {
                result[stamp.id] = stamp
            }
        }
    }

    
    var stampTypeCount: (airport: Int, museum: Int, seminar: Int, flyIn: Int) {
        var airportCount = 0
        var museumCount = 0
        var seminarCount = 0
        var flyInCount = 0
        
        for stamp in collectedStamps {
            switch stamp.type {
            case .airport:
                airportCount += 1
            case .museum:
                museumCount += 1
            case .seminar:
                seminarCount += 1
            case .flyIn:
                flyInCount += 1
            default:
                print("no type found")
            }
        }
        
        return (airport: airportCount, museum: museumCount, seminar: seminarCount, flyIn: flyInCount)
    }
    
    var stampRegionCount: (region1: Int, region2: Int, region3: Int, region4: Int, region5: Int, region6: Int, region7: Int) {
        var region1Count = 0
        var region2Count = 0
        var region3Count = 0
        var region4Count = 0
        var region5Count = 0
        var region6Count = 0
        var region7Count = 0
        
        for stamp in collectedStamps {
            switch stamp.secondaryIdentifier {
            case .region1:
                region1Count += 1
            case .region2:
                region2Count += 1
            case .region3:
                region3Count += 1
            case .region4:
                region4Count += 1
            case .region5:
                region5Count += 1
            case .region6:
                region6Count += 1
            case .region7:
                region7Count += 1
            default:
                print("Region out of range")
            }
        }
        
        return (region1: region1Count, region2: region2Count, region3: region3Count, region4: region4Count, region5: region5Count, region6: region6Count, region7: region7Count)
    }
    


    // MARK: - INITS
    
    init() {
        attachStampsListener(from: stampsCollection)
        attachRewardsListener(from: rewardsCollection)
    }
    
    deinit {
        detachListeners()
    }
    
    
    
    // MARK: - MAP VIEW
    
    var position: MapCameraPosition = .automatic
    var stampVisibility: StampVisibility = .all
    
    func checkCollected(stamp: Stamp) -> Bool {
        collectedStampReferences.contains { $0.id == stamp.id }
    }
    
    func verifyUserLocation(locationManager: LocationManager, stamp: Stamp) -> Bool {
        let stampLocation = CLLocation(latitude: stamp.coordinates.latitude, longitude: stamp.coordinates.longitude)
        
        if let userLocation = locationManager.location {
            let distance = userLocation.distance(from: stampLocation)
            return distance < 2500
        }
        
        return false
    }

    func findNearbyStamp(locationManager: LocationManager) -> Stamp? {
        guard let userLocation = locationManager.location else { return nil }
        
        for stamp in stamps {
            let stampLocation = CLLocation(latitude: stamp.coordinates.latitude, longitude: stamp.coordinates.longitude)
            let distance = userLocation.distance(from: stampLocation)
            
            if distance < 2500 {
                return stamp
            }
        }
        
        // If no stamp is within 2500 meters, return nil
        return nil
    }
    
    func addStamp(id: String) -> Bool {
        if !collectedStamps.contains(where: { $0.id == id }) {
            let newCollectedStamp = CollectedStamp(id: id, dateCollected: Date.now, stampPath: "stamps/\(id)")
            collectedStampReferences.append(newCollectedStamp)
            return true
        }
        
        return false
    }
    
    // Navigates user to specified coordinate in the map view
    func goTo(item: MKMapItem) {
        withAnimation {
            position = .item(item)
        }
    }
    
    func setStampVisibility(to stampVisibility: StampVisibility) {
        self.stampVisibility = stampVisibility
    }
    
    
    
    // MARK: - PASSPORT VIEW
    
    var rewardLevels: [RewardLevel] = []
    
    
    
    // MARK: - PROFILE VIEW
    
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
    var informationUpdated: Bool = false
    
    
    func loadCollector(authManager: AuthManager) async {
        guard let id = await authManager.user?.uid else {
            print("User ID is nil")
            return
        }
        
        do {
            try await attachCollectorListener(collection: collectorsCollection, documentId: id)
        } catch FirestoreError.documentNotFound {
            await save(authManager: authManager)
            print("Document not found, saving new collector.")
        } catch FirestoreError.other(let error) {
            print("An error occurred: \(error.localizedDescription)")
        } catch {
            print("An unexpected error occurred: \(error.localizedDescription)")
        }
    }

    func save(authManager: AuthManager) async {
        do {
            if let id = await authManager.user?.uid {
                let savedCollector = Collector(firstName: firstName, lastName: lastName, email: email, stamps: collectedStampReferences)
                try await FirebaseService.addOrUpdateDocument(to: collectorsCollection, id: id, object: savedCollector)
                try await attachCollectorListener(collection: collectorsCollection, documentId: id)
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
        stamps = []
    }
    
    
    
    // MARK: - Listeners

    private var stampsListener: ListenerRegistration?
    private var collectorListener: ListenerRegistration?
    private var rewardsListener: ListenerRegistration?
    
    func attachStampsListener(from collection: String) {
        let collectionRef = FirebaseService.firestoreDatabase.collection(collection)
        stampsListener = collectionRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }

            let stamps: [Stamp] = documents.compactMap { document in
                do {
                    return try document.data(as: Stamp.self)
                } catch {
                    print("Error decoding document into Stamp: \(error)")
                    return nil
                }
            }

            DispatchQueue.main.async {
                self?.stamps = stamps
            }
        }
    }
    
    func attachRewardsListener(from collection: String) {
        let collectionRef = FirebaseService.firestoreDatabase.collection(collection)
        rewardsListener = collectionRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }

            let levels: [RewardLevel] = documents.compactMap { document in
                do {
                    return try document.data(as: RewardLevel.self)
                } catch {
                    print("Error decoding document into Reward: \(error)")
                    return nil
                }
            }

            DispatchQueue.main.async {
                self?.rewardLevels = levels.sorted { $0.airports < $1.airports }
            }
        }
    }
    
    func attachCollectorListener(collection: String, documentId: String) async throws {
        let documentRef = FirebaseService.firestoreDatabase.collection(collection).document(documentId)
        
        let documentSnapshot = try await documentRef.getDocument()
        guard documentSnapshot.exists else {
            throw FirestoreError.documentNotFound
        }

        collectorListener = documentRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let snapshot = documentSnapshot, snapshot.exists, let self = self else {
                print("Error fetching document: \(String(describing: error))")
                return
            }

            do {
                let collector = try snapshot.data(as: Collector.self)
                DispatchQueue.main.async {
                    self.collector = collector
                }
            } catch let error {
                print("Error decoding document: \(error)")
            }
        }
    }

    
    func detachListeners() {
        stampsListener?.remove()
        collectorListener?.remove()
        rewardsListener?.remove()
    }
}
