//
//  SeekerView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 18/4/26.
//

import SwiftUI
import MapKit

// MARK: - Donor pin model
struct NearbyDonor: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let bloodType: String
    let name: String
    let distance: Double // in km
    let isAvailable: Bool
}

// MARK: - Seeker view
struct SeekerView: View {

    // Search state
    @State private var selectedBloodType = "A+"
    @State private var radiusKm: Double = 5
    @State private var hasSearched = false
    @State private var showNotifyConfirm = false
    @State private var notificationSent = false

    let bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    let radiusPresets: [Double] = [1, 5, 10, 25, 50]

    // Map
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    // Dummy donors — replaced by Firebase later
    let allDonors: [NearbyDonor] = [
        NearbyDonor(coordinate: CLLocationCoordinate2D(latitude: 23.8140, longitude: 90.4080), bloodType: "A+",  name: "Hasan",   distance: 0.6,  isAvailable: true),
        NearbyDonor(coordinate: CLLocationCoordinate2D(latitude: 23.8090, longitude: 90.4180), bloodType: "A+",  name: "Farida",  distance: 1.4,  isAvailable: true),
        NearbyDonor(coordinate: CLLocationCoordinate2D(latitude: 23.8210, longitude: 90.4060), bloodType: "B+",  name: "Tariq",   distance: 3.2,  isAvailable: true),
        NearbyDonor(coordinate: CLLocationCoordinate2D(latitude: 23.8050, longitude: 90.4150), bloodType: "O-",  name: "Layla",   distance: 6.8,  isAvailable: false),
        NearbyDonor(coordinate: CLLocationCoordinate2D(latitude: 23.8170, longitude: 90.4220), bloodType: "A+",  name: "Imran",   distance: 8.1,  isAvailable: true),
        NearbyDonor(coordinate: CLLocationCoordinate2D(latitude: 23.8030, longitude: 90.4100), bloodType: "AB+", name: "Nusrat",  distance: 12.3, isAvailable: true),
        NearbyDonor(coordinate: CLLocationCoordinate2D(latitude: 23.8250, longitude: 90.4000), bloodType: "A-",  name: "Bashir",  distance: 18.5, isAvailable: true),
        NearbyDonor(coordinate: CLLocationCoordinate2D(latitude: 23.8000, longitude: 90.4300), bloodType: "A+",  name: "Sultana", distance: 24.0, isAvailable: true),
    ]

    // Filtered donors based on blood type and radius
    var matchingDonors: [NearbyDonor] {
        allDonors.filter {
            $0.bloodType == selectedBloodType &&
            $0.distance <= radiusKm &&
            $0.isAvailable
        }
    }

    var mapSpan: MKCoordinateSpan {
        let delta = max(0.01, radiusKm * 0.018)
        return MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                // MARK: Full screen map
                Map(position: $cameraPosition) {
                    // Radius circle overlay (approximate)
                    MapCircle(
                        center: CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125),
                        radius: radiusKm * 1000
                    )
                    .foregroundStyle(Color.blue.opacity(0.08))
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)

