//
//  StampsAppViewModel.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//

import Foundation
import SwiftUI


@Observable class StampsAppViewModel {
    var stamps: [Stamp] = []
    
    init() {
        Task {
            await loadData()
        }
    }
 
    func loadData() async {
        await fetchStampLocationsCloud()
    }
    
    func fetchStampLocationsCloud() async {
        do {
//            locations = try await FirebaseService.fetchAllDocuments(from: "airports")
        } catch {
            print("Error fetching document: \(error)")
        }
    }
 
}

