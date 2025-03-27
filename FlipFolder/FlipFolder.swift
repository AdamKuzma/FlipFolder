//
//  FlipFolder_AppApp.swift
//  FlipFolder App
//
//  Created by Adam Kuzma on 3/4/25.
//

import SwiftUI
import UIKit
import CoreGraphics
import CoreText

@main
struct FlipFolderApp: App {
    init() {
        // Register fonts
        registerFonts()
        
        // Print all registered fonts
        print("\n=== All Available Fonts ===")
        for family in UIFont.familyNames.sorted() {
            print("\nFamily: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   Font: \(name)")
            }
        }
    }
    
    private func registerFonts() {
        guard let fontURLs = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else { 
            print("❌ No font files found in bundle")
            return 
        }
        
        print("\n=== Found Font Files ===")
        for url in fontURLs {
            print("Found font file: \(url.lastPathComponent)")
            do {
                let data = try Data(contentsOf: url)
                if let provider = CGDataProvider(data: data as CFData),
                   let font = CGFont(provider) {
                    var error: Unmanaged<CFError>?
                    if CTFontManagerRegisterGraphicsFont(font, &error) {
                        if let postScriptName = font.postScriptName {
                            print("✅ Font registered: \(url.lastPathComponent)")
                            print("   PostScript name: \(postScriptName)")
                        }
                    } else {
                        if let err = error?.takeRetainedValue() {
                            print("❌ Error registering font: \(err)")
                        }
                    }
                }
            } catch {
                print("❌ Error loading font: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
