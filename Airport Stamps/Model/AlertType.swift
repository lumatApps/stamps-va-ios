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
    case ambassaadorLevelAchieved(level: AmbassadorLevel)
    case profileSaved
    case profileNotSaved
    case verificationSubmitted
    case verificationNotSubmitted

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
        case .ambassaadorLevelAchieved:
            return "Congratulations!"
        case .profileSaved:
            return "Profiled Saved"
        case .profileNotSaved:
            return "Oops! Profiled Not Saved"
        case .verificationSubmitted:
            return "Verification Submitted"
        case .verificationNotSubmitted:
            return "Verification Not Submitted"
        }
    }
    
    var message: String {
        switch self {
        case .invalidDate:
            return "The date for this event has either not yet started or already expired."
        case .invalidLocation:
            return "Your current location is outside the stamp's designated area. Ensure you're near the specified map marker and verify your location settings."
        case .userLocationRequired:
            return "To collect your stamp, we require access to your location. Please navigate to your device's Settings, then head to 'Privacy & Security' > 'Location Services'. Here, ensure that Location Services are turned on, and then scroll down to find our app in the list. Tap on it and select the option to allow location access while using the app."
        case .stampNotLocated:
            return "We couldn't find a stamp at your current location. Make sure you're in the right place and try again."
        case .stampAlreadyCollected:
            return "Looks like you've already collected this stamp. Explore more to find new stamps!"
        case .ambassaadorLevelAchieved(let level):
            return "You've reached \(level) level!"
        case .signInRequired:
            return "You need to be signed in to collect stamps. Please sign in or create an account to continue."
        case .stampSavedSuccessfully(let stampName):
            return "Thank you for visiting \(stampName)! Your stamp has been successfully added to your collection. Check it out in your passport!"
        case .profileSaved:
            return "Your profile changes have been saved successfully."
        case .profileNotSaved:
            return "Your profile changes were unsuccessful."
        case .verificationSubmitted:
            return "We will review your passport and contact you."
        case .verificationNotSubmitted:
            return "Verification Not Submitted Placeholder"
        }
    }
}

extension MapView {
    func showAlert(for type: AlertType) {
        self.alertTitle = type.title
        self.alertMessage = type.message
        self.showingAlert = true
        let currentId = (self.hapticFeedbackTrigger?.id ?? 0) + 1
        self.hapticFeedbackTrigger = HapticFeedbackTrigger(type: type, id: currentId)
    }
}

extension ProfileView {
    func showAlert(for type: AlertType) {
        self.alertTitle = type.title
        self.alertMessage = type.message
        self.showingAlert = true
        let currentId = (self.hapticFeedbackTrigger?.id ?? 0) + 1
        self.hapticFeedbackTrigger = HapticFeedbackTrigger(type: type, id: currentId)
    }
}

extension PersonalInformationSection {
    func showAlert(for type: AlertType) {
        self.alertTitle = type.title
        self.alertMessage = type.message
        self.showingAlert = true
        let currentId = (self.hapticFeedbackTrigger?.id ?? 0) + 1
        self.hapticFeedbackTrigger = HapticFeedbackTrigger(type: type, id: currentId)
    }
}

struct HapticFeedbackTrigger: Equatable {
    let type: AlertType
    let id: Int
}
