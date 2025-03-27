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
    @Environment(\.colorScheme) private var colorScheme
    
    private var imageNameForScheme: String {
        colorScheme == .dark ? "\(imageName)-Dark" : imageName
    }
    
    private var materialOpacity: Double {
        colorScheme == .dark ? 0.6 : 1
    }
    
    var body: some View {
        Image(imageNameForScheme)
            .resizable()
            .scaledToFit()
            .frame(width: 18, height: 18)
            .foregroundStyle(ColorTokens.default)
            .padding(6)
            .background(.ultraThinMaterial.opacity(materialOpacity))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        ColorTokens.containerGradient,
                        lineWidth: 1
                    )
                    .opacity(0.6)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .contentShape(Rectangle())
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
