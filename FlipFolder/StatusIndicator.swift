//
//  StatusIndicator.swift
//  FlipFolder App
//
//  Created by Adam Kuzma on 3/4/25.
//

import SwiftUI

enum StatusIndicatorState: Equatable {
    case noSong
    case loading(songTitle: String)
    case songOnly(songTitle: String)
    case performanceNoSong
    case performanceWithSong(songTitle: String, composer: String)
    
    static func == (lhs: StatusIndicatorState, rhs: StatusIndicatorState) -> Bool {
        switch (lhs, rhs) {
        case (.noSong, .noSong):
            return true
        case (.loading(let lTitle), .loading(let rTitle)):
            return lTitle == rTitle
        case (.songOnly(let lTitle), .songOnly(let rTitle)):
            return lTitle == rTitle
        case (.performanceNoSong, .performanceNoSong):
            return true
        case (.performanceWithSong(let lTitle, let lComposer), .performanceWithSong(let rTitle, let rComposer)):
            return lTitle == rTitle && lComposer == rComposer
        default:
            return false
        }
    }
    
    var label: String? {
        switch self {
        case .noSong, .loading, .songOnly:
            return nil
        case .performanceNoSong, .performanceWithSong:
            return "Performance Active"
        }
    }
    
    var title: String {
        switch self {
        case .noSong:
            return "No Song Playing"
        case .loading(let songTitle):
            return "Loading '\(songTitle)'"
        case .songOnly(let songTitle):
            return songTitle
        case .performanceNoSong:
            return "No Song Playing"
        case .performanceWithSong(let songTitle, let composer):
            return "\(songTitle), \(composer)"
        }
    }
    
    var indicatorColor: Color {
        switch self {
        case .noSong, .songOnly:
            return .gray
        case .loading:
            return .clear
        case .performanceNoSong, .performanceWithSong:
            return Color(hex: "#6B4EFF") // Purple color
        }
    }
    
    var showSpinner: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

struct StatusIndicator: View {
    let state: StatusIndicatorState
    @State private var isPressed = false
    var isLandscape: Bool = false
    
    private var isPerformanceActive: Bool {
        switch state {
        case .performanceNoSong, .performanceWithSong:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: isPerformanceActive ? 12 : 10) {
            // Left icon with transition
            Group {
                if state.showSpinner {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 14, height: 14)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.7).combined(with: .opacity),
                                removal: .scale(scale: 1.3).combined(with: .opacity)
                            )
                        )
                } else {
                    switch state {
                    case .performanceNoSong, .performanceWithSong:
                        PulsatingDot()
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.7).combined(with: .opacity),
                                    removal: .scale(scale: 1.3).combined(with: .opacity)
                                )
                            )
                    default:
                        Circle()
                            .fill(state.indicatorColor)
                            .frame(width: 7, height: 7)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.7).combined(with: .opacity),
                                    removal: .scale(scale: 1.3).combined(with: .opacity)
                                )
                            )
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: state)
            
            // Text content with transition
            VStack(alignment: .leading, spacing: isPerformanceActive ? 3 : 2) {
                if let label = state.label {
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .kerning(-0.2)
                        .foregroundColor(Color(red: 132/255, green: 123/255, blue: 139/255))
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            )
                        )
                }
                
                Text(state.title)
                    .font(.system(size: 13, weight: .semibold))
                    .kerning(-0.2)
                    .foregroundColor(Color(red: 69/255, green: 61/255, blue: 75/255))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: state)
            
            if state.label != nil && !isLandscape {
                Spacer()
            }
        }
        .frame(width: isLandscape ? nil : (state.label != nil ? 220 : nil))
        .padding(.vertical, 7)
        .padding(.horizontal, isPerformanceActive ? 0 : 14)
        .padding(.leading, isPerformanceActive ? 14 : 0)
        .padding(.trailing, isLandscape && isPerformanceActive ? 20 : 0)
        .background(.ultraThinMaterial)
        .cornerRadius(isPerformanceActive ? 12 : 16)
        .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: isPerformanceActive ? 12 : 16)
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: state)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
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
                }
        )
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    VStack(spacing: 20) {
        StatusIndicator(state: .noSong)
        StatusIndicator(state: .loading(songTitle: "Spring Concert"))
        StatusIndicator(state: .songOnly(songTitle: "Spring Concert"))
        StatusIndicator(state: .performanceNoSong)
        StatusIndicator(state: .performanceWithSong(songTitle: "Spring Concert", composer: "Composer Name"))
    }
    .padding()
}
