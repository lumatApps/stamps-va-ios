//
//  AlertType.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/12/24.
//

import Foundation

enum AlertType: Equatable {
    case invalidDate
    case invalidLocation
    case userLocationRequired
    case stampNotLocated
    case stampAlreadyCollected
    case signInRequired
    case stampSavedSuccessfully(stampName: String)

    var title: String {
        switch self {
        case .invalidDate, .invalidLocation, .stampAlreadyCollected:
            return "Oops! Stamp Not Saved"
        case .userLocationRequired:
            return "Location Permissions Needed"
        case .stampNotLocated:
            return "Oops! Stamp Not Found"
        case .signInRequired:
            return "Action Required: Sign In"
        case .stampSavedSuccessfully:
            return "Stamp Collected!"
        }
    }
    
    var message: String {
        switch self {
        case .invalidDate:
            return "The date for this event has either not yet started or already expired."
        case .invalidLocation:
            return "Your current location is outside the stamp's designated area. Ensure you're near the specified map marker and verify your location settings."
        case .userLocationRequired:
            return "We need access to your location to confirm the stamp. Please enable location services in your settings."
        case .stampNotLocated:
            return "We couldn't find a stamp at your current location. Make sure you're in the right place and try again."
        case .stampAlreadyCollected:
            return "Looks like you've already collected this stamp. Explore more to find new stamps!"
        case .signInRequired:
            return "You need to be signed in to collect stamps. Please sign in or create an account to continue."
        case .stampSavedSuccessfully(let stampName):
            return "Thank you for visiting \(stampName)! Your stamp has been successfully added to your collection. Check it out in your passport!"
        }
    }
}

extension MapView {
    func showAlert(for type: AlertType) {
        self.alertTitle = type.title
        self.alertMessage = type.message
        let currentId = (self.hapticFeedbackTrigger?.id ?? 0) + 1
        self.hapticFeedbackTrigger = HapticFeedbackTrigger(type: type, id: currentId)
        
        switch type {
        case .signInRequired:
            self.showingAuthAlert = true
        default:
            // All other types use the general alert
            self.showingAlert = true
        }
    }
}


struct HapticFeedbackTrigger: Equatable {
    let type: AlertType
    let id: Int
}
