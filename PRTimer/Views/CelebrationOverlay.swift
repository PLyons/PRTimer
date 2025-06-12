//
//  CelebrationOverlay.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

struct CelebrationOverlay: View {
    let milestone: Milestone
    @Binding var isShowing: Bool
    @EnvironmentObject var colorTheme: ColorThemeManager
    @State private var animationPhase = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            VStack(spacing: 20) {
                // Milestone content
                milestoneCard
            }
            .scaleEffect(isShowing ? 1.0 : 0.5)
            .opacity(isShowing ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)
            
            // Animation overlay
            animationOverlay
        }
        .onAppear {
            startCelebrationSequence()
        }
    }
    
    private var milestoneCard: some View {
        VStack(spacing: 20) {
            // Title with enhanced styling
            Text(milestone.title)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(colorTheme.currentTheme.primaryTextColor)
                .multilineTextAlignment(.center)
                .advancedShadow(.strong)
                .scaleEffect(animationPhase >= 1 ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2), value: animationPhase)
            
            // Message with premium styling
            Text(milestone.message)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(colorTheme.currentTheme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .advancedShadow(.soft)
                .opacity(animationPhase >= 2 ? 1.0 : 0.0)
                .offset(y: animationPhase >= 2 ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: animationPhase)
            
            // Enhanced celebration emoji
            celebrationEmoji
                .scaleEffect(animationPhase >= 3 ? 1.0 : 0.0)
                .rotationEffect(.degrees(animationPhase >= 3 ? 360 : 0))
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8), value: animationPhase)
            
            // Premium continue button
            Button("Continue") {
                isShowing = false
            }
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .glassmorphism(style: .prominent, cornerRadius: 25)
            .themedBorder(color: colorTheme.accentColor, width: 2, cornerRadius: 25, intensity: 1.0)
            .advancedShadow(.floating)
            .opacity(animationPhase >= 4 ? 1.0 : 0.0)
            .offset(y: animationPhase >= 4 ? 0 : 30)
            .animation(.easeOut(duration: 0.4).delay(1.2), value: animationPhase)
        }
        .padding(36)
        .glassmorphism(style: .floating, cornerRadius: 28)
        .themedBorder(color: colorTheme.accentColor, width: 2.5, cornerRadius: 28, intensity: 0.9)
        .advancedShadow(.dramatic)
        .padding(.horizontal, 32)
    }
    
    private var celebrationEmoji: some View {
        Text(getCelebrationEmoji())
            .font(.system(size: 50))
            .breathing(duration: 2.0, scaleRange: 1.0...1.2)
    }
    
    private var animationOverlay: some View {
        Group {
            switch milestone.animation {
            case .confetti:
                ConfettiView()
            case .fireworks:
                FireworksView()
            case .sparkles:
                SparklesView()
            case .balloons:
                BalloonsView()
            }
        }
    }
    
    private func getCelebrationEmoji() -> String {
        switch milestone.type {
        case .friday:
            return "🎉"
        case .majorCountdown:
            return "🚀"
        case .weekly:
            return "⭐"
        case .fridayCountdown:
            return "📅"
        case .seasonal:
            return "🎊"
        }
    }
    
    private func startCelebrationSequence() {
        // Animate in phases
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animationPhase = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animationPhase = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            animationPhase = 3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animationPhase = 4
        }
    }
}

// MARK: - Additional Animation Views

