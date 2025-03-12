//
//  AnnotationMenu.swift
//  FlipFolder
//
//  Created by Adam Kuzma on 3/12/25.
//

import SwiftUI

// Annotation Top Menu
struct AnnotationTopMenu: View {
    @Binding var isAnnotationModeActive: Bool
    @Binding var isTopMenuVisible: Bool
    @State private var selectedTab: AnnotationTab = .private
    @State private var isDiscardPressed = false
    @State private var isSavePressed = false
    
    enum AnnotationTab {
        case `private`, shared
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            HStack(alignment: .top, spacing: 5) {
                // Close/Discard button
                AnnotationNavItem(imageName: "xmark", isPressed: $isDiscardPressed) {
                    // First, hide the annotation mode
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAnnotationModeActive = false
                    }
                    
                    // After a short delay, show the top menu
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isTopMenuVisible = true
                        }
                    }
                }
                
                Spacer()
                
                // Annotation tabs
                AnnotationTabSelector(selectedTab: $selectedTab, isLandscape: isLandscape)
                
                Spacer()
                
                // Save button
                AnnotationNavItem(imageName: "checkmark", isPressed: $isSavePressed) {
                    // First, hide the annotation mode
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAnnotationModeActive = false
                    }
                    
                    // After a short delay, show the top menu
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isTopMenuVisible = true
                        }
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.clear)
        }
    }
}

// Annotation Nav Item (similar to NavItem)
struct AnnotationNavItem: View {
    let imageName: String
    @Binding var isPressed: Bool
    var action: () -> Void
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: imageName == "xmark" ? 14 : 16, height: imageName == "xmark" ? 14 : 16)
            .padding(imageName == "xmark" ? 9 : 8)
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
                        action()
                    }
            )
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// Annotation Tab Selector (similar to StatusIndicator)
struct AnnotationTabSelector: View {
    @Binding var selectedTab: AnnotationTopMenu.AnnotationTab
    var isLandscape: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Private Notes Tab
            TabButton(
                title: "Private Notes",
                isSelected: selectedTab == .private,
                position: .left
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .private
                }
            }
            
            // Shared Notes Tab
            TabButton(
                title: "Shared Notes",
                isSelected: selectedTab == .shared,
                position: .right
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .shared
                }
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
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
        .fixedSize(horizontal: !isLandscape, vertical: true)
    }
}

// Tab Button for the Annotation Tab Selector
struct TabButton: View {
    enum Position {
        case left, right
    }
    
    let title: String
    let isSelected: Bool
    let position: Position
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .kerning(-0.2)
                .foregroundColor(isSelected ? Color(red: 69/255, green: 61/255, blue: 75/255) : Color(red: 132/255, green: 123/255, blue: 139/255))
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .background(
                    isSelected ?
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.7))
                        .padding(2)
                    : nil
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        AnnotationTopMenu(
            isAnnotationModeActive: .constant(true),
            isTopMenuVisible: .constant(false)
        )
        .frame(height: 80)
        .background(Color.gray.opacity(0.1))
        
        Spacer()
    }
} 
