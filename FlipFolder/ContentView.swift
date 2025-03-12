//
//  ContentView.swift
//  FlipFolder
//
//  Created by Adam Kuzma on 3/4/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var isScrimVisible = false
    @State private var showingPerformanceNameAlert = false
    @State private var performanceName: String = ""
    @State private var currentPerformanceName: String? = nil
    @State private var isTopMenuVisible = true
    @State private var isPerformanceSheetPresented = false
    @State private var showToolsMenu = false
    @State private var showPartsMenu = false
    @State private var statusState: StatusIndicatorState = .noSong
    @State private var selectedSong: Song?
    @State private var popoverScale: CGFloat = 0
    @State private var toolsMenuScale: CGFloat = 0
    @State private var partsMenuScale: CGFloat = 0
    @State private var isMainViewLoading = false
    @State private var previousSongId: UUID?
    @State private var showSongsView = false
    @State private var selectedPart: InstrumentPart = .trumpets
    @State private var partToConfirm: InstrumentPart?
    @State private var showingPartConfirmation = false
    @State private var isAnnotationModeActive = false
    
    // Create AppState to share with MenuItemRow
    @StateObject private var appState = AppState()
    
    var body: some View {
        ZStack {
            // Main content
            mainContentView
            
            // Songs View with custom positioning
            songsView
            
            // Scrim and popup for New Performance
            performancePopover
            
            // Tools and Parts Menus with shared scrim
            menuOverlays
        }
        .alert("Performance Name", isPresented: $showingPerformanceNameAlert) {
            performanceNameAlert
        }
        .confirmationDialog(
            "Are you sure you want to change your part to \(partToConfirm?.rawValue ?? "")? This will replace all the currently downloaded songs.",
            isPresented: $showingPartConfirmation,
            titleVisibility: .visible
        ) {
            partConfirmationButtons
        } 
        .sheet(isPresented: $isPerformanceSheetPresented, onDismiss: {
            handlePerformanceSheetDismiss()
        }) {
            performanceSheet
        }
        .onReceive(NotificationCenter.default.publisher(for: .showPartsMenu)) { _ in
            handleShowPartsMenu()
        }
        .onReceive(NotificationCenter.default.publisher(for: .partSelected)) { notification in
            handlePartSelected(notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAnnotationTools)) { _ in
            handleShowAnnotationTools()
        }
        .environmentObject(appState)
        .onChange(of: selectedSong) { newSong in
            // Update AppState when selectedSong changes
            appState.selectedSong = newSong
        }
    }
    
    // MARK: - View Components
    
    private var mainContentView: some View {
        ZStack {
            MainView(
                selectedSong: $selectedSong, 
                isLoading: $isMainViewLoading, 
                isTopMenuVisible: $isTopMenuVisible,
                isAnnotationModeActive: $isAnnotationModeActive
            )
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onTapGesture {
                    // Only toggle top menu if not in annotation mode
                    if !isAnnotationModeActive {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isTopMenuVisible.toggle()
                        }
                    }
                }
                .offset(x: showSongsView ? 12 : 0)
                .opacity(showSongsView ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: showSongsView)
            
            // Overlaying TopMenu without affecting layout
            topMenuOverlay
        }
    }
    
    private var topMenuOverlay: some View {
        VStack {
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                VStack(spacing: 0) {
                    if isLandscape {
                        Spacer().frame(height: 8)
                    }
                    
                    // Only show the regular TopMenu when not in annotation mode
                    if !isAnnotationModeActive {
                        TopMenu(isScrimVisible: $isScrimVisible, showToolsMenu: $showToolsMenu, showSongsView: $showSongsView, statusState: $statusState)
                            .offset(y: isTopMenuVisible ? 0 : -10)
                            .opacity(isTopMenuVisible ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isTopMenuVisible)
                    }
                }
            }
            .frame(height: 80)
            
            Spacer()
        }
        .offset(x: showSongsView ? 12 : 0)
        .opacity(showSongsView ? 0 : 1)
        .animation(.easeInOut(duration: 0.2), value: showSongsView)
    }
    
    private var songsView: some View {
        SongsView(selectedSong: $selectedSong, isMainViewLoading: $isMainViewLoading, showSongsView: $showSongsView, statusState: $statusState)
            .offset(x: showSongsView ? 0 : -12)
            .opacity(showSongsView ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: showSongsView)
    }
    
    private var performancePopover: some View {
        Group {
            if isScrimVisible {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isScrimVisible = false
                            popoverScale = 0.1
                        }
                    }
                    .zIndex(10)
                
                VStack {
                    HStack(spacing: 12) {
                        if statusState.label == "Performance Active" {
                            
                        } else {
                            Image(systemName: "plus.circle")
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        
                        Text(statusState.label == "Performance Active" ? currentPerformanceName ?? "" : "New Performance")
                            .font(.body)
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .frame(width: 280)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 22)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .offset(y: statusState.label == "Performance Active" ? 72 : 60)
                    .scaleEffect(popoverScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            popoverScale = 1.0
                        }
                    }
                    .onTapGesture {
                        handlePerformancePopoverTap()
                    }
                    
                    Spacer()
                }
                .transition(.opacity)
                .zIndex(20)
            }
        }
    }
    
    private var menuOverlays: some View {
        Group {
            if showToolsMenu || showPartsMenu {
                // Shared scrim for both menus
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showToolsMenu = false
                            showPartsMenu = false
                            toolsMenuScale = 0.6
                            partsMenuScale = 0.6
                        }
                    }
                    .zIndex(10)
                
                // Tools Menu
                toolsMenuView
                
                // Parts Menu
                partsMenuView
            }
        }
    }
    
    private var toolsMenuView: some View {
        Group {
            if showToolsMenu {
                VStack {
                    VStack(spacing: 0) {
                        ForEach(ToolsMenuItem.allCases) { item in
                            MenuItemRow(item: item)
                            if item != ToolsMenuItem.allCases.last {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .frame(width: 225)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.6))
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .offset(y: 56)
                    .scaleEffect(toolsMenuScale, anchor: .topTrailing)
                    .onAppear {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            toolsMenuScale = 1.0
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 24)
                .transition(.opacity)
                .zIndex(20)
            }
        }
    }
    
    private var partsMenuView: some View {
        Group {
            if showPartsMenu {
                VStack {
                    VStack(spacing: 0) {
                        ForEach(InstrumentPart.allCases) { part in
                            PartItemRow(part: part, selectedPart: selectedPart)
                            if part != InstrumentPart.allCases.last {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .frame(width: 225)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.6))
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .offset(y: 56)
                    .scaleEffect(partsMenuScale, anchor: .topTrailing)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 24)
                .transition(.opacity)
                .zIndex(20)
            }
        }
    }
    
    private var performanceNameAlert: some View {
        VStack {
            TextField("Enter performance name", text: $performanceName)
            
            Button("Cancel", role: .cancel) {
                performanceName = ""
            }
            
            Button("Start") {
                startPerformance()
            }
            .disabled(performanceName.isEmpty)
        }
    }
    
    private var partConfirmationButtons: some View {
        Group {
            Button("Change to \(partToConfirm?.rawValue ?? "")") {
                confirmPartChange()
            }
            
            Button("Cancel", role: .cancel) {
                partToConfirm = nil
            }
        }
    }
    
    private var performanceSheet: some View {
        Group {
            if let name = currentPerformanceName {
                PerformanceView(
                    performanceName: name,
                    statusState: $statusState,
                    selectedSong: $selectedSong,
                    mainViewLoading: $isMainViewLoading
                )
            }
        }
    }
    
    // MARK: - Action Methods
    
    private func handlePerformancePopoverTap() {
        if statusState.label == "Performance Active" {
            isScrimVisible = false
            isPerformanceSheetPresented = true
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                isScrimVisible = false
                popoverScale = 0.1
            }
            showingPerformanceNameAlert = true
        }
    }
    
    private func startPerformance() {
        withAnimation {
            currentPerformanceName = performanceName
            isScrimVisible = false
            isPerformanceSheetPresented = true
            performanceName = ""
            if let song = selectedSong {
                statusState = .performanceWithSong(songTitle: song.title, composer: song.composer)
            } else {
                statusState = .performanceNoSong
            }
        }
    }
    
    private func handlePerformanceSheetDismiss() {
        // When sheet is dismissed, check if a new performance was started
        if let song = selectedSong, statusState != .performanceWithSong(songTitle: song.title, composer: song.composer) {
            // Only show loading if a song was changed or selected for the first time
            isMainViewLoading = true
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                statusState = .loading(songTitle: song.title)
            }
            
            // After 1 second, transition both states together
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isMainViewLoading = false
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    statusState = .performanceWithSong(songTitle: song.title, composer: song.composer)
                }
            }
        }
    }
    
    private func handleShowPartsMenu() {
        // First, just hide the tools menu but keep the scrim visible
        withAnimation(.easeInOut(duration: 0.2)) {
            toolsMenuScale = 0.6
        }
        
        // Small delay before showing parts menu
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Hide tools menu and show parts menu while keeping the scrim visible
            showToolsMenu = false
            showPartsMenu = true
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                partsMenuScale = 1.0
            }
        }
    }
    
    private func handlePartSelected(_ notification: Notification) {
        if let part = notification.object as? InstrumentPart {
            // Hide the parts menu
            withAnimation(.easeInOut(duration: 0.2)) {
                showPartsMenu = false
                partsMenuScale = 0.6
            }
            
            // Set the part to confirm and show confirmation dialog
            partToConfirm = part
            showingPartConfirmation = true
        }
    }
    
    private func confirmPartChange() {
        if let part = partToConfirm {
            // Update the selected part
            selectedPart = part
            
            // Store the current state before changing to loading
            let previousState = statusState
            
            // Show loading states
            isMainViewLoading = true
            
            // Determine the current song title for the loading state
            let songTitle: String
            if case .songOnly(let title) = statusState {
                songTitle = title
            } else if case .performanceWithSong(let title, _) = statusState {
                songTitle = title
            } else {
                songTitle = "Loading"
            }
            
            // Update status to loading
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                statusState = .loading(songTitle: songTitle)
            }
            
            // After a delay, return to the previous state
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Clear loading state
                isMainViewLoading = false
                
                // Return to the previous state with animation
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    // Restore the previous state
                    statusState = previousState
                }
            }
        }
    }
    
    private func handleShowAnnotationTools() {
        // Only activate annotation mode if a song is selected
        guard selectedSong != nil else { return }
        
        // Hide the tools menu
        withAnimation(.easeInOut(duration: 0.2)) {
            showToolsMenu = false
            toolsMenuScale = 0.6
        }
        
        // First, hide the top menu
        withAnimation(.easeInOut(duration: 0.2)) {
            isTopMenuVisible = false
        }
        
        // After the top menu is hidden, activate annotation mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnnotationModeActive = true
            }
        }
    }
}

// Performance Sheet
struct PerformanceSheet: View {
    var performanceName: String
    
    var body: some View {
        VStack {
            Text("Performance Started")
                .font(.title2)
                .padding()
            
            Text(performanceName)
                .font(.headline)
                .padding()
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}

