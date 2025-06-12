//
//  CountdownGridView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct CountdownGridView: View {
    let countdownData: CountdownData
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Landscape layout - horizontal arrangement
                landscapeLayout
            } else {
                // Portrait layout - 2x2 grid
                portraitLayout
            }
        }
    }
    
    private var portraitLayout: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                TimeBlockView(
                    value: countdownData.formattedDisplayedDays,
                    label: countdownData.daysLabel
                )
                
                TimeBlockView(
                    value: countdownData.formattedHours,
                    label: "Hours"
                )
            }
            
            HStack(spacing: 16) {
                TimeBlockView(
                    value: countdownData.formattedMinutes,
                    label: "Minutes"
                )
                
                TimeBlockView(
                    value: countdownData.formattedSeconds,
                    label: "Seconds"
                )
            }
        }
    }
    
    private var landscapeLayout: some View {
        HStack(spacing: 12) {
            TimeBlockView(
                value: countdownData.formattedDisplayedDays,
                label: countdownData.daysLabel
            )
            
            TimeBlockView(
                value: countdownData.formattedHours,
                label: "Hours"
            )
            
            TimeBlockView(
                value: countdownData.formattedMinutes,
                label: "Minutes"
            )
            
            TimeBlockView(
                value: countdownData.formattedSeconds,
                label: "Seconds"
            )
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.48, blue: 0.91),
                Color(red: 0.46, green: 0.29, blue: 0.64)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        CountdownGridView(
            countdownData: CountdownData(
                workingDays: 42,
                totalDays: 65,
                fridays: 6,
                hours: 8,
                minutes: 23,
                seconds: 15,
                progress: 73.5
            )
        )
        .padding()
    }
}
