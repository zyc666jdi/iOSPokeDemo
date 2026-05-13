import SwiftUI

extension Color {
    static func pokemonColor(_ name: String) -> Color {
        switch name.lowercased() {
        case "red":    return Color.red.opacity(0.25)
        case "blue":   return Color.blue.opacity(0.25)
        case "yellow": return Color.yellow.opacity(0.35)
        case "green":  return Color.green.opacity(0.25)
        case "black":  return Color.gray.opacity(0.45)
        case "brown":  return Color.brown.opacity(0.3)
        case "purple": return Color.purple.opacity(0.25)
        case "pink":   return Color.pink.opacity(0.25)
        case "white":  return Color(white: 0.95)
        case "gray":   return Color.gray.opacity(0.2)
        default:       return Color(white: 0.93)
        }
    }
}
