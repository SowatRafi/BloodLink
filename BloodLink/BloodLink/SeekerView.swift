//
//  SeekerView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 18/4/26.
//

import SwiftUI
import MapKit

// MARK: - Donor result model
struct DonorResult: Identifiable {
    let id = UUID()
    let name: String
    let bloodType: String
    let distance: String
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Seeker sheet position
enum SeekerSheetPosition: CGFloat {
    case small  = 0.78
    case medium = 0.45
    case large  = 0.08

    static let all: [SeekerSheetPosition] = [.small, .medium, .large]
}

// MARK: - Seeker view
struct SeekerView: View {

    @State private var selectedBloodType = "A+"
    @State private var radiusKm: Double = 5
    @State private var showResults = false
    @State private var showNotifyConfirm = false
    @State private var notifySent = false

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var sheetPosition: SeekerSheetPosition = .medium
    @State private var dragOffset: CGFloat = 0

    let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    let presetRadii: [Double] = [1, 5, 10, 25, 50]

    let userLocation = CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125)

    let allDonors: [DonorResult] = [
        DonorResult(name: "Hasan",   bloodType: "A+",  distance: "0.4 km", coordinate: CLLocationCoordinate2D(latitude: 23.8140, longitude: 90.4080)),
        DonorResult(name: "Nusrat",  bloodType: "A+",  distance: "1.1 km", coordinate: CLLocationCoordinate2D(latitude: 23.8160, longitude: 90.4170)),
        DonorResult(name: "Bashir",  bloodType: "A+",  distance: "2.3 km", coordinate: CLLocationCoordinate2D(latitude: 23.8050, longitude: 90.4050)),
        DonorResult(name: "Sultana", bloodType: "A+",  distance: "3.8 km", coordinate: CLLocationCoordinate2D(latitude: 23.8220, longitude: 90.4230)),
        DonorResult(name: "Imran",   bloodType: "A+",  distance: "4.2 km", coordinate: CLLocationCoordinate2D(latitude: 23.7980, longitude: 90.4100)),
        DonorResult(name: "Layla",   bloodType: "O-",  distance: "0.9 km", coordinate: CLLocationCoordinate2D(latitude: 23.8130, longitude: 90.4180)),
    ]

    var matchingDonors: [DonorResult] {
        allDonors.filter { $0.bloodType == selectedBloodType }
    }

    var radiusMeters: CLLocationDistance {
        radiusKm * 1000
    }

