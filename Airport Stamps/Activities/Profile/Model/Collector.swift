//
//  User.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 2/29/24.
//

import Foundation

struct Collector: Codable {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var stamps: [CollectedStamp] = []
}
