import SwiftUI

struct MenuItemRow: View {
    let item: ToolsMenuItem
    
    var body: some View {
        Button(action: {
            item.action()
        }) {
            HStack {
                Text(item.title)
                    .foregroundColor(Color(hex: "#212121"))
                    .font(.system(size: 15, weight: .medium))
                    .kerning(-0.1)
                Spacer()
                
                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
    }
}

enum ToolsMenuItem: CaseIterable, Identifiable {
    case annotate
    case crop
    case rearrange
    case changePart
    case metronome
    case messages
    case settings
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .annotate: return "Annotate"
        case .crop: return "Crop"
        case .rearrange: return "Rearrange"
        case .changePart: return "Change Part"
        case .metronome: return "Metronome"
        case .messages: return "Messages"
        case .settings: return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .annotate: return "Pen"
        case .crop: return "Crop"
        case .rearrange: return "Rearrange"
        case .changePart: return "Parts"
        case .metronome: return "Metronome"
        case .messages: return "Comments"
        case .settings: return "Settings"
        }
    }
    
    func action() {
        // Implement actions for each menu item
        switch self {
        case .annotate:
            // Handle annotate action
            break
        case .crop:
            // Handle crop action
            break
        case .rearrange:
            // Handle rearrange action
            break
        case .changePart:
            // Show the parts menu
            NotificationCenter.default.post(name: .showPartsMenu, object: nil)
            break
        case .metronome:
            // Handle metronome action
            break
        case .messages:
            // Handle messages action
            break
        case .settings:
            // Handle settings action
            break
        }
    }
}

// New enum for instrument parts
enum InstrumentPart: String, CaseIterable, Identifiable {
    case trumpets = "Trumpets"
    case trombones = "Trombones"
    case sousaphones = "Sousaphones"
    case clarinets = "Clarinets"
    case tenorDrums = "Tenor Drums"
    
    var id: Self { self }
    
    var iconName: String {
        return "Parts" // Using the same icon for all parts for now
    }
}

struct PartItemRow: View {
    let part: InstrumentPart
    let selectedPart: InstrumentPart
    
    var body: some View {
        Button(action: {
            // Handle part selection
            NotificationCenter.default.post(name: .partSelected, object: part)
        }) {
            HStack {
                Text(part.rawValue)
                    .foregroundColor(Color(hex: "#212121"))
                    .font(.system(size: 15, weight: .medium))
                    .kerning(-0.1)
                Spacer()
                
                if part == selectedPart {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundColor(Color(hex: "#212121"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
    }
}

// Notification names
extension Notification.Name {
    static let showPartsMenu = Notification.Name("showPartsMenu")
    static let partSelected = Notification.Name("partSelected")
} 