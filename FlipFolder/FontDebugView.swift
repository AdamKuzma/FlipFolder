import SwiftUI

struct FontDebugView: View {
    var body: some View {
        List {
            Section(header: Text("Available Font Families")) {
                ForEach(UIFont.familyNames.sorted(), id: \.self) { familyName in
                    Section(header: Text(familyName)) {
                        ForEach(UIFont.fontNames(forFamilyName: familyName).sorted(), id: \.self) { fontName in
                            Text(fontName)
                                .font(.custom(fontName, size: 14))
                        }
                    }
                }
            }
            
            Section(header: Text("Futura Font Tests")) {
                Group {
                    Text("This is Futura-Book font")
                        .font(.custom("Futura-Book", size: 16))
                    
                    Text("This is FuturaBook font")
                        .font(.custom("FuturaBook", size: 16))
                    
                    Text("This is Futura Book font")
                        .font(.custom("Futura Book", size: 16))
                        
                    Text("This is Futura font")
                        .font(.custom("Futura", size: 16))
                        
                    Text("This is Futura-Medium font")
                        .font(.custom("Futura-Medium", size: 16))
                }
                .padding(.vertical, 4)
                
                // Test default system fonts for comparison
                Group {
                    Text("System Default Font")
                        .padding(.top)
                    
                    Text("System Font - Regular")
                        .font(.system(size: 16, weight: .regular))
                        
                    Text("System Font - Medium")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.vertical, 4)
            }
            
            // Search for Futura specifically
            Section(header: Text("Search for Futura Fonts")) {
                ForEach(UIFont.familyNames.sorted().filter { $0.contains("Futura") }, id: \.self) { familyName in
                    Text("Family: \(familyName)")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    ForEach(UIFont.fontNames(forFamilyName: familyName).sorted(), id: \.self) { fontName in
                        Text("Font: \(fontName)")
                            .font(.custom(fontName, size: 16))
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Font Diagnostics")
        .onAppear {
            // Print all font family names and font names for debugging
            for family in UIFont.familyNames.sorted() {
                print("Font Family: \(family)")
                for name in UIFont.fontNames(forFamilyName: family).sorted() {
                    print("   Font: \(name)")
                }
            }
            
            // Look specifically for Futura
            print("\n--- SEARCHING FOR FUTURA FONTS ---")
            for family in UIFont.familyNames.sorted().filter({ $0.contains("Futura") }) {
                print("Futura Family Found: \(family)")
                for name in UIFont.fontNames(forFamilyName: family).sorted() {
                    print("   Futura Font: \(name)")
                }
            }
        }
    }
}

#Preview {
    FontDebugView()
} 