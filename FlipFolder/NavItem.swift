//
//  NavItem.swift
//  FlipFolder App
//
//  Created by Adam Kuzma on 3/4/25.
//

import SwiftUI

struct NavItem: View {
    let imageName: String
    @State private var isPressed = false
    @Binding var showToolsMenu: Bool
    @Binding var showSongsView: Bool
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .padding(6)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.sRGB, red: 249/255, green: 248/255, blue: 250/255),
                                Color(.sRGB, red: 211/255, green: 209/255, blue: 211/255)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .opacity(0.6)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            triggerHapticFeedback()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        if imageName.lowercased() == "tools" {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showToolsMenu = true
                            }
                        } else if imageName.lowercased() == "music" {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showSongsView = true
                            }
                        }
                    }
            )
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    NavItem(imageName: "Tools", showToolsMenu: .constant(false), showSongsView: .constant(false))
}
