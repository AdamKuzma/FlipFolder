import SwiftUI

struct SongsView: View {
    @Binding var selectedSong: Song?
    @Binding var isMainViewLoading: Bool
    @Binding var showSongsView: Bool
    @Binding var statusState: StatusIndicatorState
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var songToConfirm: Song?
    @State private var showingSongConfirmation = false
    
    // Performance name from ContentView
    @Binding var currentPerformanceName: String?
    
    // Check if a performance is active
    private var isPerformanceActive: Bool {
        if case .performanceNoSong = statusState { return true }
        if case .performanceWithSong = statusState { return true }
        return false
    }
    
    // Check if we have a performance name but haven't started the performance yet
    private var isPendingPerformance: Bool {
        return currentPerformanceName != nil && !isPerformanceActive
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            SongsHeader(showSongsView: $showSongsView, selectedTab: $selectedTab)
            
            // Songs header
            SongsTitle()
            
            // Search bar
            SearchBar(text: $searchText)
                .padding(.horizontal, 25)
            
            // Content based on selected tab
            ZStack {
                if selectedTab == 0 {
                    SongsList(
                        searchText: searchText,
                        selectedSong: selectedSong,
                        songToConfirm: $songToConfirm,
                        showingSongConfirmation: $showingSongConfirmation
                    )
                } else {
                    PlaylistsEmptyState()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(ColorTokens.surface)
        .confirmationDialog(
            isPerformanceActive 
                ? "Would you like to change the song to \"\(songToConfirm?.title ?? "")\"?"
                : "Would you like to play \"\(songToConfirm?.title ?? "")\"?",
            isPresented: $showingSongConfirmation,
            titleVisibility: .visible
        ) {
            Button(isPerformanceActive ? "Change Song" : "Play") {
                handleSongSelection()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func handleSongSelection() {
        if let song = songToConfirm {
            selectedSong = song
            isMainViewLoading = true
            
            // Update status based on whether performance is active or pending
            if isPerformanceActive {
                handleActivePerformanceSelection(song)
            } else if isPendingPerformance {
                handlePendingPerformanceSelection(song)
            } else {
                handleNoPerformanceSelection(song)
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showSongsView = false
            }
        }
    }
    
    private func handleActivePerformanceSelection(_ song: Song) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            statusState = .loading(songTitle: song.title)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if case .performanceWithSong(_, let composer) = statusState {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    statusState = .performanceWithSong(songTitle: song.title, composer: composer)
                }
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    statusState = .performanceWithSong(songTitle: song.title, composer: song.composer)
                }
            }
            isMainViewLoading = false
        }
    }
    
    private func handlePendingPerformanceSelection(_ song: Song) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            statusState = .loading(songTitle: song.title)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                statusState = .performanceWithSong(songTitle: song.title, composer: song.composer)
            }
            isMainViewLoading = false
        }
    }
    
    private func handleNoPerformanceSelection(_ song: Song) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            statusState = .loading(songTitle: song.title)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                statusState = .songOnly(songTitle: song.title)
            }
            isMainViewLoading = false
        }
    }
}

// MARK: - Subcomponents

struct SongsHeader: View {
    @Binding var showSongsView: Bool
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSongsView = false
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(Color(hex: "#5C5C5E"))
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Picker("View Mode", selection: $selectedTab) {
                Text("Songs").tag(0)
                Text("Playlists").tag(1)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            
            Spacer()
            
            Color.clear
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, 25)
        .padding(.top, 20)
    }
}

struct SongsTitle: View {
    var body: some View {
        HStack {
            Text("Songs")
                .font(.custom("Futura", size: 22))
                .foregroundColor(.primary)
                .kerning(-0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 25)
    }
}

struct SongsList: View {
    let searchText: String
    let selectedSong: Song?
    @Binding var songToConfirm: Song?
    @Binding var showingSongConfirmation: Bool
    
    private var filteredSongGroups: [SongGroup] {
        if searchText.isEmpty {
            return SongList.songGroups
        }
        return SongList.songGroups.map { group in
            SongGroup(
                letter: group.letter,
                songs: group.songs.filter { 
                    $0.title.lowercased().contains(searchText.lowercased()) ||
                    $0.composer.lowercased().contains(searchText.lowercased())
                }
            )
        }.filter { !$0.songs.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(filteredSongGroups) { group in
                    SongGroupView(
                        group: group,
                        selectedSong: selectedSong,
                        songToConfirm: $songToConfirm,
                        showingSongConfirmation: $showingSongConfirmation
                    )
                }
                
                if filteredSongGroups.isEmpty {
                    EmptySearchState()
                }
            }
            .padding(.horizontal, 25)
        }
    }
}

struct SongGroupView: View {
    let group: SongGroup
    let selectedSong: Song?
    @Binding var songToConfirm: Song?
    @Binding var showingSongConfirmation: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(group.letter)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
            
            VStack(spacing: 0) {
                ForEach(group.songs) { song in
                    SongRow(
                        song: song,
                        isSelected: selectedSong?.id == song.id,
                        songToConfirm: $songToConfirm,
                        showingSongConfirmation: $showingSongConfirmation
                    )
                    
                    if song.id != group.songs.last?.id {
                        Divider()
                    }
                }
            }
            .cornerRadius(12)
        }
    }
}

struct SongRow: View {
    let song: Song
    let isSelected: Bool
    @Binding var songToConfirm: Song?
    @Binding var showingSongConfirmation: Bool
    
    var body: some View {
        Button(action: {
            songToConfirm = song
            showingSongConfirmation = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(ColorTokens.label)
                    Text(song.composer)
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#6B4EFF"))
                        .font(.system(size: 20))
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct EmptySearchState: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("No songs found")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.gray)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PlaylistsEmptyState: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image("Empty")
                .padding(.bottom, 16)
                .padding(.top, 40)
            
            Text("No playlists yet")
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
            
            Text("Create a playlist to organize your songs.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(red: 132/255, green: 132/255, blue: 132/255))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 46)
    }
}

// Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ColorTokens.caption.opacity(0.6))
            
            TextField("Search songs", text: $text)
                .foregroundColor(.primary)
                .tint(ColorTokens.caption.opacity(0.6))
                .placeholder(when: text.isEmpty) {
                    Text("Search songs")
                        .foregroundColor(ColorTokens.caption.opacity(0.6))
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorTokens.caption.opacity(0.6))
                }
            }
        }
        .padding(10)
        .background(Color(ColorTokens.backgroundSecondary))
        .cornerRadius(10)
    }
}

// Helper ViewModifier for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    SongsView(selectedSong: .constant(nil), isMainViewLoading: .constant(false), showSongsView: .constant(true), statusState: .constant(.performanceNoSong), currentPerformanceName: .constant(nil))
} 
