//
//  ShimmerEffectView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct ShimmerEffectView: View {
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var pulseScale: CGFloat = 1.0
    let intensity: Double
    let speed: Double
    
    init(intensity: Double = 0.3, speed: Double = 2.0) {
        self.intensity = intensity
        self.speed = speed
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main shimmer sweep
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(intensity * 0.8),
                        Color.white.opacity(intensity),
                        Color.white.opacity(intensity * 0.8),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(25))
                .offset(x: shimmerOffset * (geometry.size.width + 100))
                .animation(
                    Animation.linear(duration: speed)
                        .repeatForever(autoreverses: false),
                    value: shimmerOffset
                )
                
                // Pulse effect overlay
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(intensity * 0.5),
                                Color.clear,
                                Color.white.opacity(intensity * 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .scaleEffect(pulseScale)
                    .animation(
                        Animation.easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: true),
                        value: pulseScale
                    )
            }
        }
        .onAppear {
            shimmerOffset = 1.0
            pulseScale = 1.05
        }
    }
}

// Extension to add shimmer to any view
extension View {
    func shimmer(intensity: Double = 0.3, speed: Double = 2.0) -> some View {
        self.overlay(
            ShimmerEffectView(intensity: intensity, speed: speed)
                .clipped()
        )
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 16)
        .fill(.ultraThinMaterial)
        .frame(width: 120, height: 100)
        .shimmer()
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
