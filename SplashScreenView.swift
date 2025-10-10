//
//  SplashScreenView.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showMainApp = false
    
    var body: some View {
        if showMainApp {
            ContentView()
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // App icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    // App name
                    VStack(spacing: 8) {
                        Text("MediLog")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Your Health Companion")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0).delay(0.5), value: isAnimating)
                }
            }
            .onAppear {
                isAnimating = true
                
                // Show main app after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showMainApp = true
                    }
                }
            }
        }
    }
}

