//
//  ShadowSystemView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI

/// Advanced shadow system with multiple depth levels and semantic meaning
struct ShadowSystemView: View {
    let level: ShadowLevel
    
    var body: some View {
        EmptyView()
    }
}

// MARK: - Shadow Levels

enum ShadowLevel {
    case none
    case subtle
    case soft
    case medium
    case strong
    case dramatic
    case floating
    case pressed
    
    var shadows: [ShadowProperties] {
        switch self {
        case .none:
            return []
        case .subtle:
            return [
                ShadowProperties(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            ]
        case .soft:
            return [
                ShadowProperties(color: .black.opacity(0.1), radius: 8, x: 0, y: 4),
                ShadowProperties(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
            ]
        case .medium:
            return [
                ShadowProperties(color: .black.opacity(0.15), radius: 16, x: 0, y: 8),
                ShadowProperties(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            ]
        case .strong:
            return [
                ShadowProperties(color: .black.opacity(0.2), radius: 24, x: 0, y: 12),
                ShadowProperties(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            ]
        case .dramatic:
            return [
                ShadowProperties(color: .black.opacity(0.3), radius: 40, x: 0, y: 20),
                ShadowProperties(color: .black.opacity(0.2), radius: 16, x: 0, y: 8),
                ShadowProperties(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            ]
        case .floating:
            return [
                ShadowProperties(color: .black.opacity(0.25), radius: 32, x: 0, y: 16),
                ShadowProperties(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            ]
        case .pressed:
            return [
                ShadowProperties(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            ]
        }
    }
}

struct ShadowProperties {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions

extension View {
    func advancedShadow(_ level: ShadowLevel) -> some View {
        var view = AnyView(self)
        
        for shadow in level.shadows {
            view = AnyView(
                view.shadow(
                    color: shadow.color,
                    radius: shadow.radius,
                    x: shadow.x,
                    y: shadow.y
                )
            )
        }
        
        return view
    }
    
    func depthShadow(
        color: Color = .black,
        opacity: Double = 0.2,
        radius: CGFloat = 20,
        x: CGFloat = 0,
        y: CGFloat = 10
    ) -> some View {
        self
            .shadow(color: color.opacity(opacity * 0.5), radius: radius * 1.5, x: x, y: y * 1.5)
            .shadow(color: color.opacity(opacity), radius: radius, x: x, y: y)
            .shadow(color: color.opacity(opacity * 0.3), radius: radius * 0.5, x: x, y: y * 0.5)
    }
    
    func elevationShadow(_ elevation: Int) -> some View {
        let shadowLevel: ShadowLevel
        switch elevation {
        case 0: shadowLevel = .none
        case 1: shadowLevel = .subtle
        case 2: shadowLevel = .soft
        case 3: shadowLevel = .medium
        case 4: shadowLevel = .strong
        case 5: shadowLevel = .dramatic
        default: shadowLevel = .floating
        }
        return self.advancedShadow(shadowLevel)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 40) {
            ForEach(0..<6, id: \.self) { elevation in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 120, height: 60)
                    .overlay(
                        Text("Level \(elevation)")
                            .font(.caption)
                            .fontWeight(.medium)
                    )
                    .elevationShadow(elevation)
            }
        }
        .padding()
    }
}
