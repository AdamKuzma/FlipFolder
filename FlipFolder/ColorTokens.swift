import SwiftUI

enum ColorTokens {
    // MARK: - Text Colors
    static let label = Color(light: "000000", dark: "FFFFFF")
    static let primary = Color(light: "141417", dark: "FFFFFF")
    static let secondary = Color(light: "252528", dark: "F2F2F2")
    static let tertiary = Color(light: "4B4B4E", dark: "D1D1D6")
    static let quaternary = Color(light: "6A6A6D", dark: "A1A1A6")
    static let caption = Color(light: "767679", dark: "8E8E93")
    
    // MARK: - Button Colors
    static let button = Color(light: "FFFFFF", dark: "FFFFFF")
    static let disabledButton = Color(light: "FFFFFF", dark: "FFFFFF", opacity: 0.4)
    static let icon = Color(light: "A4A4A8", dark: "A4A4A8")
    
    // MARK: - Interactive Colors
    static let light = Color(light: "847B8B", dark: "B0AFB2")
    static let `default` = Color(light: "58525F", dark: "DEDDDF")
    static let dark = Color(light: "453D4B", dark: "EDECEE")
    
    // MARK: - Background Colors
    static let surface = Color(light: "FFFFFF", dark: "101013")
    static let sheet = Color(light: "FFFFFF", dark: "1C1C1E")
    static let backgroundSecondary = Color(light: "F2F2F5", dark: "1B1B1F")
    static let performance = Color(light: "F2F2F5", dark: "2C2C2E")
    static let tabs = Color(light: "EAEAEE", dark: "2C2C2E")
    static let tabsSelected = Color(light: "FFFFFF", dark: "5A5A5E")
    static let glass = Color(light: "F5F4F6", dark: "2C2C2E", opacity: 0.75)
    static let lightPopover = Color(light: "FFFFFF", dark: "2C2C2E", opacity: 0.70)
    static let popover = Color(light: "FFFFFF", dark: "1C1C1E", opacity: 0.85)
    static let muted = Color(light: "D3D3D3", dark: "5A5A5E")
    static let border = Color(light: "E5E5E5", dark: "252526")
    static let scrim = Color(light: "000000", dark: "000000", opacity: 0.30)
    static let separator = Color(light: "1C1C1E", dark: "FFFFFF", opacity: 0.08)
    
    // MARK: - Gradients
    static let containerGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(light: "F9F8FA", dark: "3A3A3C").opacity(0.13), location: 0),
            .init(color: Color(light: "D3D1D3", dark: "1C1C1E"), location: 1)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Color Extension
extension Color {
    init(light: String, dark: String, opacity: Double = 1.0) {
        self.init(uiColor: UIColor { traitCollection in
            let hexString = traitCollection.userInterfaceStyle == .light ? light : dark
            return UIColor(hex: hexString)?.withAlphaComponent(opacity) ?? .clear
        })
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        let start = hex.hasPrefix("#") ? hex.index(hex.startIndex, offsetBy: 1) : hex.startIndex
        let hexColor = String(hex[start...])
        
        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000FF) / 255
                
                self.init(red: r, green: g, blue: b, alpha: 1)
                return
            }
        }
        return nil
    }
} 
