//
//  MapSheetView.swift
//  Airport Stamps
//
//  Created by Jared William Tamulynas on 3/7/24.
//

import SwiftUI

struct MapSheetView: View {
    var stamp: Stamp
    var verifyStampAction: (Stamp) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: stamp.icon)
                    .foregroundStyle(Color.accentColor)
                
                Text(stamp.id)
                
                Spacer()
                
                Button {
                    verifyStampAction(stamp)
                } label: {
                    Label("Add Stamp", systemImage: "square.badge.plus")
                }
            }
            .font(.headline)
            
            Text(stamp.name)
                .font(.headline)
            
            if stamp.type == .airport {
                let length = Measurement(value: stamp.length, unit: UnitLength.feet)
                let formattedLength = formatMeasurement(length)
                
                let elevation = Measurement(value: stamp.elevation, unit: UnitLength.feet)
                let formattedElevation = formatMeasurement(elevation)
                
                Group {
                    Text("Region \(stamp.secondaryIdentifier.rawValue)")
                    Text("Runway Length: \(formattedLength)")
                    Text("Elevation: \(formattedElevation)")
                }
                .font(.subheadline)
            }
                
            if !stamp.notes.isEmpty {
                Text("Notes: \(stamp.notes)")
                    .font(.footnote)
                    .lineLimit(nil)
            }
            
            if !stamp.alert.isEmpty {
                Text("Alert: \(stamp.alert)".uppercased())
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .presentationDetents([.fraction(0.33)])
    }
    
    private func formatMeasurement(_ measurement: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter.string(from: measurement)
    }
}


#Preview {
    MapSheetView(stamp: Stamp.example) { _ in
        // Stamp
    }
}
