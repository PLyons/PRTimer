//
//  OptimizedAnimationView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

/// Optimized animation wrapper that adapts based on performance
struct OptimizedAnimationView<Content: View>: View {
    let content: Content
    let animationType: OptimizedAnimationType
    let enabled: Bool
    
    @StateObject private var performanceMonitor = PerformanceMonitor()
    @State private var isReducedMotion = false
    
    init(
        type: OptimizedAnimationType = .standard,
        enabled: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.animationType = type
        self.enabled = enabled
        self.content = content()
    }
    
    var body: some View {
        Group {
            if shouldAnimate {
                content
                    .animation(optimizedAnimation, value: UUID())
            } else {
                content
            }
        }
        .onAppear {
            checkAccessibilitySettings()
            if enabled {
                performanceMonitor.startMonitoring()
            }
        }
        .onDisappear {
            performanceMonitor.stopMonitoring()
        }
    }
    
    private var shouldAnimate: Bool {
        enabled && !isReducedMotion && performanceMonitor.fps >= animationType.minimumFPS
    }
    
    private var optimizedAnimation: Animation {
        if performanceMonitor.fps >= 55 {
            return animationType.highPerformanceAnimation
        } else if performanceMonitor.fps >= 30 {
            return animationType.standardAnimation
        } else {
            return animationType.lowPerformanceAnimation
        }
    }
    
    private func checkAccessibilitySettings() {
        isReducedMotion = UIAccessibility.isReduceMotionEnabled
    }
}

// MARK: - Animation Types

enum OptimizedAnimationType {
    case standard
    case spring
    case bounce
    case shimmer
    case breathing
    
    var minimumFPS: Double {
        switch self {
        case .standard: return 25
        case .spring: return 30
        case .bounce: return 35
        case .shimmer: return 40
        case .breathing: return 20
        }
    }
    
    var highPerformanceAnimation: Animation {
        switch self {
        case .standard:
            return .easeInOut(duration: 0.3)
        case .spring:
            return .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)
        case .bounce:
            return .spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.3)
        case .shimmer:
            return .linear(duration: 2.0).repeatForever(autoreverses: false)
        case .breathing:
            return .easeInOut(duration: 4.0).repeatForever(autoreverses: true)
        }
    }
    
    var standardAnimation: Animation {
        switch self {
        case .standard:
            return .easeInOut(duration: 0.4)
        case .spring:
            return .spring(response: 0.7, dampingFraction: 0.8)
        case .bounce:
            return .spring(response: 0.8, dampingFraction: 0.7)
        case .shimmer:
            return .linear(duration: 3.0).repeatForever(autoreverses: false)
        case .breathing:
            return .easeInOut(duration: 5.0).repeatForever(autoreverses: true)
        }
    }
    
    var lowPerformanceAnimation: Animation {
        switch self {
        case .standard:
            return .easeInOut(duration: 0.5)
        case .spring:
            return .easeOut(duration: 0.5)
        case .bounce:
            return .easeOut(duration: 0.6)
        case .shimmer:
            return .linear(duration: 4.0).repeatForever(autoreverses: false)
        case .breathing:
            return .easeInOut(duration: 6.0).repeatForever(autoreverses: true)
        }
    }
}

// MARK: - Memory-Optimized Particle System

struct OptimizedParticleView: View {
    @State private var particles: [OptimizedParticle] = []
    @StateObject private var performanceMonitor = PerformanceMonitor()
    
    let maxParticles: Int
    let particleType: ParticleType
    
    init(maxParticles: Int = 30, type: ParticleType = .confetti) {
        self.maxParticles = maxParticles
        self.particleType = type
    }
    
    var body: some View {
        ZStack {
            ForEach(particles.prefix(adaptiveParticleCount), id: \.id) { particle in
                particleView(particle)
            }
        }
        .onAppear {
            performanceMonitor.startMonitoring()
            generateParticles()
        }
        .onDisappear {
            performanceMonitor.stopMonitoring()
            particles.removeAll()
        }
    }
    
    private var adaptiveParticleCount: Int {
        if performanceMonitor.fps >= 55 {
            return maxParticles
        } else if performanceMonitor.fps >= 35 {
            return maxParticles / 2
        } else {
            return maxParticles / 4
        }
    }
    
    private func particleView(_ particle: OptimizedParticle) -> some View {
        Group {
            switch particleType {
            case .confetti:
                RoundedRectangle(cornerRadius: 2)
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            case .sparkle:
                Text("✨")
                    .font(.system(size: particle.size))
            case .circle:
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            }
        }
        .offset(x: particle.position.x, y: particle.position.y)
        .opacity(particle.opacity)
        .scaleEffect(particle.scale)
        .rotationEffect(.degrees(particle.rotation))
    }
    
    private func generateParticles() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan]
        
        for _ in 0..<maxParticles {
            let particle = OptimizedParticle(
                id: UUID(),
                position: CGPoint(
                    x: Double.random(in: -200...200),
                    y: Double.random(in: -300...300)
                ),
                color: colors.randomElement() ?? .blue,
                size: Double.random(in: 4...12),
                opacity: 1.0,
                scale: 1.0,
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)
        }
        
        animateParticles()
    }
    
    private func animateParticles() {
        let animationDuration = performanceMonitor.fps >= 30 ? 3.0 : 5.0
        
        withAnimation(.linear(duration: animationDuration)) {
            for i in particles.indices {
                particles[i].position.y += Double.random(in: 400...600)
                particles[i].position.x += Double.random(in: -100...100)
                particles[i].opacity = 0.0
                particles[i].rotation += Double.random(in: 180...540)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            particles.removeAll()
        }
    }
}

struct OptimizedParticle {
    let id: UUID
    var position: CGPoint
    let color: Color
    let size: Double
    var opacity: Double
    var scale: Double
    var rotation: Double
}

enum ParticleType {
    case confetti
    case sparkle
    case circle
}

// MARK: - Performance-Aware View Modifiers

extension View {
    func optimizedAnimation(
        type: OptimizedAnimationType = .standard,
        enabled: Bool = true
    ) -> some View {
        OptimizedAnimationView(type: type, enabled: enabled) {
            self
        }
    }
    
    func adaptiveBlur(radius: CGFloat, threshold: Double = 30.0) -> some View {
        modifier(AdaptiveBlurModifier(radius: radius, performanceThreshold: threshold))
    }
}

struct AdaptiveBlurModifier: ViewModifier {
    let radius: CGFloat
    let performanceThreshold: Double
    @StateObject private var monitor = PerformanceMonitor()
    
    func body(content: Content) -> some View {
        content
            .blur(radius: monitor.fps >= performanceThreshold ? radius : radius * 0.5)
            .onAppear {
                monitor.startMonitoring()
            }
            .onDisappear {
                monitor.stopMonitoring()
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 30) {
            Text("Optimized Animations")
                .font(.title)
                .foregroundColor(.white)
                .optimizedAnimation(type: .spring)
            
            OptimizedParticleView(maxParticles: 20, type: .confetti)
                .frame(height: 200)
        }
    }
}   
