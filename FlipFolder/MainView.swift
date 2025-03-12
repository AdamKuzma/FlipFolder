//
//  MainView.swift
//  FlipFolder
//
//  Created by Adam Kuzma on 3/6/25.
//

import SwiftUI
import PDFKit

// Shared zoom manager to synchronize zoom across all PDF pages
class PDFZoomManager: ObservableObject {
    @Published var scale: CGFloat = 1.0
    static let shared = PDFZoomManager()
    
    private init() {}
    
    func resetZoom() {
        scale = 1.0
    }
}

// A UIKit-based zoomable scroll view that can contain any SwiftUI content
struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    @Binding var currentZoom: CGFloat
    private var content: Content
    @ObservedObject private var zoomManager = PDFZoomManager.shared
    
    init(currentZoom: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self._currentZoom = currentZoom
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        // Set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.backgroundColor = .white
        
        // Create a UIHostingController to host our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .white
        
        // Add the hosting view to the scroll view
        scrollView.addSubview(hostedView)
        
        // Set up constraints to make the hosted view fill the scroll view
        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // This ensures the content is at least as wide as the scroll view
            hostedView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        // Add double tap gesture for quick zoom
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // Set initial zoom from manager
        scrollView.zoomScale = zoomManager.scale
        currentZoom = zoomManager.scale
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // Update the SwiftUI content if needed
        context.coordinator.hostingController.rootView = content
        
        // Update zoom scale if it changed externally
        if abs(scrollView.zoomScale - currentZoom) > 0.01 {
            scrollView.setZoomScale(currentZoom, animated: false)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableScrollView
        var hostingController: UIHostingController<Content>
        
        init(_ parent: ZoomableScrollView) {
            self.parent = parent
            self.hostingController = UIHostingController(rootView: parent.content)
            self.hostingController.view.backgroundColor = .white
            super.init()
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // Update the current zoom
            parent.currentZoom = scrollView.zoomScale
            parent.zoomManager.scale = scrollView.zoomScale
            
            // Center content if smaller than the scroll view
            let offsetX = max((scrollView.bounds.width - hostingController.view.frame.width * scrollView.zoomScale) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - hostingController.view.frame.height * scrollView.zoomScale) * 0.5, 0)
            
            scrollView.contentInset = UIEdgeInsets(
                top: offsetY,
                left: offsetX,
                bottom: offsetY,
                right: offsetX
            )
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else { return }
            
            if scrollView.zoomScale > scrollView.minimumZoomScale + 0.1 {
                // If zoomed in, zoom out
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                // If zoomed out, zoom in to a reasonable level
                let zoomScale = min(2.5, scrollView.maximumZoomScale)
                
                // Get the location of the tap
                let location = gesture.location(in: scrollView)
                
                // Calculate the zoom rect
                let size = CGSize(
                    width: scrollView.bounds.width / zoomScale,
                    height: scrollView.bounds.height / zoomScale
                )
                let origin = CGPoint(
                    x: location.x - size.width / 2,
                    y: location.y - size.height / 2
                )
                let zoomRect = CGRect(origin: origin, size: size)
                
                // Zoom to the tapped area
                scrollView.zoom(to: zoomRect, animated: true)
            }
            
            // Update the zoom manager after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.parent.currentZoom = scrollView.zoomScale
                self.parent.zoomManager.scale = scrollView.zoomScale
            }
        }
    }
}

// Simple PDF view without custom zooming
struct PDFPageView: UIViewRepresentable {
    let pageNumber: Int
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .white
        pdfView.pageShadowsEnabled = false
        
        // Disable individual page zooming and interaction
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.maxScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.isUserInteractionEnabled = false
        
