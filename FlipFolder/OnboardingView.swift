//
//  OnboardingView.swift
//  FlipFolder
//
//  Created by Adam Kuzma
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var showHeader = false
    @State private var showBody = false
    @State private var showButton = false
    @State private var showLegalText = false
    @State private var showFontDebugView = false
    @State private var refreshTrigger = false
    @State private var marqueeKey = UUID() // Used to force recreate the marquee
    @State private var showMarquee = false // Control marquee visibility
    
    // Timing for animations
    private let initialDelay = 2.0 // Initial delay before any animations start
    private let marqueeCompletionDelay = 2.3 // Time until marquee completes its initial animations
    private let headerDelay = 0.3 // Delay after marquee before showing header
    private let bodyDelay = 0.3 // Delay after header before showing body
    private let buttonDelay = 0.3 // Delay after body before showing button
    private let legalTextDelay = 0.0 // Delay after button before showing legal text
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "#0d0d0d")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Marquee component
                if showMarquee {
                    MarqueeView(refreshTrigger: refreshTrigger)
                        .id(marqueeKey) // Force view recreation on refresh
                        .padding(.top, 40)
                        .edgesIgnoringSafeArea(.horizontal)
                        .transition(.opacity)
                } else {
                    // Empty spacer to maintain layout
                    Spacer()
                        .frame(height: 175) // Approximate height of MarqueeView
                }
                
                Spacer(minLength: 40)
                
                VStack(spacing: 28) {
                    // Title
                    Text("Your Band, Always in Sync.")
                        .font(.custom("Futura-Book", size: 36))
                        .foregroundColor(.white)
                        .kerning(-0.7)
                        .lineSpacing(-5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .opacity(showHeader ? 1 : 0)
                        .offset(y: showHeader ? 0 : 20)
                    
                    // Description
                    Text("Music flows better when your band is in sync. Go paperless and perform effortlessly.")
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .lineSpacing(2)
                        .opacity(showBody ? 1 : 0)
                        .offset(y: showBody ? 0 : 10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 14) {
                    // Get Started button
                    Button(action: {
                        // Set onboarding as completed
                        isOnboardingCompleted = true
                        
                        // Previous code for animation - leaving this in case you want to test animations
                        /*
                        // Immediately reset all animation states without animation
                        showHeader = false
                        showBody = false
                        showButton = false
                        showLegalText = false
                        
                        // Generate new UUID to force MarqueeView recreation
                        marqueeKey = UUID()
                        
                        // Toggle refresh trigger to restart marquee
                        refreshTrigger.toggle()
                        
                        // Immediately start the animation sequence again
                        startAnimationSequence()
                        */
                    }) {
                        Text("Get Started")
                            .font(.custom("Futura", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#7662F6"))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 12)
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 10)
                    
                    // Legal text
                    Text("By continuing you agree to our EULA, Terms & Conditions, and Privacy Policy.")
                        .font(.custom("DMSans-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        .opacity(showLegalText ? 1 : 0)
                        
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .onAppear {
                startAnimationSequence()
            }
        }
    }
    
    // Function to start the animation sequence
    private func startAnimationSequence() {
        // Initial delay before starting any animations
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
            // First show the marquee with animation
            withAnimation(.easeInOut(duration: 0.6)) {
                showMarquee = true
            }
            
            // Start animation sequence after marquee animation
            DispatchQueue.main.asyncAfter(deadline: .now() + marqueeCompletionDelay) {
                // Animate header
                withAnimation(.easeInOut(duration: 0.6)) {
                    showHeader = true
                }
                
                // Animate body text after header
                DispatchQueue.main.asyncAfter(deadline: .now() + bodyDelay) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showBody = true
                    }
                    
                    // Animate button after body
                    DispatchQueue.main.asyncAfter(deadline: .now() + buttonDelay) {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            showButton = true
                        }
                        
                        // Animate legal text after button
                        DispatchQueue.main.asyncAfter(deadline: .now() + legalTextDelay) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                showLegalText = true
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isOnboardingCompleted: .constant(false))
    }
}

// Helper extensions
extension ColorTokens {
    static var active: Color {
        Color(hex: "#6B4EFF")
    }
    
    static var inactive: Color {
        Color(red: 0.86, green: 0.86, blue: 0.86)
    }
} 