    var radiusDisplay: String {
        if radiusKm < 1 {
            return String(format: "%.1f km", radiusKm)
        }
        return "\(Int(radiusKm)) km"
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .top) {

                    Map(position: $cameraPosition) {
                        MapCircle(center: userLocation, radius: radiusMeters)
                            .foregroundStyle(Color.red.opacity(0.1))
                            .stroke(Color.red.opacity(0.5), lineWidth: 1.5)

                        if showResults {
                            ForEach(matchingDonors) { donor in
                                Annotation(donor.name, coordinate: donor.coordinate) {
                                    DonorMapPin(bloodType: donor.bloodType)
                                }
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .top)

                    seekerSheet
                        .frame(height: geo.size.height)
                        .offset(y: max(
                            geo.size.height * sheetPosition.rawValue + dragOffset,
                            geo.size.height * SeekerSheetPosition.large.rawValue
                        ))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.height
                                }
                                .onEnded { value in
                                    let currentOffset = geo.size.height * sheetPosition.rawValue + value.translation.height
                                    let currentFraction = currentOffset / geo.size.height

                                    let closest = SeekerSheetPosition.all.min(by: {
                                        abs($0.rawValue - currentFraction) < abs($1.rawValue - currentFraction)
                                    }) ?? .medium

                                    withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.85)) {
                                        sheetPosition = closest
                                        dragOffset = 0
                                    }
                                }
                        )
                }
            }
            .navigationTitle("Find Blood")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .confirmationDialog(
                "Notify all \(matchingDonors.count) \(selectedBloodType) donors?",
                isPresented: $showNotifyConfirm,
                titleVisibility: .visible
            ) {
                Button("Send notification") {
                    withAnimation { notifySent = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { notifySent = false }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All \(selectedBloodType) donors within \(radiusDisplay) will be alerted.")
            }
        }
    }

    // MARK: - Seeker sheet content
    var seekerSheet: some View {
        VStack(spacing: 0) {

            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 6)

            ScrollView {
                VStack(spacing: 18) {

                    // MARK: Blood type grid
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(Color.red)
                            Text("Blood type needed")
                                .font(.headline)
                        }
                        .padding(.horizontal, 16)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(bloodTypes, id: \.self) { type in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedBloodType = type
                                        showResults = false
                                    }
                                } label: {
                                    Text(type)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(
                                            selectedBloodType == type ? Color.white : Color.red
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedBloodType == type
                                            ? Color.red
                                            : Color.red.opacity(0.08)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 6)

                    // MARK: Radius
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "scope")
                                Text("Search radius")
                                    .font(.headline)
                            }
                            Spacer()
                            Text(radiusDisplay)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.blue)
                                .contentTransition(.numericText())
                        }
                        .padding(.horizontal, 16)

                        HStack(spacing: 8) {
                            ForEach(presetRadii, id: \.self) { preset in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        radiusKm = preset
                                        showResults = false
                                    }
                                } label: {
                                    Text("\(Int(preset)) km")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(
                                            radiusKm == preset ? Color.white : Color.blue
                                        )
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(
                                            radiusKm == preset
                                            ? Color.blue
                                            : Color.blue.opacity(0.1)
                                        )
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)

                        VStack(spacing: 4) {
                            Slider(value: $radiusKm, in: 0.5...50, step: 0.5)
                                .tint(.blue)
                                .onChange(of: radiusKm) { showResults = false }

                            HStack {
                                Text("0.5 km").font(.caption2).foregroundStyle(Color.gray)
                                Spacer()
                                Text("25 km").font(.caption2).foregroundStyle(Color.gray)
                                Spacer()
                                Text("50 km").font(.caption2).foregroundStyle(Color.gray)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // MARK: Action
                    if !showResults {
                        Button {
                            withAnimation { showResults = true }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                Text("Find \(selectedBloodType) donors within \(radiusDisplay)")
                                    .font(.body.weight(.semibold))
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    } else {

                        // MARK: Results
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.2.fill")
                                        .foregroundStyle(Color.green)
                                    Text("\(matchingDonors.count) donors nearby")
                                        .font(.headline)
                                }
                                Spacer()
                                Button {
                                    withAnimation { showResults = false }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.gray)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)

                            if matchingDonors.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "person.fill.questionmark")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.gray.opacity(0.4))
                                    Text("No \(selectedBloodType) donors within \(radiusDisplay)")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.gray)
                                    Text("Try expanding your search radius")
                                        .font(.caption)
                                        .foregroundStyle(Color.gray.opacity(0.7))
                                }
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                            } else {
                                ForEach(matchingDonors) { donor in
                                    NavigationLink(destination: NavigationRouteView(
                                        donorName: donor.name,
                                        donorBloodType: donor.bloodType,
                                        donorCoordinate: donor.coordinate
                                    )) {
                                        DonorResultRow(donor: donor)
                                    }
                                    .buttonStyle(.plain)
                                }

                                Button {
                                    showNotifyConfirm = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "bell.fill")
                                        Text("Notify all \(matchingDonors.count) donors")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)

                                if notifySent {
                                    Label("Notification sent to all donors", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color.green)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
            .scrollDisabled(sheetPosition != .large)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: -4)
        )
    }
}

// MARK: - Donor map pin
struct DonorMapPin: View {
    let bloodType: String
    @State private var appear = false

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 34, height: 34)
                    .shadow(color: .green.opacity(0.4), radius: 6)
                Image(systemName: "person.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white)
            }
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
struct DonorResultRow: View {
    let donor: DonorResult

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 46, height: 46)
                Text(donor.bloodType)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.green)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(donor.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.green)
                    Text("Verified")
                        .font(.caption2)
                        .foregroundStyle(Color.green)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(donor.distance)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.blue)
                Text("away")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

#Preview {
    SeekerView()
}
