//
//  RewardProgressView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/9/24.
//

import SwiftUI

struct RewardProgressView: View {
    var collectedStamps: [Stamp]
    
    var typeCount: (airport: Int, museum: Int, seminar: Int, flyIn: Int, test: Int) {
        var airportCount = 0
        var museumCount = 0
        var seminarCount = 0
        var flyInCount = 0
        var testCount = 0
        
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
            case .test:
                testCount += 1
            }
        }
        
        return (airport: airportCount, museum: museumCount, seminar: seminarCount, flyIn: flyInCount, test: testCount)
    }

    var body: some View {
        HStack {
            Spacer()
            RewardProgressItemView(image: "✈️", count: typeCount.airport)
            Spacer()
            RewardProgressItemView(image: "🏛️", count: typeCount.museum)
            Spacer()
            RewardProgressItemView(image: "🦺", count: typeCount.seminar)
            Spacer()
            RewardProgressItemView(image: "🛫", count: typeCount.flyIn)
            Spacer()
        }
        .padding()
    }
}

struct RewardProgressItemView: View {
    var image: String
    var count: Int
    
    var body: some View {
        VStack {
            Text(image)
                .font(.title)
            
            Text("\(count)")
                .font(.headline)
        }
    }
}


//#Preview {
//    ProgressView()
//}
