//
//  RewardLevel.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/9/24.
//

import Foundation

struct RewardLevel: Codable {
    var name: String
    var prize: String
    var airports: Int
    var museums: Int
    var seminars: Int
    var flyIns: Int
}
