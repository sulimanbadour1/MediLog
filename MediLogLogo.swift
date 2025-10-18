//
//  MediLogLogo.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI

struct MediLogLogo: View {
    let size: CGFloat
    let showText: Bool
    
    init(size: CGFloat = 60, showText: Bool = true) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Logo Icon
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.6, height: size * 0.6)
                
                // Medical cross
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size * 0.15, height: size * 0.25)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size * 0.25, height: size * 0.15)
                }
                
                // Small dots for medical theme
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Spacer()
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 3)
                    }
                    Spacer()
                }
                .padding(4)
            }
            
            if showText {
                // App Name
                VStack(alignment: .leading, spacing: 2) {
                    Text("MediLog")
                        .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Health Tracker")
                        .font(.system(size: size * 0.15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct MediLogLogoIcon: View {
    let size: CGFloat
    
    init(size: CGFloat = 40) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Medical cross
            VStack(spacing: 2) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size * 0.25, height: size * 0.4)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size * 0.4, height: size * 0.25)
            }
            
            // Decorative dots
            VStack {
                HStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
                Spacer()
            }
            .padding(6)
        }
    }
}

struct MediLogLogoCompact: View {
    let size: CGFloat
    
    init(size: CGFloat = 30) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size * 0.6)
            
            // Medical cross
            VStack(spacing: 1) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size * 0.2, height: size * 0.3)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: size * 0.3, height: size * 0.2)
            }
        }
    }
}

// Preview
struct MediLogLogo_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Full logo
            MediLogLogo(size: 80, showText: true)
            
            // Icon only
            MediLogLogoIcon(size: 60)
            
            // Compact version
            MediLogLogoCompact(size: 40)
            
            // Different sizes
            HStack(spacing: 20) {
                MediLogLogo(size: 40, showText: false)
                MediLogLogo(size: 60, showText: false)
                MediLogLogo(size: 80, showText: false)
            }
        }
        .padding()
    }
}
