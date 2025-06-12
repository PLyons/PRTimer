//
//  PerformanceMonitor.swift
//  PRTimer
//
//  Created by Paul Lyons on 6/5/25.
//

import SwiftUI
import Foundation

/// Performance monitoring and optimization utilities
class PerformanceMonitor: ObservableObject {
    @Published var fps: Double = 60
    @Published var memoryUsage: Double = 0
    @Published var isMonitoring = false
    
    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastTimestamp: CFTimeInterval = 0
    private var memoryTimer: Timer?
    
    // MARK: - FPS Monitoring
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        displayLink = CADisplayLink(target: self, selector: #selector(frameUpdate))
        displayLink?.add(to: .main, forMode: .common)
        
        // Start memory monitoring
        startMemoryMonitoring()
    }
    
    func stopMonitoring() {
        isMonitoring = false
        displayLink?.invalidate()
        displayLink = nil
        memoryTimer?.invalidate()
        memoryTimer = nil
    }
    
    @objc private func frameUpdate(displayLink: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = displayLink.timestamp
            return
        }
        
        frameCount += 1
        let elapsed = displayLink.timestamp - lastTimestamp
        
        if elapsed >= 1.0 {
            let newFPS = Double(frameCount) / elapsed
            
            // Smooth the FPS reading to avoid jitter
            DispatchQueue.main.async { [weak self] in
                self?.fps = newFPS
            }
            
            frameCount = 0
            lastTimestamp = displayLink.timestamp
        }
    }
    
    // MARK: - Memory Monitoring
    
    private func startMemoryMonitoring() {
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }
    
    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: 1) { intPtr in
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         intPtr,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usage = Double(info.resident_size) / 1024 / 1024 // MB
            DispatchQueue.main.async { [weak self] in
                self?.memoryUsage = usage
            }
        }
    }
    
    // MARK: - Performance Optimization Helpers
    
    /// Debounce function to limit rapid updates
    static func debounce<T>(
        delay: TimeInterval,
        queue: DispatchQueue = .main,
        action: @escaping (T) -> Void
    ) -> (T) -> Void {
        var workItem: DispatchWorkItem?
        
        return { param in
            workItem?.cancel()
            workItem = DispatchWorkItem { action(param) }
            queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
        }
    }
    
    /// Throttle function to limit execution frequency
    static func throttle<T>(
        interval: TimeInterval,
        queue: DispatchQueue = .main,
        action: @escaping (T) -> Void
    ) -> (T) -> Void {
        var lastExecution: Date?
        
        return { param in
            let now = Date()
            if let last = lastExecution, now.timeIntervalSince(last) < interval {
                return
            }
            lastExecution = now
            queue.async { action(param) }
        }
    }
    
    // MARK: - Performance Metrics
    
    var isHighPerformance: Bool {
        fps >= 55 && memoryUsage <= 100
    }
    
    var isLowPerformance: Bool {
        fps < 30 || memoryUsage > 200
    }
    
    var performanceLevel: PerformanceLevel {
        if fps >= 55 && memoryUsage <= 50 {
            return .high
        } else if fps >= 30 && memoryUsage <= 100 {
            return .medium
        } else {
            return .low
        }
    }
}

enum PerformanceLevel {
    case high
    case medium
    case low
    
    var description: String {
        switch self {
        case .high: return "High Performance"
        case .medium: return "Medium Performance"
        case .low: return "Low Performance"
        }
    }
}

// MARK: - View Extensions for Performance

extension View {
    /// Conditionally render view based on performance threshold
    func renderWhen(fps: Double, minimum: Double = 30.0) -> some View {
        Group {
            if fps >= minimum {
                self
            } else {
                EmptyView()
            }
        }
    }
    
    /// Reduce animation complexity on lower performance
    func adaptiveAnimation(fps: Double, threshold: Double = 45.0) -> some View {
        self.animation(
            fps >= threshold ?
                .spring(response: 0.5, dampingFraction: 0.8) :
                .easeInOut(duration: 0.3),
            value: fps
        )
    }
    
    /// Performance-aware modifier
    func performanceAware(_ monitor: PerformanceMonitor) -> some View {
        self.modifier(PerformanceAwareModifier(monitor: monitor))
    }
}

struct PerformanceAwareModifier: ViewModifier {
    @ObservedObject var monitor: PerformanceMonitor
    
    func body(content: Content) -> some View {
        content
            .opacity(monitor.isLowPerformance ? 0.8 : 1.0)
            .animation(
                monitor.isHighPerformance ?
                    .spring(response: 0.5, dampingFraction: 0.8) :
                    .easeInOut(duration: 0.3),
                value: monitor.performanceLevel
            )
    }
}

#if DEBUG
/// Performance overlay for debugging
struct PerformanceOverlay: View {
    @StateObject private var monitor = PerformanceMonitor()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("FPS: \(monitor.fps, specifier: "%.1f")")
                .font(.caption)
                .foregroundColor(fpsColor)
            
            Text("Memory: \(monitor.memoryUsage, specifier: "%.1f") MB")
                .font(.caption)
                .foregroundColor(memoryColor)
            
            Text(monitor.performanceLevel.description)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .onAppear {
            monitor.startMonitoring()
        }
        .onDisappear {
            monitor.stopMonitoring()
        }
    }
    
    private var fpsColor: Color {
        if monitor.fps >= 55 { return .green }
        else if monitor.fps >= 30 { return .orange }
        else { return .red }
    }
    
    private var memoryColor: Color {
        if monitor.memoryUsage <= 50 { return .green }
        else if monitor.memoryUsage <= 100 { return .orange }
        else { return .red }
    }
}
#endif

#Preview {
    VStack(spacing: 20) {
        Text("Performance Monitor")
            .font(.title)
        
        #if DEBUG
        PerformanceOverlay()
        #endif
    }
    .padding()
}
