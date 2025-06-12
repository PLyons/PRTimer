//
//  AnimatedNumberView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI
import Foundation
import CoreGraphics

struct AnimatedNumberView: View {
    let value: String
    @State private var previousValue: String = ""
    @State private var isAnimating = false
    @State private var particles: [NumberParticle] = []
    @EnvironmentObject var colorTheme: ColorThemeManager
    
    var body: some View {
        ZStack {
            // Main number with transition animation
            Text(value)
                .font(.system(size: 44, weight: .heavy, design: .monospaced))
                .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                .shadow(color: colorTheme.currentTheme.textShadowColor, radius: 2, x: 2, y: 2)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.7 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            
            // Particle effects overlay
            ForEach(particles, id: \.id) { particle in
                Text("+")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(colorTheme.accentColor)
                    .offset(x: particle.offsetX, y: particle.offsetY)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onChange(of: value) { oldValue, newValue in
            if !previousValue.isEmpty && previousValue != newValue {
                triggerNumberChangeAnimation()
            }
            previousValue = newValue
        }
        .onAppear {
            previousValue = value
        }
    }
    
    private func triggerNumberChangeAnimation() {
        // Trigger scale animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isAnimating = true
        }
        
        // Reset animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = false
            }
        }
        
        // Create particle effects
        createParticles()
    }
    
    private func createParticles() {
        let particleCount = 5
        particles.removeAll()
        
        for i in 0..<particleCount {
            let angle = Double(i) * (2 * .pi / Double(particleCount))
            let radius: Double = 30
            
            let particle = NumberParticle(
                id: UUID(),
                offsetX: cos(angle) * radius,
                offsetY: sin(angle) * radius,
                opacity: 1.0,
                scale: 0.5
            )
            
            particles.append(particle)
        }
        
        // Animate particles
        withAnimation(.easeOut(duration: 1.0)) {
            for i in particles.indices {
                particles[i].opacity = 0.0
                particles[i].scale = 1.5
                particles[i].offsetX = particles[i].offsetX * 2
                particles[i].offsetY = particles[i].offsetY * 2
            }
        }
        
        // Remove particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            particles.removeAll()
        }
    }
}

struct NumberParticle {
    let id: UUID
    var offsetX: Double
    var offsetY: Double
    var opacity: Double
    var scale: Double
    
    init(id: UUID, offsetX: Double, offsetY: Double, opacity: Double, scale: Double) {
        self.id = id
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.opacity = opacity
        self.scale = scale
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        AnimatedNumberView(value: "42")
            .environmentObject(ColorThemeManager())
    }
}
