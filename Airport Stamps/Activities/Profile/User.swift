//
//  User.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//

import Foundation

struct User2: Codable {
    var firstName: String
    var lastName: String
    var stamps: [CollectedStamp]
}
