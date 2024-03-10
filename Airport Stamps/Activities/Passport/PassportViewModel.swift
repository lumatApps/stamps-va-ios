//
//  PassportViewModel.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/9/24.
//

import Foundation
import SwiftUI

@Observable class PassportViewModel {
    var rewardLevels: [RewardLevel] = []
    
    init() {
        Task {
            await loadData()
        }
    }
 
    func loadData() async {
        print("❌ rewards from cloud")
        await fetchStampLocationsCloud()
    }
    
    func fetchStampLocationsCloud() async {
        do {
            let rewards: [RewardLevel] = try await FirebaseService.fetchAllDocuments(from: "rewards")
            rewardLevels = rewards.sorted { $0.airports < $1.airports }
        } catch {
            print("Error fetching document: \(error)")
        }
    }
}
