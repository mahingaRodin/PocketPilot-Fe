//
//  DatePicker.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct CustomDatePicker: View {
    let title: String
    @Binding var date: Date
    var displayedComponents: DatePickerComponents = [.date]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            SwiftUI.DatePicker(
                title,
                selection: $date,
                displayedComponents: displayedComponents
            )
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}