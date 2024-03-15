//
//  ProgramInformationSection.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/14/24.
//

import SwiftUI

struct ProgramInformationSection: View {
    var body: some View {
        Section("Program Information") {
            Link("Ambassadors Program",
                 destination: URL(string: "https://doav.virginia.gov/programs-and-services/ambassadors-program/")!
            )
            
            Link("Virginia Department of Aviation",
                 destination: URL(string: "https://doav.virginia.gov/")!
            )
            
            Link(destination: URL(string: "telprompt://8042363624")!) {
                Label("Contact Us", systemImage: "phone.fill")
            }
        }
    }
}
