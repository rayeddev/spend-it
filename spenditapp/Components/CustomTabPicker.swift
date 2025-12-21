//
//  CustomTabPicker.swift
//  spenditapp
//
//  Modern tab picker with glassmorphism and gradient indicators
//

import SwiftUI

// MARK: - Custom Tab Picker

struct CustomTabPicker: View {

    // MARK: - Properties

    @Binding var selection: ItemType
    @Namespace private var animation

    private let tabs: [ItemType] = [.outcome, .income, .savings]

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selection == tab,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selection = tab
                        HapticManager.shared.lightImpact()
                    }
                }
            }
        }
        .padding(6)
        .background {
            // Glassmorphism background
            ZStack {
                // Frosted glass effect
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)

                // Subtle tint
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))

                // Border highlight
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Tab Button

private struct TabButton: View {

    let tab: ItemType
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .frame(height: 24)

                // Label
                Text(tab.displayName)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background {
                if isSelected {
                    // Animated gradient background for selected tab
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(gradientForTab)
                        .matchedGeometryEffect(id: "selectedTab", in: namespace)
                        .shadow(
                            color: shadowColorForTab,
                            radius: 8,
                            y: 3
                        )
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tab.displayName) tab")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint(isSelected ? "Currently selected" : "Double tap to switch to \(tab.displayName)")
    }

    // MARK: - Computed Properties

    private var iconName: String {
        switch tab {
        case .outcome:
            return "cart.fill"
        case .income:
            return "dollarsign.circle.fill"
        case .savings:
            return "banknote.fill"
        }
    }

    private var gradientForTab: LinearGradient {
        switch tab {
        case .outcome:
            return GradientStyles.expenseGradient
        case .income:
            return GradientStyles.incomeGradient
        case .savings:
            return GradientStyles.savingsGradient
        }
    }

    private var shadowColorForTab: Color {
        switch tab {
        case .outcome:
            return Color(hex: "#DC2626").opacity(0.35)
        case .income:
            return Color(hex: "#059669").opacity(0.35)
        case .savings:
            return Color(hex: "#2563EB").opacity(0.35)
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    VStack(spacing: 40) {
        CustomTabPicker(selection: .constant(.outcome))
        CustomTabPicker(selection: .constant(.income))
        CustomTabPicker(selection: .constant(.savings))
    }
    .adaptiveBackground()
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    VStack(spacing: 40) {
        CustomTabPicker(selection: .constant(.outcome))
        CustomTabPicker(selection: .constant(.income))
        CustomTabPicker(selection: .constant(.savings))
    }
    .adaptiveBackground()
    .preferredColorScheme(.dark)
}

#Preview("Interactive") {
    struct PreviewWrapper: View {
        @State private var selectedTab: ItemType = .outcome

        var body: some View {
            VStack(spacing: 30) {
                CustomTabPicker(selection: $selectedTab)

                Text("Selected: \(selectedTab.displayName)")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .adaptiveBackground()
        }
    }

    return PreviewWrapper()
}
