//
//  TopMenu.swift
//  FlipFolder
//
//  Created by Adam Kuzma on 3/6/25.
//

import SwiftUI

struct TopMenu: View {
    
    @Binding var isScrimVisible: Bool
    @Binding var showToolsMenu: Bool
    @Binding var showSongsView: Bool
    @Binding var statusState: StatusIndicatorState
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            HStack(alignment: .top, spacing: 5) {
                NavItem(imageName: "Music", showToolsMenu: $showToolsMenu, showSongsView: $showSongsView)
                
                Spacer()
                
                StatusIndicator(state: statusState, isLandscape: isLandscape)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isScrimVisible = true
                        }
                    }
                
                Spacer()
                
                NavItem(imageName: "Tools", showToolsMenu: $showToolsMenu, showSongsView: $showSongsView)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.clear)
        }
    }
}

