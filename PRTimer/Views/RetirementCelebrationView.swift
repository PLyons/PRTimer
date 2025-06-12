//
//  RetirementCelebrationView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct RetirementCelebrationView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 100))
                .scaleEffect(1.2)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: UUID()
                )
            
            Text(userSettings.fullCelebrationTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
            
            Text("Congratulations! 🎊")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    RetirementCelebrationView()
        .environmentObject(UserSettings.shared)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.48, blue: 0.91),
                    Color(red: 0.46, green: 0.29, blue: 0.64)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .padding()
}