                    // User location pin
                    Annotation("You", coordinate: CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125)) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 16, height: 16)
                            Circle()
                                .stroke(Color.white, lineWidth: 2.5)
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 32, height: 32)
                        }
                    }

                    // Donor pins (only if searched)
                    if hasSearched {
                        ForEach(matchingDonors) { donor in
                            Annotation(donor.name, coordinate: donor.coordinate) {
                                DonorPin(bloodType: donor.bloodType)
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                .onChange(of: radiusKm) {
                    withAnimation {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125),
                            span: mapSpan
                        ))
                    }
                }

                // MARK: Bottom search panel
                VStack(spacing: 0) {

                    // Drag handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 16)

                    ScrollView {
                        VStack(spacing: 20) {

                            // MARK: Blood type picker
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Blood type needed", systemImage: "drop.fill")
                                    .font(.headline)
                                    .foregroundStyle(Color.red)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                                    ForEach(bloodGroups, id: \.self) { type in
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedBloodType = type
                                                hasSearched = false
                                                notificationSent = false
                                            }
                                        } label: {
                                            Text(type)
                                                .font(.system(size: 15, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(
                                                    selectedBloodType == type
                                                    ? Color.red
                                                    : Color.red.opacity(0.08)
                                                )
                                                .foregroundStyle(
                                                    selectedBloodType == type
                                                    ? Color.white
                                                    : Color.red
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            selectedBloodType == type
                                                            ? Color.clear
                                                            : Color.red.opacity(0.2),
                                                            lineWidth: 1
                                                        )
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)

                            // MARK: Radius selector
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label("Search radius", systemImage: "location.circle")
                                        .font(.headline)
                                    Spacer()
                                    Text(radiusKm < 1.0
                                         ? String(format: "%.1f km", radiusKm)
                                         : "\(Int(radiusKm)) km")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.blue)
                                        .contentTransition(.numericText())
                                }
                                .padding(.horizontal, 16)

                                // Preset buttons
                                HStack(spacing: 8) {
                                    ForEach(radiusPresets, id: \.self) { preset in
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                radiusKm = preset
                                                hasSearched = false
                                                notificationSent = false
                                            }
                                        } label: {
                                            Text("\(Int(preset)) km")
                                                .font(.caption.weight(.semibold))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 7)
                                                .background(
                                                    radiusKm == preset
                                                    ? Color.blue
                                                    : Color.blue.opacity(0.08)
                                                )
                                                .foregroundStyle(
                                                    radiusKm == preset
                                                    ? Color.white
                                                    : Color.blue
                                                )
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)

                                // Slider
                                Slider(value: $radiusKm, in: 0.5...50, step: 0.5)
                                    .tint(.blue)
                                    .padding(.horizontal, 16)
                                    .onChange(of: radiusKm) {
                                        hasSearched = false
                                        notificationSent = false
                                    }

                                // Scale labels
                                HStack {
                                    Text("0.5 km")
                                    Spacer()
                                    Text("25 km")
                                    Spacer()
                                    Text("50 km")
                                }
                                .font(.caption2)
                                .foregroundStyle(Color.gray)
                                .padding(.horizontal, 16)
                            }

                            // MARK: Search button
                            Button {
                                withAnimation {
                                    hasSearched = true
                                    notificationSent = false
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                    Text("Find \(selectedBloodType) donors within \(Int(radiusKm)) km")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)

                            // MARK: Results
                            if hasSearched {
                                VStack(alignment: .leading, spacing: 12) {

                                    // Results header
                                    HStack {
                                        if matchingDonors.isEmpty {
                                            Label("No donors found", systemImage: "person.slash")
                                                .font(.headline)
                                                .foregroundStyle(Color.gray)
                                        } else {
                                            Label(
                                                "\(matchingDonors.count) donor\(matchingDonors.count == 1 ? "" : "s") found",
                                                systemImage: "person.2.fill"
                                            )
                                            .font(.headline)
                                            .foregroundStyle(Color.green)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)

                                    if !matchingDonors.isEmpty {

                                        // Donor list (name, location, blood type only)
                                        ForEach(matchingDonors) { donor in
                                            DonorResultRow(donor: donor)
                                        }

                                        // Notify all button
                                        if !notificationSent {
                                            Button {
                                                showNotifyConfirm = true
                                            } label: {
                                                HStack(spacing: 8) {
                                                    Image(systemName: "bell.badge.fill")
                                                    Text("Notify all \(matchingDonors.count) donors")
                                                        .font(.body.weight(.semibold))
                                                }
                                                .foregroundStyle(Color.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 16)
                                                .background(Color.green)
                                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                            }
                                            .buttonStyle(.plain)
                                            .padding(.horizontal, 16)

                                        } else {
                                            // Sent confirmation
                                            HStack(spacing: 10) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(Color.green)
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Notifications sent!")
                                                        .font(.subheadline.weight(.semibold))
                                                    Text("Donors will be alerted based on their location.")
                                                        .font(.caption)
                                                        .foregroundStyle(Color.gray)
                                                }
                                            }
                                            .padding(14)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.green.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                            .padding(.horizontal, 16)
                                        }
                                    } else {
                                        // No results tip
                                        VStack(spacing: 8) {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .font(.title2)
                                                .foregroundStyle(Color.gray)
                                            Text("Try increasing your radius or selecting a different blood type.")
                                                .font(.caption)
                                                .foregroundStyle(Color.gray)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                    }
                                }
                            }

                            Spacer(minLength: 24)
                        }
                        .padding(.bottom, 8)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: -4)
                )
                .frame(maxHeight: 580)
            }
            .navigationTitle("Find Blood")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Notify all donors?",
                isPresented: $showNotifyConfirm,
                titleVisibility: .visible
            ) {
                Button("Yes, send notifications") {
                    withAnimation { notificationSent = true }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All \(matchingDonors.count) available \(selectedBloodType) donors within \(Int(radiusKm)) km will receive a push notification.")
            }
        }
    }
}

// MARK: - Donor map pin
struct DonorPin: View {
    let bloodType: String
    @State private var appear = false

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 36, height: 36)
                    .shadow(color: .green.opacity(0.4), radius: 6)
                Text(bloodType)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            Triangle()
                .fill(Color.green)
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

// MARK: - Donor result row
// Shows only name, location indicator, and blood type (privacy protected)
struct DonorResultRow: View {
    let donor: NearbyDonor

    var body: some View {
        HStack(spacing: 14) {

            // Blood type badge
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 46, height: 46)
                Text(donor.bloodType)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.green)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(donor.name)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.blue)
                    Text(String(format: "%.1f km away", donor.distance))
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                }
            }

            Spacer()

            // Blood type tag (only info shown — no address, no phone)
            Text(donor.bloodType)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.green.opacity(0.12))
                .foregroundStyle(Color.green)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

#Preview {
    SeekerView()
}
