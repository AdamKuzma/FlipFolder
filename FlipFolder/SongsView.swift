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
    
    // Check if a performance is active
    private var isPerformanceActive: Bool {
        if case .performanceNoSong = statusState { return true }
        if case .performanceWithSong = statusState { return true }
        return false
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Header with back button and tabs
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
                
                // Tab Toggle
                Picker("View Mode", selection: $selectedTab) {
                    Text("Songs").tag(0)
                    Text("Playlists").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                
                Spacer()
                
                // Empty view to balance the layout
                Color.clear
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
            
            // Songs header
            HStack {
                Text("Songs")
                    .font(.custom("Futura", size: 22))
                    .foregroundColor(.primary)
                    .kerning(-0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 25)
            
            // Search bar
            SearchBar(text: $searchText)
                .padding(.horizontal, 25)
            
            // Content based on selected tab
            ZStack {
                if selectedTab == 0 {
                    // Filter songs based on search text
                    let filteredSongGroups = searchText.isEmpty 
                        ? SongList.songGroups 
                        : SongList.songGroups.map { group in
                            SongGroup(
                                letter: group.letter,
                                songs: group.songs.filter { 
                                    $0.title.lowercased().contains(searchText.lowercased()) ||
                                    $0.composer.lowercased().contains(searchText.lowercased())
                                }
                            )
                        }.filter { !$0.songs.isEmpty }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(filteredSongGroups) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.letter)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
                                    
                                    VStack(spacing: 0) {
                                        ForEach(group.songs) { song in
                                            Button(action: {
                                                songToConfirm = song
                                                showingSongConfirmation = true
                                            }) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(song.title)
                                                            .font(.system(size: 15, weight: .medium))
                                                            .foregroundColor(.black)
                                                        Text(song.composer)
                                                            .font(.system(size: 13))
                                                            .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    if selectedSong?.id == song.id {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(Color(hex: "#6B4EFF"))
                                                            .font(.system(size: 20))
                                                    }
                                                }
                                                .padding(.vertical, 8)
                                            }
                                            
                                            if song.id != group.songs.last?.id {
                                                Divider()
                                            }
                                        }
                                    }
                                    .cornerRadius(12)
                                }
                            }
                            
                            if filteredSongGroups.isEmpty {
                                VStack(spacing: 20) {
                                    Text("No songs found")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.gray)
                                        .padding(.top, 40)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                } else {
                    // Playlists tab (empty state)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 251/255, green: 251/255, blue: 254/255))
        .confirmationDialog(
            isPerformanceActive 
                ? "Would you like to change the song to \"\(songToConfirm?.title ?? "")\"?"
                : "Would you like to play \"\(songToConfirm?.title ?? "")\"?",
            isPresented: $showingSongConfirmation,
            titleVisibility: .visible
        ) {
            Button(isPerformanceActive ? "Change Song" : "Play") {
                if let song = songToConfirm {
                    selectedSong = song
                    isMainViewLoading = true
                    
                    // Update status based on whether performance is active
                    if isPerformanceActive {
                        // If performance is active, update to loading then performance with song
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            statusState = .loading(songTitle: song.title)
                        }
                        
                        // After a delay, update to performanceWithSong state and clear loading
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            if case .performanceWithSong(_, let composer) = statusState {
                                // If we already have a performance with a song, keep the composer
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    statusState = .performanceWithSong(songTitle: song.title, composer: composer)
                                }
                            } else {
                                // Otherwise, use the song's composer
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    statusState = .performanceWithSong(songTitle: song.title, composer: song.composer)
                                }
                            }
                            isMainViewLoading = false
                        }
                    } else {
                        // If no performance, update to loading then song only
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            statusState = .loading(songTitle: song.title)
                        }
                        
                        // After a delay, update to songOnly state and clear loading
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                statusState = .songOnly(songTitle: song.title)
                            }
                            isMainViewLoading = false
                        }
                    }
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSongsView = false
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search songs", text: $text)
                .foregroundColor(.primary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    SongsView(selectedSong: .constant(nil), isMainViewLoading: .constant(false), showSongsView: .constant(true), statusState: .constant(.performanceNoSong))
} 