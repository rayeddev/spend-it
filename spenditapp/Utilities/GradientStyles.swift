//
//  GradientStyles.swift
//  spenditapp
//
//  Modern gradient system for SpendIt app
//

import SwiftUI

struct GradientStyles {
    // MARK: - Background Gradients

    /// Warm sunrise gradient - main app background
    static let warmSunrise = LinearGradient(
        colors: [
            Color(hex: "#FAF5FF"),  // Soft lavender white
            Color(hex: "#FFF4ED"),  // Warm peach cream
            Color(hex: "#F0F9FF")   // Light sky blue
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Dark mode equivalent - subtle and elegant
    static let warmSunriseDark = LinearGradient(
        colors: [
            Color(hex: "#1A1625"),  // Deep purple-black
            Color(hex: "#1F1B24"),  // Warm dark brown-black
            Color(hex: "#1A232E")   // Deep blue-black
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Mint fresh gradient - alternative option
    static let mintFresh = LinearGradient(
        colors: [
            Color(hex: "#F0FDF4"),  // Mint white
            Color(hex: "#FEF3C7"),  // Warm amber cream
            Color(hex: "#F0F9FF")   // Sky blue
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Peachy warmth - softer option
    static let peachyWarm = LinearGradient(
        colors: [
            Color(hex: "#FFF7ED"),  // Peach white
            Color(hex: "#FEF2F2"),  // Rose white
            Color(hex: "#FAF5FF")   // Lavender white
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Card Gradients (Subtle)

    static let cardSubtle = LinearGradient(
        colors: [
            Color.white.opacity(0.95),
            Color.white.opacity(0.85)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardSubtleDark = LinearGradient(
        colors: [
            Color(hex: "#2C2C2E").opacity(0.95),
            Color(hex: "#1C1C1E").opacity(0.85)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Accent Gradients

    static let incomeGradient = LinearGradient(
        colors: [
            Color(hex: "#10B981"),  // Emerald 500
            Color(hex: "#059669")   // Emerald 600
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let expenseGradient = LinearGradient(
        colors: [
            Color(hex: "#F87171"),  // Red 400
            Color(hex: "#DC2626")   // Red 600
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let savingsGradient = LinearGradient(
        colors: [
            Color(hex: "#60A5FA"),  // Blue 400
            Color(hex: "#2563EB")   // Blue 600
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Applies adaptive gradient background based on color scheme
    @ViewBuilder
    func adaptiveBackground() -> some View {
        self.background {
            ZStack {
                // Base gradient
                AdaptiveGradientView()
                    .ignoresSafeArea()

                // Subtle noise texture for depth (optional)
                Color.black.opacity(0.01)
                    .blendMode(.overlay)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Adaptive Gradient View

struct AdaptiveGradientView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                GradientStyles.warmSunriseDark
            } else {
                GradientStyles.warmSunrise
            }
        }
    }
}
