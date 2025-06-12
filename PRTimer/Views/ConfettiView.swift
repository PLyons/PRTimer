//
//  ConfettiView.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI
import Foundation

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan
    ]
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                confettiPieceView(piece)
            }
        }
        .onAppear {
            startConfetti()
        }
    }
    
    private func confettiPieceView(_ piece: ConfettiPiece) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(piece.color)
            .frame(width: piece.size.width, height: piece.size.height)
            .offset(x: piece.position.x, y: piece.position.y)
            .rotationEffect(.degrees(piece.rotation))
            .opacity(piece.opacity)
            .scaleEffect(piece.scale)
    }
    
    private func startConfetti() {
        // Create initial confetti pieces
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                id: UUID(),
                position: CGPoint(
                    x: Double.random(in: -200...200),
                    y: -100
                ),
                velocity: CGPoint(
                    x: Double.random(in: -50...50),
                    y: Double.random(in: 50...150)
                ),
                color: colors.randomElement() ?? .blue,
                size: CGSize(
                    width: Double.random(in: 4...12),
                    height: Double.random(in: 4...12)
                ),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -5...5),
                opacity: 1.0,
                scale: 1.0
            )
            confettiPieces.append(piece)
        }
        
        // Animate confetti falling
        withAnimation(.linear(duration: 3.0)) {
            isAnimating = true
            updateConfettiPositions()
        }
        
        // Remove confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            confettiPieces.removeAll()
        }
    }
    
    private func updateConfettiPositions() {
        for i in confettiPieces.indices {
            confettiPieces[i].position.x += confettiPieces[i].velocity.x * 3.0
            confettiPieces[i].position.y += confettiPieces[i].velocity.y * 3.0
            confettiPieces[i].rotation += confettiPieces[i].rotationSpeed * 360
            confettiPieces[i].opacity = max(0, confettiPieces[i].opacity - 0.3)
        }
    }
}

struct ConfettiPiece {
    let id: UUID
    var position: CGPoint
    var velocity: CGPoint
    let color: Color
    let size: CGSize
    var rotation: Double
    let rotationSpeed: Double
    var opacity: Double
    var scale: Double
}

// Confetti Trigger Extension
extension View {
    func confetti(isActive: Bool) -> some View {
        self.overlay(
            Group {
                if isActive {
                    ConfettiView()
                }
            }
        )
    }
}

#Preview {
    ZStack {
        Color.black
        ConfettiView()
    }
}
