//
//  HomeView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 18/4/26.
//

import SwiftUI
import MapKit

// MARK: - Blood request pin model
struct BloodRequest: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let bloodType: String
    let seekerName: String
    let distance: String
}

// MARK: - Home view (tab container)
struct HomeView: View {

    @EnvironmentObject var themeManager: ThemeManager

    // Donor state
    @State private var isOnline = false
    @State private var isLocked = false
    @State private var daysUntilEligible = 0
    @State private var showGoOnlineConfirm = false

    // Stats
    @State private var totalDonations = 3
    @State private var livesSaved = 3
    @State private var nextEligibleDate = Calendar.current.date(
        byAdding: .day, value: 14, to: Date()
    ) ?? Date()

    // Map
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    // Dummy nearby requests
    let nearbyRequests: [BloodRequest] = [
        BloodRequest(coordinate: CLLocationCoordinate2D(latitude: 23.8150, longitude: 90.4100), bloodType: "A+",  seekerName: "Rahim",  distance: "0.8 km"),
        BloodRequest(coordinate: CLLocationCoordinate2D(latitude: 23.8080, longitude: 90.4200), bloodType: "O-",  seekerName: "Karim",  distance: "1.2 km"),
        BloodRequest(coordinate: CLLocationCoordinate2D(latitude: 23.8200, longitude: 90.4050), bloodType: "B+",  seekerName: "Salma",  distance: "2.1 km"),
        BloodRequest(coordinate: CLLocationCoordinate2D(latitude: 23.8060, longitude: 90.4160), bloodType: "AB+", seekerName: "Nadia",  distance: "3.0 km"),
    ]

    @State private var pulse = false
    @State private var unreadNotifications = 3

    var formattedNextEligible: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: nextEligibleDate)
    }

    var buttonLabel: String {
        if isLocked { return "Unavailable" }
        return isOnline ? "Online" : "Go Online"
    }

    var buttonColor: Color {
        if isLocked { return .gray }
        return isOnline ? .green : .red
    }

    // MARK: - Body
    var body: some View {
        TabView {

            // MARK: Donate tab
            donorTab
                .tabItem {
                    Label("Donate", systemImage: "drop.fill")
                }

            // MARK: Find Blood tab
            SeekerView()
                .tabItem {
                    Label("Find Blood", systemImage: "magnifyingglass")
                }

            // MARK: Messages tab
            ConversationListView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }

            // MARK: Alerts tab
            NotificationView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .badge(unreadNotifications > 0 ? unreadNotifications : 0)

            // MARK: Profile tab
            ProfileView()
                .environmentObject(themeManager)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.red)
    }

    // MARK: - Donor tab
    var donorTab: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                // Full screen map
                Map(position: $cameraPosition) {
                    ForEach(nearbyRequests) { request in
                        Annotation(request.bloodType, coordinate: request.coordinate) {
                            BloodRequestPin(bloodType: request.bloodType)
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)

                // Bottom sheet
                VStack(spacing: 0) {

                    // Drag handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    ScrollView {
                        VStack(spacing: 20) {

                            // MARK: Online/offline button
                            VStack(spacing: 8) {
                                ZStack {
                                    if isOnline {
                                        Circle()
                                            .stroke(Color.green.opacity(0.3), lineWidth: 12)
                                            .frame(
                                                width: pulse ? 140 : 110,
                                                height: pulse ? 140 : 110
                                            )
                                            .animation(
                                                .easeInOut(duration: 1.2)
                                                .repeatForever(autoreverses: true),
                                                value: pulse
                                            )

                                        Circle()
                                            .stroke(Color.green.opacity(0.15), lineWidth: 20)
                                            .frame(
                                                width: pulse ? 170 : 130,
                                                height: pulse ? 170 : 130
                                            )
                                            .animation(
                                                .easeInOut(duration: 1.2)
                                                .repeatForever(autoreverses: true)
                                                .delay(0.2),
                                                value: pulse
                                            )
                                    }

                                    Button {
                                        if isLocked { return }
                                        if isOnline {
                                            withAnimation { isOnline = false }
                                        } else {
                                            showGoOnlineConfirm = true
                                        }
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(buttonColor)
                                                .frame(width: 110, height: 110)
                                                .shadow(
                                                    color: buttonColor.opacity(0.4),
                                                    radius: 12, x: 0, y: 6
                                                )
                                            VStack(spacing: 4) {
                                                Image(systemName: isLocked
                                                      ? "lock.fill"
                                                      : (isOnline ? "wifi" : "wifi.slash"))
                                                    .font(.system(size: 28, weight: .semibold))
                                                    .foregroundStyle(Color.white)
                                                Text(buttonLabel)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundStyle(Color.white)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                .frame(height: 180)
                                .onAppear { pulse = true }

                                if isLocked {
                                    Label(
                                        "Eligible to donate again in \(daysUntilEligible) days",
                                        systemImage: "clock"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(Color.orange)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(Capsule())
                                }

                                Text(isOnline
                                     ? "You are visible to nearby blood seekers"
                                     : "You are hidden from seekers")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }

                            // MARK: Stats cards
                            HStack(spacing: 12) {
                                StatCard(
                                    icon: "drop.fill",
                                    iconColor: .red,
                                    value: "\(totalDonations)",
                                    label: "Donations"
                                )
                                StatCard(
                                    icon: "heart.fill",
                                    iconColor: .pink,
                                    value: "\(livesSaved)",
                                    label: "Lives saved"
                                )
                                StatCard(
                                    icon: "calendar.badge.checkmark",
                                    iconColor: .blue,
                                    value: formattedNextEligible,
                                    label: "Next eligible"
                                )
                            }
                            .padding(.horizontal, 16)

                            // MARK: Nearby requests list
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Nearby requests")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(nearbyRequests.count) active")
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                }
                                .padding(.horizontal, 16)

                                ForEach(nearbyRequests) { request in
                                    NearbyRequestRow(request: request)
                                }
                            }

                            Spacer(minLength: 20)
                        }
                        .padding(.top, 8)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: -4)
                )
                .frame(maxHeight: 520)
            }
            .navigationTitle("BloodLink")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.red)
                    }
                }
                #endif
            }
            .confirmationDialog(
                "Go online as donor?",
                isPresented: $showGoOnlineConfirm,
                titleVisibility: .visible
            ) {
                Button("Yes, I'm available") {
                    withAnimation { isOnline = true }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will be visible to nearby blood seekers based on your location.")
            }
        }
    }
}

// MARK: - Blood request map pin
struct BloodRequestPin: View {
    let bloodType: String
    @State private var appear = false

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 36, height: 36)
                    .shadow(color: .red.opacity(0.4), radius: 6)
                Text(bloodType)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            Triangle()
                .fill(Color.red)
                .frame(width: 10, height: 6)
        }
        .scaleEffect(appear ? 1 : 0.1)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                appear = true
            }
        }
    }
}

// MARK: - Triangle shape for pin tail
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Stat card
struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Nearby request row
struct NearbyRequestRow: View {
    let request: BloodRequest

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                Text(request.bloodType)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.red)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(request.seekerName)
                    .font(.subheadline.weight(.semibold))
                Text("Needs \(request.bloodType) blood")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(request.distance)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.blue)
                Text("away")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

#Preview {
    HomeView()
        .environmentObject(ThemeManager())
}
