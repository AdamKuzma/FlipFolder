import SwiftUI

struct PageNavigator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 10) {
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    // Use current page index to determine styling
                    ZStack {
                        if index == currentPage {
                            // Current page - large white dot
                            Circle()
                                .fill(Color.white)
                                .frame(width: 20, height: 20)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                        } else {
                            // Other pages - small dark dot
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 5, height: 5)
                        }
                    }
                    .frame(width: 26, height: 26)
                    .contentShape(Rectangle())
                }
            }
            .frame(alignment: .center)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 3)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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
    }
}

#Preview {
    VStack(spacing: 20) {
        PageNavigator(currentPage: 0, totalPages: 2)
        PageNavigator(currentPage: 1, totalPages: 2)
        PageNavigator(currentPage: 0, totalPages: 5)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
} 