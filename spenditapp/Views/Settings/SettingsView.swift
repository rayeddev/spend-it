//
//  SettingsView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss

    // TODO: Add state for sync status, subscription status, etc.

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("App Info")
                }

                Section {
                    HStack {
                        Image(systemName: "icloud")
                            .foregroundStyle(.blue)
                        Text("iCloud Sync")
                        Spacer()
                        #if DEBUG
                        Text("Disabled (Debug)")
                            .foregroundStyle(.orange)
                        #else
                        Text("Enabled")
                            .foregroundStyle(.green)
                        #endif
                    }
                } header: {
                    Text("Data")
                } footer: {
                    #if DEBUG
                    Text("Running in DEBUG mode. CloudKit sync is disabled. Data is stored locally only.")
                    #else
                    Text("Your data is securely synced to your private iCloud account")
                    #endif
                }

                Section {
                    // TODO: Implement subscription management
                    NavigationLink {
                        Text("Subscription details coming soon")
                            .foregroundStyle(.secondary)
                    } label: {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(.yellow)
                            Text("Subscription")
                        }
                    }

                    // TODO: Implement export functionality (P2 feature)
                    Button {
                        // Export functionality
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.green)
                            Text("Export to Excel")
                            Spacer()
                            Text("$6.99")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(true)
                }

                Section {
                    Link(destination: URL(string: "https://support.apple.com")!) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Help & Support")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://www.apple.com/legal/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula")!) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
