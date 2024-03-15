//
//  PersonalInformationSection.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/14/24.
//

import SwiftUI

struct PersonalInformationSection: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var isSaveDisabled: Bool

    var body: some View {
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

            TextField("Enter Last Name", text: Binding(
                get: { self.lastName },
                set: {
                    if $0 != self.lastName {
                        self.lastName = $0
                        self.isSaveDisabled = false
                    }
                }
            ))
        }
    }
}
