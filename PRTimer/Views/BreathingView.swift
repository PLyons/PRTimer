//
//  BreathingView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct BreathingView<Content: View>: View {
    let content: Content
    let duration: Double
    let scaleRange: ClosedRange<Double>
    let opacityRange: ClosedRange<Double>
    
    @State private var isBreathing = false
    
    init(
        duration: Double = 4.0,
        scaleRange: ClosedRange<Double> = 1.0...1.05,
        opacityRange: ClosedRange<Double> = 0.8...1.0,
        @ViewBuilder content: () -> Content
    ) {
        self.duration = duration
        self.scaleRange = scaleRange
        self.opacityRange = opacityRange
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(isBreathing ? scaleRange.upperBound : scaleRange.lowerBound)
            .opacity(isBreathing ? opacityRange.upperBound : opacityRange.lowerBound)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isBreathing
            )
            .onAppear {
                isBreathing = true
            }
    }
}

// Extension for easy breathing animation
extension View {
    func breathing(
        duration: Double = 4.0,
        scaleRange: ClosedRange<Double> = 1.0...1.05,
        opacityRange: ClosedRange<Double> = 0.8...1.0
    ) -> some View {
        BreathingView(
            duration: duration,
            scaleRange: scaleRange,
            opacityRange: opacityRange
        ) {
            self
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        Text("🎉")
            .font(.system(size: 60))
            .breathing(duration: 2.0, scaleRange: 1.0...1.2)
        
        RoundedRectangle(cornerRadius: 16)
            .fill(.blue)
            .frame(width: 100, height: 100)
            .breathing(duration: 3.0)
    }
    .padding()
}
