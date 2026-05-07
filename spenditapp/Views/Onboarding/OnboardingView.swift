//
//  OnboardingView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2026-05-07.
//

import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {

    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "calendar.badge.clock",
            tint: .blue,
            title: "Plan before you spend",
            body: "Most apps tell you where your money went. SpendIt helps you decide where it should go — before you spend it."
        ),
        OnboardingPage(
            symbol: "arrow.up.arrow.down.circle.fill",
            tint: .green,
            title: "Income, expenses, savings",
            body: "Add what you earn, what you'll spend, and what you'll save. Color-coded. Freeze any item to see your balance without it."
        ),
        OnboardingPage(
            symbol: "bolt.circle.fill",
            tint: .orange,
            title: "Live balance, instantly",
            body: "Numbers update the moment you change anything. No surprises, no end-of-month panic — just clarity."
        )
    ]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button("Skip") {
                finish()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .accessibilityHint("Skip onboarding and go to the app")

            VStack {
                Spacer()
                primaryButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 80)
            }
        }
        .adaptiveBackground()
    }

    @ViewBuilder
    private var primaryButton: some View {
        let isLast = currentPage == pages.count - 1
        Button {
            HapticManager.shared.lightImpact()
            if isLast {
                finish()
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentPage += 1
                }
            }
        } label: {
            Text(isLast ? "Get Started" : "Next")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(GradientStyles.savingsGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.blue.opacity(0.25), radius: 12, y: 4)
        }
    }

    private func finish() {
        HapticManager.shared.success()
        withAnimation(.easeInOut(duration: 0.3)) {
            hasOnboarded = true
        }
    }
}

// MARK: - Onboarding Page Model

private struct OnboardingPage {
    let symbol: String
    let tint: Color
    let title: String
    let body: String
}

// MARK: - Onboarding Page View

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: page.symbol)
                .font(.system(size: 96, weight: .regular))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(page.tint)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text(page.body)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
}
