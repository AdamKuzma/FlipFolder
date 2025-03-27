import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(ColorTokens.default)
                            Text("Dark Mode")
                                .foregroundColor(ColorTokens.label)
                        }
                    }
                } header: {
                    Text("Appearance")
                        .foregroundColor(ColorTokens.caption)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(Color(hex: "#5C5C5E"))
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: isDarkMode) { newValue in
            // Force a UI update when the color scheme changes
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = newValue ? .dark : .light
        }
    }
}

#Preview {
    SettingsView()
} 