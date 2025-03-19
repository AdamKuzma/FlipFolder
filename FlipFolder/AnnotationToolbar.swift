//
//  AnnotationToolbar.swift
//  FlipFolder
//
//  Created by Adam Kuzma on 3/12/25.
//

import SwiftUI

// Annotation Sheet View
struct AnnotationSheet: View {
    @Binding var isVisible: Bool
    @Binding var isTopMenuVisible: Bool
    @State private var selectedColor: Color = .black
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Handle indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 48, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 32)
            
            // Annotation tools layout
            HStack {
                // Left side - Undo/Redo/Clear
                HStack(spacing: 2) {
                    AnnotationTool(icon: "arrow.uturn.backward", label: "Undo")
                    AnnotationTool(icon: "arrow.uturn.forward", label: "Redo")
                    AnnotationTool(icon: "trash", label: "Clear All")
                }
                
                Spacer(minLength: 20)
                
                // Right side - Drawing tools and color
                HStack(spacing: 2) {
                    AnnotationTool(icon: "pencil", label: "Draw")
                    AnnotationTool(icon: "text.cursor", label: "Text")
                    AnnotationTool(icon: "eraser", label: "Erase")
                    ColorOption(color: selectedColor)
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            // Here you would show a color picker
                        }
                }
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 0)
            
            Spacer()
        }
        .frame(height: 150) // Fixed height
        .background(
            // Use a custom shape to only round the top corners
            RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Custom shape to round specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Annotation Tool Button
struct AnnotationTool: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.black)
                .frame(width: 44, height: 44)
                .cornerRadius(8)
            
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.black)
        }
    }
}

// Color Option Button
struct ColorOption: View {
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// Extension to support hex colors
// Removed duplicate Color extension - using the one from Color+Hex.swift instead

#Preview {
    VStack {
        Spacer()
        AnnotationSheet(
            isVisible: .constant(true),
            isTopMenuVisible: .constant(false)
        )
    }
} 
