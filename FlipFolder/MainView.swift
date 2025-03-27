//
//  MainView.swift
//  FlipFolder
//
//  Created by Adam Kuzma on 3/6/25.
//

import SwiftUI

// Shared zoom manager to synchronize zoom across all pages
class ImageZoomManager: ObservableObject {
    @Published var scale: CGFloat = 1.0
    static let shared = ImageZoomManager()
    
    private init() {}
    
    func resetZoom() {
        scale = 1.0
    }
}

// Simple image page view for displaying song sheets
struct PageView: View {
    let pageNumber: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        // Try to load image from resources
        if let image = loadPageImage() {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .background(ColorTokens.surface)
        } else {
            // Fallback if image cannot be loaded
            Rectangle()
                .fill(ColorTokens.surface)
                .overlay(
                    Text("Page \(pageNumber) not found")
                        .foregroundColor(.gray)
                )
        }
    }
    
    private func loadPageImage() -> UIImage? {
        let imageName = colorScheme == .dark ? "Page\(pageNumber)-Dark" : "Page\(pageNumber)"
        
        // Try to load from bundle
        if let image = UIImage(named: imageName) {
            return image
        }
        
        // Try to load from Resources folder
        if let resourcePath = Bundle.main.resourcePath {
            let possiblePaths = [
                (resourcePath as NSString).appendingPathComponent("\(imageName).png"),
                (resourcePath as NSString).appendingPathComponent("Resources/\(imageName).png"),
                Bundle.main.path(forResource: imageName, ofType: "png"),
                Bundle.main.path(forResource: imageName, ofType: "png", inDirectory: "Resources")
            ].compactMap { $0 }
            
            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    if let image = UIImage(contentsOfFile: path) {
                        return image
                    }
                }
            }
        }
        
        return nil
    }
}

struct LoadingLine: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(hex: isAnimating ? "#F7F7F7" : "#E8E8E8"))
            .frame(height: 2)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 0.7)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct LoadingGroup: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                LoadingLine()
            }
        }
        .padding(.horizontal, 40)
    }
}

struct LoadingPage: View {
    var body: some View {
        VStack(spacing: 24) {
            ForEach(0..<5, id: \.self) { _ in
                LoadingGroup()
            }
        }
        .frame(height: 500) // Standard height for page views
    }
}

struct MainView: View {
    @Binding var selectedSong: Song?
    @Binding var isLoading: Bool
    @StateObject private var zoomManager = ImageZoomManager.shared
    @State private var currentZoom: CGFloat = 1.0
    @Binding var isTopMenuVisible: Bool
    @Binding var isAnnotationModeActive: Bool
    @Binding var currentPerformanceName: String?
    @State private var showAnnotationSheet: Bool = false
    @State private var currentPage: Int = 0
    @State private var totalPages: Int = 3
    @State private var orientationChanged = false // Track orientation changes
    @Environment(\.colorScheme) private var colorScheme
    
    // Double-tap gesture state
    @State private var lastDoubleTapLocation: CGPoint = .zero
    
    // For ScrollView position tracking
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    
    private var emptyImageName: String {
        colorScheme == .dark ? "Empty-Dark" : "Empty"
    }
    
