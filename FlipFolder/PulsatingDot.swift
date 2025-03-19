import SwiftUI

struct PulsatingDot: View {
    @State private var isAnimating = false
    var color: Color = Color(hex: "#6B4EFF") // Custom purple color
    
    var body: some View {
        ZStack {
            // Base dot
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            
            // Animated border
            Circle()
                .stroke(color, lineWidth: 1)
                .frame(width: 7, height: 7)
                .scaleEffect(isAnimating ? 2.14 : 1) // 15/7 ≈ 2.14
                .opacity(isAnimating ? 0 : 1)
        }
        .onAppear {
            // Add a slight delay before starting the first animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateWithDelay()
            }
        }
    }
    
    private func animateWithDelay() {
        withAnimation(.easeOut(duration: 1.2)) {
            isAnimating = true
        }
        
        // Reset the animation state after it completes and add a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { // 1.2s animation + 0.6s delay
            isAnimating = false
            // Start the next pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateWithDelay()
            }
        }
    }
}

// Simple static dot without animation
struct StaticDot: View {
    var color: Color = .gray
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 7, height: 7)
    }
}

#Preview {
    VStack(spacing: 20) {
        PulsatingDot() // Using custom purple
        StaticDot() // Using default gray
    }
    .padding(50)
    .background(Color.white)
} 
