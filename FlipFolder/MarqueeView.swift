//
//  MarqueeView.swift
//  FlipFolder
//
//  Created by Adam Kuzma
//

import SwiftUI

struct MarqueeView: View {
    private let topRowImages = ["1a", "2a", "3a", "4a", "5a", "6a"]
    private let bottomRowImages = ["1b", "2b", "3b", "4b", "5b", "6b"]
    
    var refreshTrigger: Bool
    
    @State private var topOffset: CGFloat = 0
    @State private var bottomOffset: CGFloat = 0
    @State private var imagesAppeared = false
    @State private var imageDelays: [String: Double] = [:]
    @State private var isAnimating = false
    
    private let animationDuration: Double = 30.0
    private let imageSize: CGFloat = 135
    private let spacing: CGFloat = -24
    private let appearanceDuration: Double = 3.0
    private let individualDelay: Double = 0.15
    private let rowStaggerOffset: CGFloat = 50  // Offset for bottom row staggering
    
    // Default initializer with optional refreshTrigger
    init(refreshTrigger: Bool = false) {
        self.refreshTrigger = refreshTrigger
    }
    
    func startAnimationSequence() {
        // Reset states
        imagesAppeared = false
        isAnimating = false
        topOffset = 0
        bottomOffset = -rowStaggerOffset  // Start the bottom row with the stagger offset
        
        // Explicitly cancel any ongoing animations by forcing a layout update
        DispatchQueue.main.async {
            // Create combined array for all images
            var allImages: [(name: String, row: Int)] = []
            
            // Add top row images
            for imageName in topRowImages {
                allImages.append((name: imageName, row: 0))
            }
            
            // Add bottom row images
            for imageName in bottomRowImages {
                allImages.append((name: imageName, row: 1))
            }
            
            // Shuffle all images
            allImages.shuffle()
            
            // Generate alternating delays for each image
            var newDelays: [String: Double] = [:]
            
            // Assign delays to alternate between top and bottom
            for (index, imageInfo) in allImages.enumerated() {
                let delay = Double(index) * individualDelay
                newDelays[imageInfo.name] = delay
                
                // For duplicates, add a consistent delay
                if let dupeName = getDuplicateName(imageInfo.name) {
                    newDelays[dupeName] = delay + 0.5
                }
            }
            
            // Update state
            imageDelays = newDelays
            
            // First animate the images appearing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                imagesAppeared = true
            }
            
            // Then start the scrolling animation after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + appearanceDuration) {
                isAnimating = true
                
                // Calculate row widths
                let topRowWidth = CGFloat(topRowImages.count) * (imageSize + spacing)
                let bottomRowWidth = CGFloat(bottomRowImages.count) * (imageSize + spacing)
                
                // Start animation for top row (right to left)
                withAnimation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                    topOffset = -topRowWidth
                }
                
                // Initialize bottom row from left side and move right
                bottomOffset = -bottomRowWidth - rowStaggerOffset // Start from negative position (left) with stagger
                
                // Start animation for bottom row (left to right)
                withAnimation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                    bottomOffset = -rowStaggerOffset // Move toward right but maintain stagger
                }
            }
        }
    }
    
    // Get duplicate name for the second set of images
    private func getDuplicateName(_ name: String) -> String? {
        return "duplicate_\(name)"
    }
    
    // Linear gradient mask for fading edges
    private var edgeFadeMask: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .black.opacity(0), location: 0),
                .init(color: .black, location: 0.05),
                .init(color: .black, location: 0.95),
                .init(color: .black.opacity(0), location: 1)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Top row - scrolling left
            ZStack {
                // Container for mask
                GeometryReader { geometry in
                    let rowWidth = CGFloat(topRowImages.count) * (imageSize + spacing)
                    
                    HStack(spacing: spacing) {
                        // First set of images
                        HStack(spacing: spacing) {
                            ForEach(topRowImages, id: \.self) { imageName in
                                ImageWithFallback(imageName: imageName)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: imageSize, height: imageSize)
                                    .background(Color.black.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .opacity(imagesAppeared ? 1 : 0)
                                    .animation(
                                        .easeIn(duration: 0.4).delay(imageDelays[imageName] ?? 0),
                                        value: imagesAppeared
                                    )
                            }
                        }
                        
                        // Duplicate set for seamless scrolling
                        HStack(spacing: spacing) {
                            ForEach(topRowImages, id: \.self) { imageName in
                                let duplicateName = getDuplicateName(imageName) ?? imageName
                                
                                ImageWithFallback(imageName: imageName)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: imageSize, height: imageSize)
                                    .background(Color.black.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .opacity(imagesAppeared ? 1 : 0)
                                    .animation(
                                        .easeIn(duration: 0.4).delay(imageDelays[duplicateName] ?? 0),
                                        value: imagesAppeared
                                    )
                            }
                        }
                    }
                    .offset(x: topOffset)
                }
                .mask(edgeFadeMask)
            }
            .frame(height: imageSize)
            
            // Bottom row - scrolling right
            ZStack {
                // Container for mask
                GeometryReader { geometry in
                    let rowWidth = CGFloat(bottomRowImages.count) * (imageSize + spacing)
                    
                    HStack(spacing: spacing) {
                        // First set of images
                        HStack(spacing: spacing) {
                            ForEach(bottomRowImages, id: \.self) { imageName in
                                ImageWithFallback(imageName: imageName)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: imageSize, height: imageSize)
                                    .background(Color.black.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .opacity(imagesAppeared ? 1 : 0)
                                    .animation(
                                        .easeIn(duration: 0.4).delay(imageDelays[imageName] ?? 0),
                                        value: imagesAppeared
                                    )
                            }
                        }
                        
                        // Duplicate set for seamless scrolling
                        HStack(spacing: spacing) {
                            ForEach(bottomRowImages, id: \.self) { imageName in
                                let duplicateName = getDuplicateName(imageName) ?? imageName
                                
                                ImageWithFallback(imageName: imageName)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: imageSize, height: imageSize)
                                    .background(Color.black.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .opacity(imagesAppeared ? 1 : 0)
                                    .animation(
                                        .easeIn(duration: 0.4).delay(imageDelays[duplicateName] ?? 0),
                                        value: imagesAppeared
                                    )
                            }
                        }
                    }
                    .offset(x: bottomOffset)
                }
                .mask(edgeFadeMask)
            }
            .frame(height: imageSize)
        }
        // Add double tap gesture to entire view
        .contentShape(Rectangle()) // Make entire area tappable
        .onTapGesture(count: 2) {
            // Restart animation sequence on double tap
            startAnimationSequence()
        }
        .onAppear {
            // Start animation sequence on initial appearance
            startAnimationSequence()
        }
        .onChange(of: refreshTrigger) { _ in
            // Restart animation when refresh trigger changes
            startAnimationSequence()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ImageWithFallback: View {
    let imageName: String
    
    var body: some View {
        Group {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                // Fallback placeholder if image not found
                ZStack {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#6B4EFF").opacity(0.6), Color(hex: "#9F7FFF").opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    VStack {
                        Image(systemName: "music.note")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text(imageName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        MarqueeView()
    }
} 