        // Try to load PDF directly from the Resources folder
        let pdfName = "Page\(pageNumber)"
        if let resourcePath = Bundle.main.resourcePath {
            let possiblePaths = [
                (resourcePath as NSString).appendingPathComponent("\(pdfName).pdf"),
                (resourcePath as NSString).appendingPathComponent("Resources/\(pdfName).pdf"),
                Bundle.main.path(forResource: pdfName, ofType: "pdf"),
                Bundle.main.path(forResource: pdfName, ofType: "pdf", inDirectory: "Resources")
            ].compactMap { $0 }
            
            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    if let document = PDFDocument(url: URL(fileURLWithPath: path)) {
                        pdfView.document = document
                        break
                    }
                }
            }
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.pageShadowsEnabled = false
        
        // Ensure zoom is disabled
        uiView.minScaleFactor = uiView.scaleFactorForSizeToFit
        uiView.maxScaleFactor = uiView.scaleFactorForSizeToFit
        uiView.isUserInteractionEnabled = false
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
        .frame(height: 500) // Match the height of PDFPageView
    }
}

struct MainView: View {
    @Binding var selectedSong: Song?
    @Binding var isLoading: Bool
    @StateObject private var zoomManager = PDFZoomManager.shared
    @State private var currentZoom: CGFloat = 1.0
    @Binding var isTopMenuVisible: Bool
    @Binding var isAnnotationModeActive: Bool
    @State private var showAnnotationSheet: Bool = false
    
    var body: some View {
        Group {
            if selectedSong != nil {
                ZStack(alignment: .bottom) {
                    ZoomableScrollView(currentZoom: $currentZoom) {
                        ZStack(alignment: .top) {
                            // Content
                            VStack(spacing: 0) {
                                if isLoading {
                                    VStack(spacing: 0) {
                                        LoadingPage()
                                        LoadingPage()
                                    }
                                } else {
                                    PDFPageView(pageNumber: 1)
                                        .frame(width: UIScreen.main.bounds.width, height: 500)
                                        .transition(.asymmetric(
                                            insertion: .offset(y: 10).combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                        .padding(.top, 25)
                                    
                                    PDFPageView(pageNumber: 2)
                                        .frame(width: UIScreen.main.bounds.width, height: 500)
                                        .transition(.asymmetric(
                                            insertion: .offset(y: 10).combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                }
                            }
                            .animation(.easeOut(duration: 0.3), value: isLoading)
                            
                            // Title section overlay
                            if let song = selectedSong, !isLoading {
                                VStack(spacing: 8) {
                                    Text(song.title)
                                        .font(.custom("TiroBangla-Regular", size: 19))
                                        .foregroundColor(Color(hex: "#1C1B1F"))
                                        .frame(maxWidth: .infinity)
                                    
                                    Text(song.composer)
                                        .font(.custom("TiroBangla-Italic", size: 7))
                                        .fontDesign(.serif)
                                        .italic()
                                        .foregroundColor(Color(hex: "#1C1B1F"))
                                        .kerning(-0.3)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding(.horizontal, 25)
                                .padding(.top, 40)
                                .padding(.bottom, 20)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white,
                                            Color.white.opacity(0)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 120)
                                )
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .offset(y: 5)),
                                    removal: .opacity
                                ))
                            }
                        }
                        .padding(.top, 100)
                        .frame(width: UIScreen.main.bounds.width)
                    }
                    .background(Color.white)
                    .onAppear {
                        // Initialize zoom from manager
                        currentZoom = zoomManager.scale
                    }
                    .onDisappear {
                        // Save zoom to manager
                        zoomManager.scale = currentZoom
                    }
                    
                    // Annotation Sheet
                    if showAnnotationSheet {
                        AnnotationSheet(isVisible: $isAnnotationModeActive, isTopMenuVisible: $isTopMenuVisible)
                            .transition(.move(edge: .bottom))
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
                    Image("Empty")
                        .padding(.bottom, 16)
                    
                    Text("No song selected")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
                        .padding(.bottom, 4)
                    
                    Text("Start a performance or select a song from the menu above to display sheet music.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 132/255, green: 132/255, blue: 132/255))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 46)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .ignoresSafeArea(.keyboard, edges: .bottom)
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
            isAnnotationModeActive: .constant(false)
        )
        MainView(
            selectedSong: .constant(Song(title: "Preview Song", composer: "Preview Composer")), 
            isLoading: .constant(false), 
            isTopMenuVisible: .constant(true),
            isAnnotationModeActive: .constant(false)
        )
    }
}
