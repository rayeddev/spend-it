//
//  SpendItApp.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI
internal import CoreData

// MARK: - SpendIt App

@main
struct SpendItApp: App {

    // MARK: - Properties

    let persistenceController = PersistenceController.shared

    @AppStorage("hasOnboarded") private var hasOnboarded = false

    // MARK: - Initialization

    init() {
        configureAppearance()
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            Group {
                if hasOnboarded {
                    PlansListView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    OnboardingView()
                }
            }
        }
    }

    // MARK: - Configuration

    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
