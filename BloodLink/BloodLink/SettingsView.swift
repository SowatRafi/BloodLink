//
//  SettingsView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 19/4/26.
//

import SwiftUI

// MARK: - Settings view
struct SettingsView: View {

    // MARK: Notifications
    @State private var notifyBloodRequests = true
    @State private var notifyChat = true
    @State private var notifySystemAlerts = true
    @State private var notifyNewDonorNearby = false
    @State private var notifyDonationReminder = true
    @State private var notificationRadius: Double = 10

    // MARK: Privacy
    @State private var shareLocation = true
    @State private var showProfilePublicly = true
    @State private var showFullName = false
    @State private var showOnlineStatus = true
    @State private var allowAnonymousCalls = true
    @State private var allowAnonymousChat = true
    @State private var locationAccuracy = "Approximate"

    // MARK: Account
    @State private var linkedWith = "Apple"
    @State private var showDeleteConfirm = false
    @State private var showSignOutConfirm = false
    @State private var showExportConfirm = false
    @State private var showExportSuccess = false

    // MARK: Appearance
    @EnvironmentObject var themeManager: ThemeManager

    let locationAccuracyOptions = ["Exact", "Approximate", "City only"]

    // MARK: Body
    var body: some View {
        Form {

            // MARK: Account
            Section {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black)
                            .frame(width: 32, height: 32)
                        Image(systemName: linkedWith == "Apple"
                              ? "apple.logo"
                              : "person.circle.fill")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 16))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Signed in with \(linkedWith)")
                            .font(.subheadline.weight(.semibold))
                        Text("Your number is never shared")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.green)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Account")
            }

            // MARK: Linked accounts
            Section {
                HStack {
                    SettingsIcon(icon: "apple.logo", color: .black)
                    Text("Apple ID")
                    Spacer()
                    Text(linkedWith == "Apple" ? "Connected" : "Not connected")
                        .font(.subheadline)
                        .foregroundStyle(linkedWith == "Apple" ? Color.green : Color.gray)
                }
                HStack {
                    SettingsIcon(icon: "person.circle.fill", color: .blue)
                    Text("Google")
                    Spacer()
                    Text(linkedWith == "Google" ? "Connected" : "Not connected")
                        .font(.subheadline)
                        .foregroundStyle(linkedWith == "Google" ? Color.green : Color.gray)
                }
            } header: {
                Text("Linked accounts")
            }

            // MARK: Appearance
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        SettingsIcon(icon: "circle.lefthalf.filled", color: .purple)
                        Text("Appearance")
                    }
                    Picker("", selection: $themeManager.colorScheme) {
                        Text("System").tag(Optional<ColorScheme>.none)
                        Text("Light").tag(Optional<ColorScheme>.some(.light))
                        Text("Dark").tag(Optional<ColorScheme>.some(.dark))
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Display")
            } footer: {
                Text("Changes apply instantly across the entire app.")
            }

            // MARK: Notifications
            Section {
                SettingsToggleRow(
                    icon: "drop.fill",
                    iconColor: .red,
                    title: "Blood requests",
                    subtitle: "Alert when someone nearby needs blood",
                    isOn: $notifyBloodRequests
                )

                if notifyBloodRequests {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            SettingsIcon(icon: "location.circle.fill", color: .blue)
                            Text("Alert radius")
                            Spacer()
                            Text("\(Int(notificationRadius)) km")
                                .font(.subheadline)
                                .foregroundStyle(Color.blue)
                                .contentTransition(.numericText())
                        }
                        Slider(value: $notificationRadius, in: 1...50, step: 1)
                            .tint(.red)
                        HStack {
                            Text("1 km").font(.caption2).foregroundStyle(Color.gray)
                            Spacer()
                            Text("25 km").font(.caption2).foregroundStyle(Color.gray)
                            Spacer()
                            Text("50 km").font(.caption2).foregroundStyle(Color.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }

                SettingsToggleRow(
                    icon: "message.fill",
                    iconColor: .green,
                    title: "Chat messages",
                    subtitle: "Notify on new messages",
                    isOn: $notifyChat
                )

                SettingsToggleRow(
                    icon: "person.fill.badge.plus",
                    iconColor: .orange,
                    title: "New donor nearby",
                    subtitle: "When a matching donor comes online",
                    isOn: $notifyNewDonorNearby
                )

                SettingsToggleRow(
                    icon: "calendar.badge.clock",
                    iconColor: .purple,
                    title: "Donation reminder",
                    subtitle: "Remind when eligible to donate again",
                    isOn: $notifyDonationReminder
                )

                SettingsToggleRow(
                    icon: "bell.badge.fill",
                    iconColor: .gray,
                    title: "System alerts",
                    subtitle: "App updates and important notices",
                    isOn: $notifySystemAlerts
                )

            } header: {
                Text("Notifications")
            } footer: {
                Text("You can also manage notification permissions in iPhone Settings → BloodLink.")
            }

            // MARK: Privacy
            Section {
                SettingsToggleRow(
                    icon: "location.fill",
                    iconColor: .blue,
                    title: "Share location",
                    subtitle: "Required to appear on donor map",
                    isOn: $shareLocation
                )

                if shareLocation {
                    HStack {
                        SettingsIcon(icon: "scope", color: .blue)
                        Picker("Location accuracy", selection: $locationAccuracy) {
                            ForEach(locationAccuracyOptions, id: \.self) { Text($0) }
                        }
                    }
                }

                SettingsToggleRow(
                    icon: "person.fill",
                    iconColor: .red,
                    title: "Public profile",
                    subtitle: "Seekers can find you on the map",
                    isOn: $showProfilePublicly
                )

                SettingsToggleRow(
                    icon: "textformat",
                    iconColor: .indigo,
                    title: "Show full name",
                    subtitle: "Seekers see only first name if off",
                    isOn: $showFullName
                )

                SettingsToggleRow(
                    icon: "circle.fill",
                    iconColor: .green,
                    title: "Show online status",
                    subtitle: "Let others see when you're active",
                    isOn: $showOnlineStatus
                )

            } header: {
                Text("Privacy")
            } footer: {
                Text("Seekers can only ever see your name, blood type, and approximate location — never your address or phone number.")
            }

            // MARK: Communication privacy
            Section {
                SettingsToggleRow(
                    icon: "phone.fill",
                    iconColor: .green,
                    title: "Anonymous calling",
                    subtitle: "Your number is always hidden",
                    isOn: $allowAnonymousCalls
                )

                SettingsToggleRow(
                    icon: "message.fill",
                    iconColor: .blue,
                    title: "Anonymous chat",
                    subtitle: "Your identity is protected in chat",
                    isOn: $allowAnonymousChat
                )

                HStack {
                    SettingsIcon(icon: "lock.shield.fill", color: .blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("End-to-end encryption")
                            .font(.subheadline)
                        Text("All messages are encrypted by default")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                }
                .padding(.vertical, 2)

            } header: {
                Text("Communication privacy")
            }

            // MARK: Data & legal
            Section {
                Button {
                    showExportConfirm = true
                } label: {
                    HStack {
                        SettingsIcon(icon: "square.and.arrow.up", color: .blue)
                        Text("Export my data")
                            .foregroundStyle(Color.primary)
                        Spacer()
                        if showExportSuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.green)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }

                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    HStack {
                        SettingsIcon(icon: "doc.text.fill", color: .gray)
                        Text("Privacy policy")
                    }
                }

                NavigationLink {
                    TermsView()
                } label: {
                    HStack {
                        SettingsIcon(icon: "doc.plaintext.fill", color: .gray)
                        Text("Terms of service")
                    }
                }

            } header: {
                Text("Data & legal")
            }

            // MARK: Danger zone
            Section {
                Button {
                    showSignOutConfirm = true
                } label: {
                    HStack {
                        SettingsIcon(
                            icon: "rectangle.portrait.and.arrow.right",
                            color: .orange
                        )
                        Text("Sign out")
                            .foregroundStyle(Color.orange)
                    }
                }

                Button {
                    showDeleteConfirm = true
                } label: {
                    HStack {
                        SettingsIcon(icon: "trash.fill", color: .red)
                        Text("Delete account")
                            .foregroundStyle(Color.red)
                    }
                }

            } header: {
                Text("Danger zone")
            } footer: {
                Text("Deleting your account permanently removes all your data from BloodLink servers. This cannot be undone.")
            }

            // MARK: About
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0 (1)").foregroundStyle(Color.gray)
                }
                HStack {
                    Text("Build")
                    Spacer()
                    Text("April 2026").foregroundStyle(Color.gray)
                }
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("SowadRafi & Friends").foregroundStyle(Color.gray)
                }
            } header: {
                Text("About BloodLink")
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .confirmationDialog(
            "Sign out?",
            isPresented: $showSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button("Sign out", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will need to sign in again to access BloodLink.")
        }
        .confirmationDialog(
            "Delete account?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete my account", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes all your data. This cannot be undone.")
        }
        .confirmationDialog(
            "Export your data?",
            isPresented: $showExportConfirm,
            titleVisibility: .visible
        ) {
            Button("Export") {
                withAnimation { showExportSuccess = true }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A copy of your BloodLink data will be prepared and sent to your linked email.")
        }
    }
}

// MARK: - Settings icon
struct SettingsIcon: View {
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(color)
                .frame(width: 30, height: 30)
            Image(systemName: icon)
                .foregroundStyle(Color.white)
                .font(.system(size: 14))
        }
    }
}

