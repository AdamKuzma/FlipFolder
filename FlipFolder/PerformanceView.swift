//
//  PerformanceView.swift
//  FlipFolder
//
//  Created by Adam Kuzma on 3/6/25.
//

import SwiftUI

// Song List Component
struct Song: Identifiable, Equatable {
    let id: UUID
    let title: String
    let composer: String
    
    init(title: String, composer: String) {
        self.id = UUID()
        self.title = title
        self.composer = composer
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

struct SongGroup: Identifiable {
    let id = UUID()
    let letter: String
    let songs: [Song]
}

struct SongList: View {
    static let songGroups: [SongGroup] = [
        SongGroup(letter: "A", songs: [
            Song(title: "American Patrol", composer: "F.W. Meacham"),
            Song(title: "Amparito Roca", composer: "Jaime Texidor"),
            Song(title: "Armed Forces Medley", composer: "Traditional")
        ]),
        SongGroup(letter: "B", songs: [
            Song(title: "Blue and Gray", composer: "Clare Grundman"),
            Song(title: "British Eighth", composer: "Zo Elliott"),
            Song(title: "Barnum and Bailey's Favorite", composer: "Karl L. King")
        ]),
        SongGroup(letter: "C", songs: [
            Song(title: "Caravan", composer: "Duke Ellington"),
            Song(title: "Championship", composer: "Karl L. King"),
            Song(title: "Circus Days", composer: "Karl L. King")
        ]),
        SongGroup(letter: "D", songs: [
            Song(title: "Dixieland Jamboree", composer: "Karl L. King"),
            Song(title: "Dramatic Overture", composer: "Karl L. King"),
            Song(title: "Drum Corps on Parade", composer: "Karl L. King")
        ]),
        SongGroup(letter: "E", songs: [
            Song(title: "El Capitan", composer: "John Philip Sousa"),
            Song(title: "Emblem of Unity", composer: "Karl L. King"),
            Song(title: "Esprit de Corps", composer: "Robert Jager")
        ]),
        SongGroup(letter: "F", songs: [
            Song(title: "Fairest of the Fair", composer: "John Philip Sousa"),
            Song(title: "Festival Overture", composer: "Karl L. King"),
            Song(title: "Florentiner March", composer: "Julius Fučík")
        ]),
        SongGroup(letter: "G", songs: [
            Song(title: "Gallant Seventh", composer: "John Philip Sousa"),
            Song(title: "Glory of the Gridiron", composer: "Karl L. King"),
            Song(title: "Golden Jubilee", composer: "Karl L. King")
        ]),
        SongGroup(letter: "H", songs: [
            Song(title: "Hands Across the Sea", composer: "John Philip Sousa"),
            Song(title: "Her Majesty's Royal Marines", composer: "Traditional"),
            Song(title: "Highlights from Chicago", composer: "John Krance")
        ]),
        SongGroup(letter: "I", songs: [
            Song(title: "Imperial Edward", composer: "Karl L. King"),
            Song(title: "In Storm and Sunshine", composer: "J.J. Richards"),
            Song(title: "Invincible Eagle", composer: "John Philip Sousa")
        ]),
        SongGroup(letter: "J", songs: [
            Song(title: "Jazz Pizzicato", composer: "Leroy Anderson"),
            Song(title: "Jubilee", composer: "Karl L. King"),
            Song(title: "Jubilant Overture", composer: "Karl L. King")
        ])
    ]
    
    @Binding var selectedSong: Song?
    @Binding var isLoading: Bool
    @State private var songToConfirm: Song?
    @State private var showingSongConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(Self.songGroups) { group in
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
            }
            .padding(.horizontal, 25)
        }
        .confirmationDialog(
            "Would you like to play \"\(songToConfirm?.title ?? "")\"?",
            isPresented: $showingSongConfirmation,
            titleVisibility: .visible
        ) {
            Button("Yes") {
                if let song = songToConfirm {
                    selectedSong = song
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct PerformanceView: View {
    var performanceName: String
    @Environment(\.dismiss) private var dismiss
    @State private var showMenu = false
    @State private var isLoading = false
    @State private var showEndConfirmation = false
    @State private var isEndingPerformance = false
    @State private var selectedTab = 0 
    @Binding var statusState: StatusIndicatorState
    @Binding var selectedSong: Song?
    @Binding var mainViewLoading: Bool
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(Color(hex: "#5C5C5E"))
                        .frame(width: 32, height: 32)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Text("Performance")
                    .font(.custom("Futura", size: 22))
                    .foregroundColor(.primary)
                    .kerning(-0.8)
                Spacer()
                
                Menu {
                    Button(action: {
                        // Handle View Attendance
                    }) {
                        Label("View Attendance", systemImage: "person.3")
                    }
                    
                    Button(role: .destructive, action: {
                        showEndConfirmation = true
                    }) {
                        Label("End Performance", systemImage: "xmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: "#5C5C5E"))
                        .frame(width: 32, height: 32)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
            
            // Container for labeled values
            VStack(spacing: 12) {
                PerformanceRow(label: "Performance", value: performanceName)
                Divider()
                    .opacity(0.7)
                HStack {
                    Text("Playing Now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
                        .frame(maxWidth: CGFloat.infinity, alignment: .leading)
                    
                    Group {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 16, height: 16)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        } else {
                            HStack(spacing: 8) {
                                Image("PlayingNow")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text(selectedSong?.title ?? "No song playing")
                                    .font(.system(size: 16, weight: .semibold))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .frame(maxWidth: CGFloat.infinity, alignment: .trailing)
                }
                Divider()
                    .opacity(0.7)
                PerformanceRow(label: "Devices", value: "1", icon: "Device")
            }
            .padding()
            .background(Color(.systemGray5).opacity(0.5))
            .cornerRadius(12)
            .padding(.horizontal, 25)
            
            // Tab Toggle
            Picker("View Mode", selection: $selectedTab) {
                Text("Songs").tag(0)
                Text("Playlists").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 25)
            .padding(.bottom, 8)
            
            // Fixed container for tab content
            ZStack {
                // Content based on selected tab
                if selectedTab == 0 {
                    SongList(selectedSong: $selectedSong, isLoading: $isLoading)
                } else {
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
        .onChange(of: selectedSong) { oldSong, newSong in
            guard !isEndingPerformance else { return }
            
            if let newSong = newSong {
                isLoading = true
                mainViewLoading = true  // Start main view loading when song is selected
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    statusState = .loading(songTitle: newSong.title)  // Show loading in StatusIndicator
                }
                // Simulate loading delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false  // Only stop the PerformanceView loading
                }
            } else if oldSong != nil {
                // Only update to performanceNoSong if we're coming from a selected song
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    statusState = .performanceNoSong
                }
            }
        }
        .confirmationDialog(
            "Would you like to end the current performance?",
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("End", role: .destructive) {
                isEndingPerformance = true
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    statusState = .noSong
                }
                selectedSong = nil
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will close the current performance and return to the main view.")
        }
    }
}

// Reusable Row Component
struct PerformanceRow: View {
    var label: String
    var value: String
    var icon: String?
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
                .frame(maxWidth: CGFloat.infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                if label == "Performance" {
                    PulsatingDot()
                }
                
                if let icon = icon {
                    HStack(spacing: 8) {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text(value)
                            .font(.system(size: 16, weight: .semibold))
                    }
                } else {
                    Text(value)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: CGFloat.infinity, alignment: .trailing)
        }
    }
}

#Preview {
    PerformanceView(performanceName: "Spring Concert", statusState: .constant(.noSong), selectedSong: .constant(nil), mainViewLoading: .constant(false))
}
