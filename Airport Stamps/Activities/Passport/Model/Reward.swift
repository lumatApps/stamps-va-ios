//
//  Reward.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/9/24.
//

import Foundation

struct Reward: Codable, Hashable, Comparable {
    var name: String
    var prize: String
    var airports: Int
    var museums: Int
    var seminars: Int
    var flyIns: Int
    var ambassadorLevel: AmbassadorLevel
    
    static let example = Reward(name: "", prize: "", airports: 0, museums: 0, seminars: 0, flyIns: 0, ambassadorLevel: AmbassadorLevel.bronze)
    
    static func < (lhs: Reward, rhs: Reward) -> Bool {
        return lhs.airports < rhs.airports
    }
}