    var body: some View {
        Group {
            if selectedSong != nil {
                ZStack(alignment: .bottom) {
                    // Use ScrollView with magnification gesture
                    ScrollView(.vertical, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            ZStack(alignment: .top) {
                                // Content
                                VStack(spacing: 0) {
                                    if isLoading {
                                        VStack(spacing: 0) {
                                            Spacer().frame(height: 60) // Move padding here
                                            LoadingPage()
                                            LoadingPage()
                                            LoadingPage()
                                        }
                                        .padding(.top, 80)
                                        .id("top")
                                    } else {
                                        // Add a spacer at the top to push content below status bar
                                        Spacer().frame(height: {
                                            // Get safe area insets in a safe way
                                            let scenes = UIApplication.shared.connectedScenes
                                            let windowScene = scenes.first as? UIWindowScene
                                            return (windowScene?.windows.first?.safeAreaInsets.top ?? 0) + 60 // Add the 60 points here
                                        }())
                                        .id("top")
                                        
                                        VStack(spacing: 0) {
                                            // Title section
                                            if let song = selectedSong {
                                                VStack(spacing: 8) {
                                                    Text(song.title)
                                                        .font(.custom("TiroBangla-Regular", size: 19))
                                                        .foregroundColor(ColorTokens.primary)
                                                        .frame(maxWidth: .infinity)
                                                    
                                                    Text(song.composer)
                                                        .font(.custom("TiroBangla-Italic", size: 8))
                                                        .fontDesign(.serif)
                                                        .italic()
                                                        .foregroundColor(ColorTokens.primary)
                                                        .kerning(-0.3)
                                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                                }
                                                .padding(.horizontal, 25)
                                                .padding(.top, 40)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            ColorTokens.surface,
                                                            ColorTokens.surface.opacity(0)
                                                        ]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                    .frame(height: 120)
                                                )
                                            }
                                            
                                            // PNG Pages
                                            VStack(spacing: 25) {
                                                PageView(pageNumber: 1)
                                                    .frame(maxWidth: .infinity)
                                                    .transition(.asymmetric(
                                                        insertion: .offset(y: 10).combined(with: .opacity),
                                                        removal: .opacity
                                                    ))
                                                    .id("page0")
                                                    .onAppear { currentPage = 0 }
                                                    
                                                PageView(pageNumber: 2)
                                                    .frame(maxWidth: .infinity)
                                                    .transition(.asymmetric(
                                                        insertion: .offset(y: 10).combined(with: .opacity),
                                                        removal: .opacity
                                                    ))
                                                    .id("page1")
                                                    .onAppear { currentPage = 1 }
                                                    
                                                PageView(pageNumber: 3)
                                                    .frame(maxWidth: .infinity)
                                                    .transition(.asymmetric(
                                                        insertion: .offset(y: 10).combined(with: .opacity),
                                                        removal: .opacity
                                                    ))
                                                    .id("page2")
                                                    .onAppear { currentPage = 2 }
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.bottom, 60)
                                        }
                                    }
                                }
                                .frame(maxWidth: 770, alignment: .center)  // Single maxWidth constraint for everything
                                .animation(.easeOut(duration: 0.3), value: isLoading)
                                
                            }
                            .frame(maxWidth: .infinity)  // Remove the .padding(.top, 60)
                            .onAppear {
                                // Store scroll view proxy for later use
                                self.scrollViewProxy = proxy
                            }
                        }
                    }
                    // Apply magnification gesture for zoom
                    .scaleEffect(currentZoom)
                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: currentZoom)
                    .onChange(of: selectedSong) { oldValue, newValue in
                        // Reset zoom when song changes
                        if oldValue?.id != newValue?.id {
                            withAnimation(.spring(response: 0.3)) {
                                zoomManager.resetZoom()
                                currentZoom = 1.0
                            }
                            // Scroll to top immediately without animation
                            scrollViewProxy?.scrollTo("top", anchor: .top)
                        }
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                // Limit zoom range with smoother updating
                                let proposedZoom = min(max(zoomManager.scale * value, 1.0), 5.0)
                                // Apply with slight damping for smoother feel
                                currentZoom = currentZoom + (proposedZoom - currentZoom) * 0.8
                            }
                            .onEnded { _ in
                                // Snap to bounds if needed
                                if currentZoom < 1.1 {
                                    withAnimation(.spring(response: 0.3)) {
                                        currentZoom = 1.0
                                    }
                                } else if currentZoom > 4.9 {
                                    withAnimation(.spring(response: 0.3)) {
                                        currentZoom = 5.0
                                    }
                                }
                                
                                // Finalize zoom
                                zoomManager.scale = currentZoom
                            }
                    )
                    // Add double tap gesture for quick zoom
                    .gesture(
                        TapGesture(count: 2)
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    if currentZoom > 1.5 {
                                        // Reset zoom
                                        currentZoom = 1.0
                                    } else {
                                        // Zoom in
                                        currentZoom = 2.0
                                    }
                                    // Update manager after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                        zoomManager.scale = currentZoom
                                    }
                                }
                            }
                    )
                    .background(ColorTokens.surface)
                    .ignoresSafeArea(.all)
                    .onAppear {
                        // Initialize zoom from manager
                        currentZoom = zoomManager.scale
                    }
                    .onDisappear {
                        // Save zoom to manager
                        zoomManager.scale = currentZoom
                    }
                    .id("scroll-container-\(orientationChanged)") // Force recreation when orientation changes
                    
                    // Page Navigator at the bottom
                    if !isLoading && !isAnnotationModeActive {
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                PageNavigator(currentPage: currentPage, totalPages: totalPages)
                                Spacer()
                            }
                            .padding(.bottom, {
                                let scenes = UIApplication.shared.connectedScenes
                                let windowScene = scenes.first as? UIWindowScene
                                return (windowScene?.windows.first?.safeAreaInsets.bottom ?? 0) + 6
                            }())
                            .opacity(isTopMenuVisible ? 1 : 0)
                            .offset(y: isTopMenuVisible ? 0 : 20) // Move down when hidden
                            .animation(.easeInOut(duration: 0.2), value: isTopMenuVisible)
                        }
                        .ignoresSafeArea(.keyboard)
                        .zIndex(50) // Increased zIndex to ensure it appears above bottom gradient
                    }
                    
                    // Annotation Sheet
                    if showAnnotationSheet {
                        ZStack {
                            AnnotationSheet(isVisible: $isAnnotationModeActive, isTopMenuVisible: $isTopMenuVisible)
                                .transition(.move(edge: .bottom))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .ignoresSafeArea()
                    }
                }
                
                // Add Annotation Top Menu overlay when in annotation mode
                .overlay(
                    VStack {
                        if isAnnotationModeActive {
                            AnnotationTopMenu(
                                isAnnotationModeActive: $isAnnotationModeActive,
                                isTopMenuVisible: $isTopMenuVisible
                            )
                                .frame(height: 80)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                        }
                        Spacer()
                    }
                )
                // Add top edge gradient overlay
                .overlay(
                    VStack {
                        // Top gradient overlay that fades the music sheets with blur
                        ZStack {
                            // Gradient background
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    ColorTokens.surface,
                                    ColorTokens.surface.opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Progressive blur overlay
                            VStack(spacing: 0) {
                                ForEach(0..<8) { index in
                                    ColorTokens.surface
                                        .opacity(0.2 - (Double(index) * 0.025))
                                        .blur(radius: 6.0 - (Double(index) * 0.6))
                                        .frame(height: 10)
                                }
                            }
                        }
                        .frame(height: 80)
                        .allowsHitTesting(false) // Allow taps to pass through
                        
                        Spacer()
                    }
                    .ignoresSafeArea(.all, edges: .top),
                    alignment: .top
                )
                // Add bottom edge gradient overlay
                .overlay(
                    VStack {
                        Spacer()
                        
                        // Bottom gradient overlay that fades the music sheets with blur
                        ZStack {
                            // Gradient background
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    ColorTokens.surface.opacity(0),
                                    ColorTokens.surface
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Progressive blur overlay
                            VStack(spacing: 0) {
                                ForEach(0..<8) { index in
                                    ColorTokens.surface
                                        .opacity(0.025 + (Double(index) * 0.025))
                                        .blur(radius: 0.6 + (Double(index) * 0.6))
                                        .frame(height: 10)
                                }
                            }
                        }
                        .frame(height: 80)
                        .allowsHitTesting(false) // Allow taps to pass through
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                    .zIndex(40), // Ensure it's below the PageNavigator but above other content
                    alignment: .bottom
                )
                .ignoresSafeArea(.all)
                .onChange(of: isAnnotationModeActive) { newValue in
                    if newValue {
                        // When annotation mode is activated, show the annotation sheet after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAnnotationSheet = true
                            }
                        }
                    } else {
                        // When annotation mode is deactivated, hide the annotation sheet immediately
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAnnotationSheet = false
                        }
                    }
                }
            } else {
                VStack(alignment: .center, spacing: 12) {
                    Image(emptyImageName)
                        .padding(.bottom, 16)
                    
                    Text("No song selected")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(ColorTokens.quaternary)
                        .padding(.bottom, 4)
                    
                    Text("Start a performance or select a song from the menu above to display sheet music.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(ColorTokens.caption)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 46)
                .background(ColorTokens.surface)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            // Toggle the orientation flag to force view recreation
            orientationChanged.toggle()
            
            // Reset zoom to ensure proper content fit
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                zoomManager.resetZoom()
                currentZoom = 1.0
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MainView(
            selectedSong: .constant(nil), 
            isLoading: .constant(false), 
            isTopMenuVisible: .constant(true),
            isAnnotationModeActive: .constant(false),
            currentPerformanceName: .constant(nil)
        )
        MainView(
            selectedSong: .constant(Song(title: "Preview Song", composer: "Preview Composer")), 
            isLoading: .constant(false), 
            isTopMenuVisible: .constant(true),
            isAnnotationModeActive: .constant(false),
            currentPerformanceName: .constant(nil)
        )
    }
}
