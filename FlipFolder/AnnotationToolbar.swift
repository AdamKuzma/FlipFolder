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
        VStack(spacing: 16) {
            // Handle indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 30, height: 5)
                .padding(.top, 8)
            
            // Annotation tools in new layout
            HStack {
                // Left side - Undo/Redo/Clear
                HStack(spacing: 4) {
                    AnnotationTool(icon: "arrow.uturn.backward", label: "Undo")
                    AnnotationTool(icon: "arrow.uturn.forward", label: "Redo")
                    AnnotationTool(icon: "trash", label: "Clear")
                }
                
                Spacer()
                
                // Right - Drawing tools
                HStack(spacing: 4) {
                    AnnotationTool(icon: "pencil", label: "Draw")
                    AnnotationTool(icon: "text.cursor", label: "Text")
                    AnnotationTool(icon: "eraser", label: "Erase")
                    ColorOption(color: selectedColor)
                    .frame(width: 36, height: 36)
                    .onTapGesture {
                        // Here you would show a color picker
                    }
                }  
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .frame(maxWidth: .infinity)
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
                .frame(width: 42, height: 42)
                //.background(Color.gray.opacity(0.1))
                .cornerRadius(8)
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