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
    
    var stamps: [Stamp] = [] {
        didSet {
            print("Stamps: \(stamps.count)")
            updateFilteredStamps()
            updateCollectedStamps()
            updateStampTypeCount()
        }
    }
    
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
            updateFilteredStamps()
            updateCollectedStamps()
        }
    }
    
    var collectedStampsDictionary: [String: Stamp] {
        return stamps.reduce(into: [:]) { (result, stamp) in
            if checkCollected(stamp: stamp) {
                result[stamp.id] = stamp
            }
        }
    }
    
    var filteredStamps: [Stamp] = []
    
    var collectedStamps: [Stamp] = [] {
        didSet {
            updateCollectedStampTypeCount()
            updateStampRegionCount()
        }
    }
    
    var stampTypeCount: (airport: Int, museum: Int, seminar: Int, flyIn: Int) = (0, 0, 0, 0)
    
    var collectedStampTypeCount: (airport: Int, museum: Int, seminar: Int, flyIn: Int) = (0, 0, 0, 0) {
        didSet {
            updateAmbassadorLevel()
        }
    }
    
    var stampRegionCount: (region1: Int, region2: Int, region3: Int, region4: Int, region5: Int, region6: Int, region7: Int) = (0, 0, 0, 0, 0, 0, 0)
    
    var ambassadorLevel: (status: AmbassadorLevel, targetStatus: AmbassadorLevel, airports: Bool, museums: Bool, seminars: Bool, flyIns: Bool, regions: Bool, reward: Reward, targetReward: Reward) = (.none, .bronze, false, false, false, false, false, Reward.example, Reward.example) {
        didSet {
            print("SET LEVEL \(ambassadorLevel)")
            selectedRewardLevel = ambassadorLevel.reward
        }
    }
    
    // MARK: - INITS
    
    deinit {
        print("DE INIT")
        detachListeners()
    }
    
    
    
    // MARK: - MAP VIEW
    
    var position: MapCameraPosition = .automatic
    var stampVisibility: StampVisibility = .all {
        didSet {
            updateFilteredStamps()
        }
    }
    
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
    
    func verifyStampDate(stamp: Stamp) -> Bool? {
        guard let startDate = stamp.startDate, let endDate = stamp.endDate else {
            print("NIL")
            return nil
        }
        
        if startDate <= endDate {
            print("IF")
            let currentDate = Date()
            let oneHourBuffer = TimeInterval(60 * 60) // 1 hour in seconds
            
            let startDateWithBuffer = startDate.addingTimeInterval(-oneHourBuffer)
            let endDateWithBuffer = endDate.addingTimeInterval(oneHourBuffer)
            
            return currentDate >= startDateWithBuffer && currentDate <= endDateWithBuffer
        } else {
            print("FALSE")
            return false
        }
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
    
    var rewardLevels: [Reward] = [] {
        didSet {
            updateAmbassadorLevel()
            print("updated reward levels")
        }
    }
    var selectedRewardLevel: Reward = Reward.example
    
    
    
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
    
    func save(authManager: AuthManager) async {
        do {
            if let id = authManager.user?.uid {
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
        stamps.removeAll()
        firstName = ""
        lastName = ""
        email = ""
        detachListeners()
    }
    
    
    // MARK: - Utility Functions
    
    // Relies on collectedStampReferences and stamps
    private func updateFilteredStamps() -> Bool {
        filteredStamps = stamps.filter { stamp in
            switch stampVisibility {
            case .all:
                return true
            case .collected:
                return collectedStampReferences.contains(where: { $0.id == stamp.id })
            case .uncollected:
                return !collectedStampReferences.contains(where: { $0.id == stamp.id })
            case .airports:
                return stamp.type == .airport
            case .museums:
                return stamp.type == .museum
            case .seminars:
                return stamp.type == .seminar
            case .flyIns:
                return stamp.type == .flyIn
            }
        }
        
        return true
    }
    
    // Relies on collectedStampReferences and stamps
    private func updateCollectedStamps() -> Bool  {
        collectedStamps = collectedStampReferences.compactMap { reference in
            stamps.first { $0.id == reference.id }
        }
        
        return true
    }
    
    // Relies on stamps
    private func updateStampTypeCount() -> Bool {
        var airportCount = 0
        var museumCount = 0
        var seminarCount = 0
        var flyInCount = 0
        
        for stamp in stamps {
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
                break
            }
        }
        
        stampTypeCount = (airport: airportCount, museum: museumCount, seminar: seminarCount, flyIn: flyInCount)
        return true
    }
    
    // Relies on collectedStamps
    private func updateCollectedStampTypeCount() -> Bool {
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
                break
            }
        }
        
        collectedStampTypeCount = (airport: airportCount, museum: museumCount, seminar: seminarCount, flyIn: flyInCount)
        return true
    }
    
    // Relies on collectedStamps
    private func updateStampRegionCount() -> Bool {
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
                break
            }
        }
        
        stampRegionCount = (region1: region1Count, region2: region2Count, region3: region3Count, region4: region4Count, region5: region5Count, region6: region6Count, region7: region7Count)
        return true
    }
    
    // Relies on rewardLevels, stampRegionCount, collectedStampTypeCount
    func updateAmbassadorLevel() {
        print("UPDATE AMBASSADOR")
        
        guard rewardLevels.count >= 3 else {
            return
        }
        
        // Assuming rewards are ordered from lowest to highest (Bronze, Silver, Gold)
        let bronze = rewardLevels[0]
        let silver = rewardLevels[1]
        let gold = rewardLevels[2]
        
        let hasVisitedAllRegions = stampRegionCount.region1 > 0 &&
            stampRegionCount.region2 > 0 &&
            stampRegionCount.region3 > 0 &&
            stampRegionCount.region4 > 0 &&
            stampRegionCount.region5 > 0 &&
            stampRegionCount.region6 > 0 &&
            stampRegionCount.region7 > 0
        
        let achievements = (
            airports: collectedStampTypeCount.airport,
            museums: collectedStampTypeCount.museum,
            seminars: collectedStampTypeCount.seminar,
            flyIns: collectedStampTypeCount.flyIn,
            regions: hasVisitedAllRegions
        )
        
        func hasMetRequirements(for level: Reward) -> Bool {
            let hasMetAirports = achievements.airports >= level.airports
            let hasMetMuseums = achievements.museums >= level.museums
            let hasMetSeminars = achievements.seminars >= level.seminars
            let hasMetFlyIns = achievements.flyIns >= level.flyIns || achievements.museums >= level.museums + 1
            
            return hasMetAirports && hasMetMuseums && hasMetSeminars && hasMetFlyIns && hasVisitedAllRegions
        }
        
        var status: AmbassadorLevel = .none
        var targetStatus: AmbassadorLevel = .bronze
        var reward = bronze
        var targetReward = silver
        
        if hasMetRequirements(for: gold) {
            status = .gold
            targetStatus = .gold
            reward = gold
            targetReward = gold
        } else if hasMetRequirements(for: silver) {
            status = .silver
            targetStatus = .gold
            reward = silver
            targetReward = gold
        } else if hasMetRequirements(for: bronze) {
            status = .bronze
            targetStatus = .silver
            reward = bronze
            targetReward = silver
        }
        
        ambassadorLevel = (
            status: status,
            targetStatus: targetStatus,
            airports: achievements.airports >= bronze.airports,
            museums: achievements.museums >= bronze.museums,
            seminars: achievements.seminars >= bronze.seminars,
            flyIns: achievements.flyIns >= bronze.flyIns || achievements.museums >= bronze.museums + 1,
            regions: achievements.regions,
            reward: reward,
            targetReward: targetReward
        )
    }
    
