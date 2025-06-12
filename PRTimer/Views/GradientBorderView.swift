//
//  GradientBorderView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

/// Advanced gradient border system with animated effects
struct GradientBorderView: View {
    let gradient: Gradient
    let width: CGFloat
    let cornerRadius: CGFloat
    let animated: Bool
    
    @State private var animationOffset: CGFloat = 0
    
    init(
        gradient: Gradient,
        width: CGFloat = 2,
        cornerRadius: CGFloat = 12,
        animated: Bool = false
    ) {
        self.gradient = gradient
        self.width = width
        self.cornerRadius = cornerRadius
        self.animated = animated
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                LinearGradient(
                    gradient: gradient,
                    startPoint: .init(x: animationOffset, y: 0),
                    endPoint: .init(x: animationOffset + 1, y: 1)
                ),
                lineWidth: width
            )
            .onAppear {
                if animated {
                    withAnimation(
                        .linear(duration: 3.0)
                        .repeatForever(autoreverses: false)
                    ) {
                        animationOffset = 2.0
                    }
                }
            }
    }
}

// MARK: - Predefined Gradient Styles

extension Gradient {
    static let glass = Gradient(colors: [
        Color.white.opacity(0.8),
        Color.white.opacity(0.2),
        Color.white.opacity(0.1),
        Color.white.opacity(0.3)
    ])
    
    static let aurora = Gradient(colors: [
        Color.purple.opacity(0.8),
        Color.blue.opacity(0.6),
        Color.cyan.opacity(0.8),
        Color.green.opacity(0.6)
    ])
    
    static let sunset = Gradient(colors: [
        Color.orange.opacity(0.8),
        Color.pink.opacity(0.6),
        Color.purple.opacity(0.8),
        Color.blue.opacity(0.6)
    ])
    
    static let golden = Gradient(colors: [
        Color.yellow.opacity(0.8),
        Color.orange.opacity(0.6),
        Color.red.opacity(0.4),
        Color.yellow.opacity(0.6)
    ])
    
    static let oceanic = Gradient(colors: [
        Color.blue.opacity(0.8),
        Color.cyan.opacity(0.6),
        Color.teal.opacity(0.8),
        Color.blue.opacity(0.6)
    ])
}

// MARK: - View Extensions

extension View {
    func gradientBorder(
        gradient: Gradient,
        width: CGFloat = 2,
        cornerRadius: CGFloat = 12,
        animated: Bool = false
    ) -> some View {
        self.overlay(
            GradientBorderView(
                gradient: gradient,
                width: width,
                cornerRadius: cornerRadius,
                animated: animated
            )
        )
    }
    
    func animatedGlassBorder(width: CGFloat = 2, cornerRadius: CGFloat = 12) -> some View {
        self.gradientBorder(
            gradient: .glass,
            width: width,
            cornerRadius: cornerRadius,
            animated: true
        )
    }
    
    func themedBorder(
        color: Color,
        width: CGFloat = 2,
        cornerRadius: CGFloat = 12,
        intensity: Double = 0.8
    ) -> some View {
        let gradient = Gradient(colors: [
            color.opacity(intensity),
            color.opacity(intensity * 0.5),
            color.opacity(intensity * 0.2),
            color.opacity(intensity * 0.6)
        ])
        
        return self.gradientBorder(
            gradient: gradient,
            width: width,
            cornerRadius: cornerRadius,
            animated: false
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.purple, Color.blue, Color.cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .frame(width: 200, height: 80)
                .overlay(Text("Glass Border").foregroundColor(.white))
                .animatedGlassBorder(cornerRadius: 16)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .frame(width: 200, height: 80)
                .overlay(Text("Aurora Border").foregroundColor(.white))
                .gradientBorder(gradient: .aurora, cornerRadius: 16, animated: true)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .frame(width: 200, height: 80)
                .overlay(Text("Themed Border").foregroundColor(.white))
                .themedBorder(color: .orange, cornerRadius: 16)
        }
        .padding()
    }
}