// MARK: - Settings toggle row
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            SettingsIcon(icon: icon, color: iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Privacy policy
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title2.weight(.bold))
                Text("Last updated: April 2026")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                PolicyBlock(
                    title: "What we collect",
                    text: "We collect your name, blood type, and approximate location to connect donors with seekers. We never collect or share your phone number."
                )
                PolicyBlock(
                    title: "How we use it",
                    text: "Your location is used only to match you with nearby blood requests. It is never sold or shared with third parties."
                )
                PolicyBlock(
                    title: "Communication",
                    text: "All calls and chats are routed through an anonymous relay. Neither party ever sees the other's phone number or personal contact details."
                )
                PolicyBlock(
                    title: "Data retention",
                    text: "You can delete your account and all associated data at any time from Settings → Danger zone."
                )
            }
            .padding(20)
        }
        .navigationTitle("Privacy Policy")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Terms of service
struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title2.weight(.bold))
                Text("Last updated: April 2026")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                PolicyBlock(
                    title: "Eligibility",
                    text: "You must be 18 or older to register as a donor. By using BloodLink you confirm that all information you provide is accurate."
                )
                PolicyBlock(
                    title: "Donor responsibilities",
                    text: "Donors must ensure they meet health eligibility criteria before agreeing to donate. BloodLink is a connection platform only and does not provide medical advice."
                )
                PolicyBlock(
                    title: "Prohibited use",
                    text: "BloodLink must not be used for any purpose other than voluntary blood donation coordination. Misuse will result in immediate account termination."
                )
                PolicyBlock(
                    title: "Liability",
                    text: "BloodLink provides a platform to connect donors and seekers. We are not responsible for outcomes of individual donation events."
                )
            }
            .padding(20)
        }
        .navigationTitle("Terms of Service")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Policy block
struct PolicyBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(ThemeManager())
}
