//
//  CardStyles.swift
//  spenditapp
//
//  Modern card and button styles for SpendIt app
//

import SwiftUI

// MARK: - Card Elevation

enum CardElevation {
    case flat       // No shadow
    case low        // Subtle elevation
    case medium     // Standard cards
    case high       // Important elements (summary bar)

    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 4
        case .medium: return 8
        case .high: return 16
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 1
        case .medium: return 2
        case .high: return 4
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .flat: return 0
        case .low: return 0.06
        case .medium: return 0.1
        case .high: return 0.15
        }
    }
}

// MARK: - Floating Card Modifier

struct FloatingCardModifier: ViewModifier {
    let elevation: CardElevation
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    @Environment(\.colorScheme) var colorScheme

    init(
        elevation: CardElevation = .medium,
        cornerRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    ) {
        self.elevation = elevation
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                ZStack {
                    // Card background with subtle gradient
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(cardBackground)

                    // Inner highlight for depth
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.05 : 0.3),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            }
            .shadow(
                color: shadowColor,
                radius: elevation.shadowRadius,
                x: 0,
                y: elevation.shadowY
            )
    }

    private var cardBackground: some ShapeStyle {
        colorScheme == .dark
            ? GradientStyles.cardSubtleDark
            : GradientStyles.cardSubtle
    }

    private var shadowColor: Color {
        colorScheme == .dark
            ? Color.black.opacity(elevation.shadowOpacity * 1.5)
            : Color.black.opacity(elevation.shadowOpacity)
    }
}

// MARK: - Glassmorphism Modifier

struct GlassMorphismModifier: ViewModifier {
    let tintColor: Color
    let intensity: Double // 0.0 to 1.0
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // Blur background
                    if colorScheme == .dark {
                        Color.black.opacity(0.3 * intensity)
                    } else {
                        Color.white.opacity(0.7 * intensity)
                    }

                    // Tint overlay
                    tintColor.opacity(0.05 * intensity)
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.1 : 0.4),
                                Color.white.opacity(0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }
}

// MARK: - View Extensions

extension View {
    func floatingCard(
        elevation: CardElevation = .medium,
        cornerRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    ) -> some View {
        modifier(FloatingCardModifier(elevation: elevation, cornerRadius: cornerRadius, padding: padding))
    }

    // Convenience methods
    func planCard() -> some View {
        floatingCard(
            elevation: .medium,
            cornerRadius: 20,
            padding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        )
    }

    func itemCard() -> some View {
        floatingCard(
            elevation: .low,
            cornerRadius: 12,
            padding: EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        )
    }

    func glassMorphism(tint: Color = .blue, intensity: Double = 1.0) -> some View {
        modifier(GlassMorphismModifier(tintColor: tint, intensity: intensity))
    }
}

// MARK: - Modern Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    let isDestructive: Bool

    init(gradient: LinearGradient = GradientStyles.savingsGradient, isDestructive: Bool = false) {
        self.gradient = isDestructive
            ? GradientStyles.expenseGradient
            : gradient
        self.isDestructive = false 
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(
                color: configuration.isPressed ? .clear : .black.opacity(0.15),
                radius: configuration.isPressed ? 0 : 12,
                y: configuration.isPressed ? 0 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func primary(gradient: LinearGradient) -> PrimaryButtonStyle {
        PrimaryButtonStyle(gradient: gradient)
    }
    static var destructive: PrimaryButtonStyle {
        PrimaryButtonStyle(isDestructive: true)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
