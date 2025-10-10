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
    @State private var logoScale: CGFloat = 0.5
    @State private var logoRotation: Double = 0
    
    var body: some View {
        if showMainApp {
            ContentView()
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
        } else {
            ZStack {
                // Enhanced background gradient with iOS 18 effects
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.9),
                        Color.purple.opacity(0.7),
                        Color.indigo.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .overlay(
                    // Subtle animated overlay
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)
                )
                
                VStack(spacing: 30) {
                    // Enhanced app icon with iOS 18 animations
                    ZStack {
                        // Multiple animated rings for depth
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.4 - Double(index) * 0.1),
                                            Color.white.opacity(0.1 - Double(index) * 0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2 - CGFloat(index) * 0.5
                                )
                                .frame(width: 140 + CGFloat(index) * 20, height: 140 + CGFloat(index) * 20)
                                .scaleEffect(isAnimating ? 1.1 + CGFloat(index) * 0.05 : 1.0)
                                .animation(
                                    .spring(response: 2.0, dampingFraction: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                    value: isAnimating
                                )
                        }
                        
                        // Main circle with enhanced gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(logoScale)
                            .rotationEffect(.degrees(logoRotation))
                            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                        
                        // Logo icon with enhanced effects
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .scaleEffect(logoScale)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: -1)
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
                // Start all animations with iOS 18 spring animations
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    isAnimating = true
                }
                
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                    logoScale = 1.0
                }
                
                withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                    logoRotation = 360
                }
                
                // Show main app after delay with enhanced transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.9)) {
                        showMainApp = true
                    }
                }
            }
        }
    }
}

