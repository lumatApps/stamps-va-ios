//
//  AmbassadorLevel.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/12/24.
//

import Foundation
import SwiftUI

enum AmbassadorLevel: String, Codable, Comparable {
    case none, bronze, silver, gold
    
    var title: String {
        switch self {
        case .none:
            return "N/A"
        case .bronze:
            return "Bronze"
        case .silver:
            return "Silver"
        case .gold:
            return "Gold"
        }
    }
    
    var color: Color {
        switch self {
        case .none:
            return .secondary
        case .bronze:
            return .bronze
        case .silver:
            return .silver
        case .gold:
            return .gold
        }
    }
    
    static func < (lhs: AmbassadorLevel, rhs: AmbassadorLevel) -> Bool {
        switch (lhs, rhs) {
        case (.none, _) where rhs != .none:
            return true
        case (.bronze, .silver), (.bronze, .gold), (.silver, .gold):
            return true
        case (_, _) where lhs == rhs:
            return false
        default:
            return false
        }
    }
}
