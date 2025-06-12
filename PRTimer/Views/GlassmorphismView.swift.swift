//
//  GlassmorphismView.swift.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

/// Advanced glassmorphism effect with multiple depth levels
struct GlassmorphismView: View {
    let style: GlassmorphismStyle
    let cornerRadius: CGFloat
    
    init(style: GlassmorphismStyle = .card, cornerRadius: CGFloat = 16) {
        self.style = style
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        ZStack {
            // Base material layer
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(style.baseMaterial)
            
            // Secondary gradient layer for depth
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(style.overlayGradient)
            
            // Border highlight
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(style.borderGradient, lineWidth: style.borderWidth)
            
            // Inner shadow effect
            if style.hasInnerShadow {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(style.innerShadowGradient)
                    .blur(radius: 1)
                    .offset(x: 0, y: 1)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(LinearGradient(
                                colors: [Color.clear, Color.black],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                    )
            }
        }
        .shadow(color: style.shadowColor, radius: style.shadowRadius, x: 0, y: style.shadowOffset)
    }
}

// MARK: - Glassmorphism Styles

enum GlassmorphismStyle {
    case card
    case elevated
    case floating
    case subtle
    case prominent
    
    var baseMaterial: Material {
        switch self {
        case .card:
            return .ultraThinMaterial
        case .elevated:
            return .thinMaterial
        case .floating:
            return .regularMaterial
        case .subtle:
            return .ultraThinMaterial
        case .prominent:
            return .thickMaterial
        }
    }
    
    var overlayGradient: LinearGradient {
        switch self {
        case .card:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.25),
                    Color.white.opacity(0.10),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .elevated:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.35),
                    Color.white.opacity(0.15),
                    Color.white.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .floating:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.45),
                    Color.white.opacity(0.20),
                    Color.white.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .subtle:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.15),
                    Color.white.opacity(0.05),
                    Color.white.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .prominent:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.55),
                    Color.white.opacity(0.25),
                    Color.white.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var borderGradient: LinearGradient {
        switch self {
        case .card:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.4),
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .elevated:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.5),
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .floating:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.6),
                    Color.white.opacity(0.4),
                    Color.white.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .subtle:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.15),
                    Color.white.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .prominent:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.7),
                    Color.white.opacity(0.5),
                    Color.white.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .card: return 1.5
        case .elevated: return 2.0
        case .floating: return 2.5
        case .subtle: return 1.0
        case .prominent: return 3.0
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .card, .subtle:
            return Color.black.opacity(0.15)
        case .elevated:
            return Color.black.opacity(0.25)
        case .floating:
            return Color.black.opacity(0.35)
        case .prominent:
            return Color.black.opacity(0.4)
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .card: return 25
        case .elevated: return 35
        case .floating: return 45
        case .subtle: return 15
        case .prominent: return 55
        }
    }
    
    var shadowOffset: CGFloat {
        switch self {
        case .card: return 15
        case .elevated: return 20
        case .floating: return 25
        case .subtle: return 10
        case .prominent: return 30
        }
    }
    
    var hasInnerShadow: Bool {
        switch self {
        case .card, .elevated, .floating: return true
        case .subtle, .prominent: return false
        }
    }
    
    var innerShadowGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.black.opacity(0.1),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - View Extension

extension View {
    func glassmorphism(style: GlassmorphismStyle = .card, cornerRadius: CGFloat = 16) -> some View {
        self.background(
            GlassmorphismView(style: style, cornerRadius: cornerRadius)
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.blue, Color.purple, Color.orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            ForEach([GlassmorphismStyle.subtle, .card, .elevated, .floating, .prominent], id: \.self) { style in
                Text("Sample Text")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .glassmorphism(style: style)
            }
        }
        .padding()
    }
}
