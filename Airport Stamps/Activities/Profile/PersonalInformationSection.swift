//
//  PersonalInformationSection.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/14/24.
//

import SwiftUI

struct PersonalInformationSection: View {
    @Environment(AuthManager.self) var authManager
    @Environment(StampsAppViewModel.self) var stampsAppViewModel
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var isSaveDisabled: Bool
    @FocusState private var focusedField: Field?
    
    // Alert
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var hapticFeedbackTrigger: HapticFeedbackTrigger?

    var body: some View {
        Group {
            Section("Personal Information") {
                TextField("Enter First Name", text: Binding(
                    get: { self.firstName },
                    set: {
                        if $0 != self.firstName {
                            self.firstName = $0
                            self.isSaveDisabled = false
                        }
                    }
                ))
                .focused($focusedField, equals: .firstName)
                
                TextField("Enter Last Name", text: Binding(
                    get: { self.lastName },
                    set: {
                        if $0 != self.lastName {
                            self.lastName = $0
                            self.isSaveDisabled = false
                        }
                    }
                ))
                .focused($focusedField, equals: .lastName)
            }
            
            Section {
                Button("Save") {
                    Task {
                        let saveSuccessful = await stampsAppViewModel.save(authManager: authManager)
                        
                        if saveSuccessful {
                            showAlert(for: .profileSaved)
                        } else {
                            showAlert(for: .profileNotSaved)
                        }
                    }
                    
                    isSaveDisabled = true
                    focusedField = nil
                }
                .frame(maxWidth: .infinity)
                .disabled($isSaveDisabled.wrappedValue)
                .alert(
                    alertTitle,
                    isPresented: $showingAlert
                ) {
                    Button("OK") {
                        showingAlert = false
                    }
                } message: {
                    Text(alertMessage)
                }
            }
        }
    }
    
    enum Field: Hashable {
        case firstName
        case lastName
    }
}