//    func updateAmbassadorLevel() {
//        let rewards = rewardLevels
//        
//        guard rewards.count >= 3 else {
//            return
//        }
//        
//        let bronze = rewards[0]
//        let silver = rewards[1]
//        let gold = rewards[2]
//        
//        let hasVisitedAllRegions = stampRegionCount.region1 > 0 && stampRegionCount.region2 > 0 && stampRegionCount.region3 > 0 && stampRegionCount.region4 > 0 && stampRegionCount.region5 > 0 && stampRegionCount.region6 > 0 && stampRegionCount.region7 > 0
//        
//        var airportsMet = collectedStampTypeCount.airport >= bronze.airports
//        let museumsMet = collectedStampTypeCount.museum >= bronze.museums
//        let seminarsMet = collectedStampTypeCount.seminar >= bronze.seminars
//        let flyInsMet = collectedStampTypeCount.flyIn >= bronze.flyIns || collectedStampTypeCount.museum >= bronze.museums + 1
//        let regionsMet = hasVisitedAllRegions
//        
//        
//        var status: AmbassadorLevel
//        var targetStatus: AmbassadorLevel
//        var reward = bronze
//        var targetReward = bronze
//        
//        if !museumsMet || !seminarsMet || !flyInsMet || !regionsMet || !airportsMet {
//            status = .none
//            targetStatus = .bronze
//        } else if collectedStampTypeCount.airport < silver.airports {
//            status = .bronze
//            targetStatus = .silver
//            airportsMet = true
//            reward = bronze
//            targetReward = silver
//        } else if collectedStampTypeCount.airport < gold.airports {
//            status = .silver
//            targetStatus = .gold
//            airportsMet = true
//            reward = silver
//            targetReward = gold
//        } else {
//            status = .gold
//            targetStatus = .gold
//            airportsMet = true
//            reward = gold
//            targetReward = gold
//        }
//        
//        ambassadorLevel = (status, targetStatus, airportsMet, museumsMet, seminarsMet, flyInsMet, regionsMet, reward, targetReward)
//    }
    
    
    
    // MARK: - Listeners
    
    var stampsListener: ListenerRegistration?
    var collectorListener: ListenerRegistration?
    var rewardsListener: ListenerRegistration?
    
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
            
            let levels: [Reward] = documents.compactMap { document in
                do {
                    return try document.data(as: Reward.self)
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
    
    func attachListeners(authManager: AuthManager) async {
        guard let id = authManager.user?.uid else {
            print("User ID is nil")
            return
        }
        
        if authManager.authState == .signedIn {
            if collectorListener == nil {
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
        }
        
        if stampsListener == nil {
            attachStampsListener(from: stampsCollection)
        }
        
        if rewardsListener == nil {
            attachRewardsListener(from: rewardsCollection)
        }
        
        position = .automatic
    }
    
    func detachListeners() {
        stampsListener?.remove()
        stampsListener = nil
        collectorListener?.remove()
        collectorListener = nil
        rewardsListener?.remove()
        rewardsListener = nil
    }
}














//
//
//
//import SwiftUI
//import Firebase
//import MapKit
//
//@Observable class StampsAppViewModel {
//    
//    // MARK: - CONSTANTS
//    
//    let stampsCollection = "stamps"
//    let collectorsCollection = "collectors"
//    let rewardsCollection = "rewards"
//    
//    
//    
//    // MARK: - COMMON VARIABLES
//    
//    var stamps: [Stamp] = []
//    var collector: Collector? {
//        didSet {
//            if let collector = collector {
//                firstName = collector.firstName
//                lastName = collector.lastName
//                email = collector.email
//                collectedStampReferences = collector.stamps
//            }
//        }
//    }
//    var collectedStampReferences: [CollectedStamp] = [] {
//        didSet {
//            print("Collected Stamps Updated: \(collectedStampReferences.count)")
//        }
//    }
//    
//    var filteredStamps: [Stamp] {
//        switch stampVisibility {
//        case .all:
//            return stamps
//        case .collected:
//            return collectedStamps
//        case .uncollected:
//            return stamps.filter { stamp in
//                !collectedStampReferences.contains(where: { profileStamp in
//                    profileStamp.id == stamp.id
//                })
//            }
//        case .airports:
//            return stamps.filter { stamp in
//                stamp.type == .airport
//            }
//        case .museums:
//            return stamps.filter { stamp in
//                stamp.type == .museum
//            }
//        case .seminars:
//            return stamps.filter { stamp in
//                stamp.type == .seminar
//            }
//        case .flyIns:
//            return stamps.filter { stamp in
//                stamp.type == .flyIn
//            }
//        }
//    }
//    
//    var collectedStamps: [Stamp] {
//        return collectedStampReferences.compactMap { reference -> Stamp? in
//            return collectedStampsDictionary[reference.id]
//        }
//    }
//    
//    var collectedStampsDictionary: [String: Stamp] {
//        return stamps.reduce(into: [:]) { (result, stamp) in
//            if checkCollected(stamp: stamp) {
//                result[stamp.id] = stamp
//            }
//        }
//    }
//    
//    var stampTypeCount: (airport: Int, museum: Int, seminar: Int, flyIn: Int) {
//        var airportCount = 0
//        var museumCount = 0
//        var seminarCount = 0
//        var flyInCount = 0
//        
//        for stamp in stamps {
//            switch stamp.type {
//            case .airport:
//                airportCount += 1
//            case .museum:
//                museumCount += 1
//            case .seminar:
//                seminarCount += 1
//            case .flyIn:
//                flyInCount += 1
//            default:
//                print("no type found")
//            }
//        }
//        
//        return (airport: airportCount, museum: museumCount, seminar: seminarCount, flyIn: flyInCount)
//    }
//    
//    var collectedStampTypeCount: (airport: Int, museum: Int, seminar: Int, flyIn: Int) {
//        var airportCount = 0
//        var museumCount = 0
//        var seminarCount = 0
//        var flyInCount = 0
//        
//        for stamp in collectedStamps {
//            switch stamp.type {
//            case .airport:
//                airportCount += 1
//            case .museum:
//                museumCount += 1
//            case .seminar:
//                seminarCount += 1
//            case .flyIn:
//                flyInCount += 1
//            default:
//                print("no type found")
//            }
//        }
//        
//        return (airport: airportCount, museum: museumCount, seminar: seminarCount, flyIn: flyInCount)
//    }
//    
//    var stampRegionCount: (region1: Int, region2: Int, region3: Int, region4: Int, region5: Int, region6: Int, region7: Int) {
//        var region1Count = 0
//        var region2Count = 0
//        var region3Count = 0
//        var region4Count = 0
//        var region5Count = 0
//        var region6Count = 0
//        var region7Count = 0
//        
//        for stamp in collectedStamps {
//            switch stamp.secondaryIdentifier {
//            case .region1:
//                region1Count += 1
//            case .region2:
//                region2Count += 1
//            case .region3:
//                region3Count += 1
//            case .region4:
//                region4Count += 1
//            case .region5:
//                region5Count += 1
//            case .region6:
//                region6Count += 1
//            case .region7:
//                region7Count += 1
//            default:
//                print("Region out of range")
//            }
//        }
//        
//        return (region1: region1Count, region2: region2Count, region3: region3Count, region4: region4Count, region5: region5Count, region6: region6Count, region7: region7Count)
//    }
//    
//    var ambassadorLevel: (status: AmbassadorLevel, targetStatus: AmbassadorLevel, airports: Bool, museums: Bool, seminars: Bool, flyIns: Bool, regions: Bool, reward: Reward, targetReward: Reward) {
//        let rewards = rewardLevels
//        
//        guard rewards.count >= 3 else {
//            return (.none, .bronze, false, false, false, false, false, Reward.example, Reward.example)
//        }
//        
//        let bronze = rewards[0]
//        let silver = rewards[1]
//        let gold = rewards[2]
//        
//        let hasVisitedAllRegions = stampRegionCount.region1 > 0 && stampRegionCount.region2 > 0 && stampRegionCount.region3 > 0 && stampRegionCount.region4 > 0 && stampRegionCount.region5 > 0 && stampRegionCount.region6 > 0 && stampRegionCount.region7 > 0
//        
//        var airportsMet = collectedStampTypeCount.airport >= bronze.airports
//        let museumsMet = collectedStampTypeCount.museum >= bronze.museums
//        let seminarsMet = collectedStampTypeCount.seminar >= bronze.seminars
//        let flyInsMet = collectedStampTypeCount.flyIn >= bronze.flyIns || collectedStampTypeCount.museum >= bronze.museums + 1
//        let regionsMet = hasVisitedAllRegions
//        
//        
//        var status: AmbassadorLevel
//        var targetStatus: AmbassadorLevel
//        var reward = bronze
//        var targetReward = bronze
//        
//        if !museumsMet || !seminarsMet || !flyInsMet || !regionsMet || !airportsMet {
//            status = .none
//            targetStatus = .bronze
//        } else if collectedStampTypeCount.airport < silver.airports {
//            status = .bronze
//            targetStatus = .silver
//            airportsMet = true
//            reward = bronze
//            targetReward = silver
//        } else if collectedStampTypeCount.airport < gold.airports {
//            status = .silver
//            targetStatus = .gold
//            airportsMet = true
//            reward = silver
//            targetReward = gold
//        } else {
//            status = .gold
//            targetStatus = .gold
//            airportsMet = true
//            reward = gold
//            targetReward = gold
//        }
//        
//        return (status, targetStatus, airportsMet, museumsMet, seminarsMet, flyInsMet, regionsMet, reward, targetReward)
//    }
//    
//    
//    
//    // MARK: - INITS
//    
//    deinit {
//        print("DE INIT")
//        detachListeners()
//    }
//    
//    
//    
//    // MARK: - MAP VIEW
//    
//    var position: MapCameraPosition = .automatic
//    var stampVisibility: StampVisibility = .all
//    
//    func checkCollected(stamp: Stamp) -> Bool {
//        collectedStampReferences.contains { $0.id == stamp.id }
//    }
//    
//    func verifyUserLocation(locationManager: LocationManager, stamp: Stamp) -> Bool {
//        let stampLocation = CLLocation(latitude: stamp.coordinates.latitude, longitude: stamp.coordinates.longitude)
//        
//        if let userLocation = locationManager.location {
//            let distance = userLocation.distance(from: stampLocation)
//            return distance < 2500
//        }
//        
//        return false
//    }
//    
//    func findNearbyStamp(locationManager: LocationManager) -> Stamp? {
//        guard let userLocation = locationManager.location else { return nil }
//        
//        for stamp in stamps {
//            let stampLocation = CLLocation(latitude: stamp.coordinates.latitude, longitude: stamp.coordinates.longitude)
//            let distance = userLocation.distance(from: stampLocation)
//            
//            if distance < 2500 {
//                return stamp
//            }
//        }
//        
//        // If no stamp is within 2500 meters, return nil
//        return nil
//    }
//    
//    func verifyStampDate(stamp: Stamp) -> Bool? {
//        guard let startDate = stamp.startDate, let endDate = stamp.endDate else {
//            print("NIL")
//            return nil
//        }
//        
//        if startDate <= endDate {
//            print("IF")
//            let currentDate = Date()
//            let oneHourBuffer = TimeInterval(60 * 60) // 1 hour in seconds
//            
//            let startDateWithBuffer = startDate.addingTimeInterval(-oneHourBuffer)
//            let endDateWithBuffer = endDate.addingTimeInterval(oneHourBuffer)
//            
//            return currentDate >= startDateWithBuffer && currentDate <= endDateWithBuffer
//        } else {
//            print("FALSE")
//            return false
//        }
//    }
//    
//    func addStamp(id: String) -> Bool {
//        if !collectedStamps.contains(where: { $0.id == id }) {
//            let newCollectedStamp = CollectedStamp(id: id, dateCollected: Date.now, stampPath: "stamps/\(id)")
//            collectedStampReferences.append(newCollectedStamp)
//            return true
//        }
//        
//        return false
//    }
//    
//    // Navigates user to specified coordinate in the map view
//    func goTo(item: MKMapItem) {
//        withAnimation {
//            position = .item(item)
//        }
//    }
//    
//    func setStampVisibility(to stampVisibility: StampVisibility) {
//        self.stampVisibility = stampVisibility
//    }
//    
//    
//    
//    // MARK: - PASSPORT VIEW
//    
//    var rewardLevels: [Reward] = []
//    
//    
//    
//    // MARK: - PROFILE VIEW
//    
//    var firstName: String = "" {
//        didSet {
//            informationUpdated = true
//        }
//    }
//    var lastName: String = "" {
//        didSet {
//            informationUpdated = true
//        }
//    }
//    var email: String = "" {
//        didSet {
//            informationUpdated = true
//        }
//    }
//    var informationUpdated: Bool = false
//    
//    func save(authManager: AuthManager) async {
//        do {
//            if let id = authManager.user?.uid {
//                let savedCollector = Collector(firstName: firstName, lastName: lastName, email: email, stamps: collectedStampReferences)
//                try await FirebaseService.addOrUpdateDocument(to: collectorsCollection, id: id, object: savedCollector)
//                try await attachCollectorListener(collection: collectorsCollection, documentId: id)
//            }
//        }
//        catch {
//            print("Error: \(error)")
//        }
//    }
//    
//    func signOut(authManager: AuthManager) async {
//        do {
//            try await authManager.signOut()
//            reset()
//        }
//        catch {
//            print("Error: \(error)")
//        }
//    }
//    
//    
//    func reset() {
//        collector = nil
//        stamps.removeAll()
//        firstName = ""
//        lastName = ""
//        email = ""
//        detachListeners()
//    }
//    
//    
//    
//    // MARK: - Listeners
//    
//    var stampsListener: ListenerRegistration?
//    var collectorListener: ListenerRegistration?
//    var rewardsListener: ListenerRegistration?
//    
//    func attachStampsListener(from collection: String) {
//        let collectionRef = FirebaseService.firestoreDatabase.collection(collection)
//        stampsListener = collectionRef.addSnapshotListener { [weak self] querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("Error fetching documents: \(String(describing: error))")
//                return
//            }
//            
//            let stamps: [Stamp] = documents.compactMap { document in
//                do {
//                    return try document.data(as: Stamp.self)
//                } catch {
//                    print("Error decoding document into Stamp: \(error)")
//                    return nil
//                }
//            }
//            
//            DispatchQueue.main.async {
//                self?.stamps = stamps
//            }
//        }
//    }
//    
//    func attachRewardsListener(from collection: String) {
//        let collectionRef = FirebaseService.firestoreDatabase.collection(collection)
//        rewardsListener = collectionRef.addSnapshotListener { [weak self] querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("Error fetching documents: \(String(describing: error))")
//                return
//            }
//            
//            let levels: [Reward] = documents.compactMap { document in
//                do {
//                    return try document.data(as: Reward.self)
//                } catch {
//                    print("Error decoding document into Reward: \(error)")
//                    return nil
//                }
//            }
//            
//            DispatchQueue.main.async {
//                self?.rewardLevels = levels.sorted { $0.airports < $1.airports }
//            }
//        }
//    }
//    
//    func attachCollectorListener(collection: String, documentId: String) async throws {
//        let documentRef = FirebaseService.firestoreDatabase.collection(collection).document(documentId)
//        
//        let documentSnapshot = try await documentRef.getDocument()
//        guard documentSnapshot.exists else {
//            throw FirestoreError.documentNotFound
//        }
//        
//        collectorListener = documentRef.addSnapshotListener { [weak self] documentSnapshot, error in
//            guard let snapshot = documentSnapshot, snapshot.exists, let self = self else {
//                print("Error fetching document: \(String(describing: error))")
//                return
//            }
//            
//            do {
//                let collector = try snapshot.data(as: Collector.self)
//                DispatchQueue.main.async {
//                    self.collector = collector
//                }
//            } catch let error {
//                print("Error decoding document: \(error)")
//            }
//        }
//    }
//    
//    func attachListeners(authManager: AuthManager) async {
//        guard let id = authManager.user?.uid else {
//            print("User ID is nil")
//            return
//        }
//        
//        if authManager.authState == .signedIn {
//            if collectorListener == nil {
//                do {
//                    try await attachCollectorListener(collection: collectorsCollection, documentId: id)
//                } catch FirestoreError.documentNotFound {
//                    await save(authManager: authManager)
//                    print("Document not found, saving new collector.")
//                } catch FirestoreError.other(let error) {
//                    print("An error occurred: \(error.localizedDescription)")
//                } catch {
//                    print("An unexpected error occurred: \(error.localizedDescription)")
//                }
//            }
//        }
//        
//        if stampsListener == nil {
//            attachStampsListener(from: stampsCollection)
//        }
//        
//        if rewardsListener == nil {
//            attachRewardsListener(from: rewardsCollection)
//        }
//        
//        position = .automatic
//    }
//    
//    func detachListeners() {
//        stampsListener?.remove()
//        stampsListener = nil
//        collectorListener?.remove()
//        collectorListener = nil
//        rewardsListener?.remove()
//        rewardsListener = nil
//    }
//}