struct FireworksView: View {
    @State private var particles: [FireworkParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.position.x, y: particle.position.y)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            createFireworks()
        }
    }
    
    private func createFireworks() {
        let colors: [Color] = [.red, .blue, .yellow, .green, .purple, .orange]
        
        for burst in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(burst) * 0.5) {
                let centerX = Double.random(in: -100...100)
                let centerY = Double.random(in: -200...(-50))
                
                for _ in 0..<15 {
                    let angle = Double.random(in: 0...(2 * .pi))
                    let distance = Double.random(in: 30...80)
                    
                    let particle = FireworkParticle(
                        id: UUID(),
                        position: CGPoint(x: centerX, y: centerY),
                        finalPosition: CGPoint(
                            x: centerX + cos(angle) * distance,
                            y: centerY + sin(angle) * distance
                        ),
                        color: colors.randomElement() ?? .yellow,
                        size: Double.random(in: 3...8),
                        opacity: 1.0,
                        scale: 1.0
                    )
                    
                    particles.append(particle)
                }
                
                animateFireworkBurst()
            }
        }
    }
    
    private func animateFireworkBurst() {
        withAnimation(.easeOut(duration: 1.0)) {
            for i in particles.indices {
                particles[i].position = particles[i].finalPosition
                particles[i].opacity = 0.0
                particles[i].scale = 0.5
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particles.removeAll()
        }
    }
}

struct FireworkParticle {
    let id: UUID
    var position: CGPoint
    let finalPosition: CGPoint
    let color: Color
    let size: Double
    var opacity: Double
    var scale: Double
}

struct SparklesView: View {
    @State private var sparkles: [SparkleParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(sparkles, id: \.id) { sparkle in
                Text("✨")
                    .font(.system(size: sparkle.size))
                    .offset(x: sparkle.position.x, y: sparkle.position.y)
                    .opacity(sparkle.opacity)
                    .scaleEffect(sparkle.scale)
                    .rotationEffect(.degrees(sparkle.rotation))
            }
        }
        .onAppear {
            createSparkles()
        }
    }
    
    private func createSparkles() {
        for _ in 0..<20 {
            let sparkle = SparkleParticle(
                id: UUID(),
                position: CGPoint(
                    x: Double.random(in: -200...200),
                    y: Double.random(in: -300...300)
                ),
                size: Double.random(in: 12...24),
                opacity: 1.0,
                scale: 0.0,
                rotation: 0.0
            )
            sparkles.append(sparkle)
        }
        
        animateSparkles()
    }
    
    private func animateSparkles() {
        for i in sparkles.indices {
            let delay = Double.random(in: 0...2.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    sparkles[i].scale = 1.0
                    sparkles[i].rotation = 360.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        sparkles[i].opacity = 0.0
                        sparkles[i].scale = 1.5
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            sparkles.removeAll()
        }
    }
}

struct SparkleParticle {
    let id: UUID
    let position: CGPoint
    let size: Double
    var opacity: Double
    var scale: Double
    var rotation: Double
}

struct BalloonsView: View {
    @State private var balloons: [BalloonParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(balloons, id: \.id) { balloon in
                Text("🎈")
                    .font(.system(size: balloon.size))
                    .offset(x: balloon.position.x, y: balloon.position.y)
                    .opacity(balloon.opacity)
                    .scaleEffect(balloon.scale)
            }
        }
        .onAppear {
            createBalloons()
        }
    }
    
    private func createBalloons() {
        for _ in 0..<8 {
            let balloon = BalloonParticle(
                id: UUID(),
                position: CGPoint(
                    x: Double.random(in: -150...150),
                    y: 400
                ),
                size: Double.random(in: 20...35),
                opacity: 1.0,
                scale: 1.0
            )
            balloons.append(balloon)
        }
        
        animateBalloons()
    }
    
    private func animateBalloons() {
        withAnimation(.easeOut(duration: 3.0)) {
            for i in balloons.indices {
                balloons[i].position.y = -400
                balloons[i].position.x += Double.random(in: -30...30)
                balloons[i].opacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            balloons.removeAll()
        }
    }
}

struct BalloonParticle {
    let id: UUID
    var position: CGPoint
    let size: Double
    var opacity: Double
    var scale: Double
}

#Preview {
    ZStack {
        Color.purple.ignoresSafeArea()
        
        CelebrationOverlay(
            milestone: Milestone(
                type: .majorCountdown,
                title: "10 Days Left! 🚀",
                message: "Single digits! Almost there!",
                animation: .fireworks
            ),
            isShowing: .constant(true)
        )
        .environmentObject(ColorThemeManager())
    }
}
