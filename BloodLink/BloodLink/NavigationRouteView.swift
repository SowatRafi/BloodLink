//
//  NavigationRouteView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 20/4/26.
//

import SwiftUI
import MapKit
import Combine

// MARK: - Transport mode
enum TransportMode: String, CaseIterable {
    case driving = "Driving"
    case walking = "Walking"
    case transit = "Transit"
    case cycling = "Cycling"

    var icon: String {
        switch self {
        case .driving: return "car.fill"
        case .walking: return "figure.walk"
        case .transit: return "bus.fill"
        case .cycling: return "bicycle"
        }
    }

    var color: Color {
        switch self {
        case .driving: return .blue
        case .walking: return .green
        case .transit: return .purple
        case .cycling: return .orange
        }
    }

    var mkType: MKDirectionsTransportType {
        switch self {
        case .driving: return .automobile
        case .walking: return .walking
        case .transit: return .transit
        case .cycling: return .walking
        }
    }

    var averageSpeed: Double {
        switch self {
        case .driving: return 35
        case .walking: return 5
        case .transit: return 25
        case .cycling: return 18
        }
    }
}

// MARK: - Navigation view
struct NavigationRouteView: View {

    let donorName: String
    let donorBloodType: String
    let donorPhone: String?
    let donorCoordinate: CLLocationCoordinate2D
    let userCoordinate: CLLocationCoordinate2D

    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: TransportMode = .driving
    @State private var cameraPosition: MapCameraPosition
    @State private var route: MKRoute? = nil
    @State private var estimatedTime: TimeInterval = 0
    @State private var distanceMeters: Double = 0
    @State private var isLoadingRoute = false
    @State private var showMapSelector = false
    @State private var showChat = false
    @State private var showCallConfirm = false
    @State private var showCallScreen = false
    @State private var callTimer = 0
    @State private var callTimerActive = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(
        donorName: String,
        donorBloodType: String,
        donorPhone: String? = nil,
        donorCoordinate: CLLocationCoordinate2D,
        userCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 23.8103, longitude: 90.4125)
    ) {
        self.donorName = donorName
        self.donorBloodType = donorBloodType
        self.donorPhone = donorPhone
        self.donorCoordinate = donorCoordinate
        self.userCoordinate = userCoordinate

        let midLat = (donorCoordinate.latitude + userCoordinate.latitude) / 2
        let midLon = (donorCoordinate.longitude + userCoordinate.longitude) / 2
        let latDelta = abs(donorCoordinate.latitude - userCoordinate.latitude) * 1.8
        let lonDelta = abs(donorCoordinate.longitude - userCoordinate.longitude) * 1.8

        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
            span: MKCoordinateSpan(
                latitudeDelta: max(latDelta, 0.02),
                longitudeDelta: max(lonDelta, 0.02)
            )
        )))
    }

    var etaString: String {
        let minutes = Int(estimatedTime / 60)
        if minutes < 60 { return "\(minutes) min" }
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }

    var distanceString: String {
        if distanceMeters < 1000 {
            return "\(Int(distanceMeters)) m"
        }
        return String(format: "%.1f km", distanceMeters / 1000)
    }

    var arrivalTime: String {
        let arrival = Date().addingTimeInterval(estimatedTime)
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: arrival)
    }

    var formattedCallTime: String {
        let m = callTimer / 60
        let s = callTimer % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: Map
            Map(position: $cameraPosition) {
                Annotation("You", coordinate: userCoordinate) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.25))
                            .frame(width: 32, height: 32)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                            .frame(width: 16, height: 16)
                    }
                }

                Annotation(donorName, coordinate: donorCoordinate) {
                    VStack(spacing: 2) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 40, height: 40)
                                .shadow(color: .red.opacity(0.4), radius: 8)
                            VStack(spacing: 0) {
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.white)
                                Text(donorBloodType)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.white)
                            }
                        }
                        RouteTriangle()
                            .fill(Color.red)
                            .frame(width: 10, height: 6)
                    }
                }

                if let route = route {
                    MapPolyline(route.polyline)
                        .stroke(selectedMode.color, lineWidth: 5)
                }
            }
            .ignoresSafeArea(edges: .top)

            // MARK: Bottom dashboard
            VStack(spacing: 0) {

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                ScrollView {
                    VStack(spacing: 16) {

                        // MARK: Donor card
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.12))
                                    .frame(width: 56, height: 56)
                                VStack(spacing: 0) {
                                    Text(String(donorName.prefix(1)))
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(Color.red)
                                    Text(donorBloodType)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.red.opacity(0.7))
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(donorName).font(.headline)
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color.green)
                                    Text("Verified donor")
                                        .font(.caption)
                                        .foregroundStyle(Color.green)
                                }
                            }

                            Spacer()

                            // Quick actions — NOW WIRED
                            HStack(spacing: 10) {
                                Button {
                                    showChat = true
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.12))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "message.fill")
                                            .foregroundStyle(Color.blue)
                                    }
                                }
                                .buttonStyle(.plain)

                                Button {
                                    showCallConfirm = true
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.12))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "phone.fill")
                                            .foregroundStyle(Color.green)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(14)
                        .background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)

                        // MARK: ETA metrics
                        HStack(spacing: 0) {
                            ETAMetric(icon: "clock.fill", value: etaString, label: "ETA", color: .blue)
                            Divider().frame(height: 40)
                            ETAMetric(icon: "location.fill", value: distanceString, label: "Distance", color: .red)
                            Divider().frame(height: 40)
                            ETAMetric(icon: "flag.checkered", value: arrivalTime, label: "Arrival", color: .green)
                        }
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)

                        // MARK: Transport modes
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Travel mode")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.gray)
                                .textCase(.uppercase)
                                .padding(.horizontal, 16)

                            HStack(spacing: 10) {
                                ForEach(TransportMode.allCases, id: \.self) { mode in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedMode = mode
                                            calculateRoute()
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: mode.icon)
                                                .font(.body)
                                                .foregroundStyle(
                                                    selectedMode == mode ? Color.white : mode.color
                                                )
                                            Text(mode.rawValue)
                                                .font(.caption2.weight(.semibold))
                                                .foregroundStyle(
                                                    selectedMode == mode ? Color.white : Color.primary
                                                )
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedMode == mode ? mode.color : Color.gray.opacity(0.08)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // MARK: Open in Maps
                        VStack(spacing: 10) {
                            Button {
                                showMapSelector = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                        .font(.title3)
                                    Text("Start navigation")
                                        .font(.body.weight(.semibold))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)

                            HStack(spacing: 6) {
                                Image(systemName: "info.circle").font(.caption2)
                                Text("Navigation will open in your preferred map app.")
                                    .font(.caption2)
                            }
                            .foregroundStyle(Color.gray)
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 20)
                    }
                    .padding(.top, 4)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: -4)
            )
            .frame(maxHeight: 520)

            // Close button
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.15), radius: 6)
                            Image(systemName: "xmark")
                                .font(.body.weight(.bold))
                                .foregroundStyle(Color.primary)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .onAppear { calculateRoute() }
        // Map selector
        .confirmationDialog(
            "Open in",
            isPresented: $showMapSelector,
            titleVisibility: .visible
        ) {
            Button("Apple Maps") { openInAppleMaps() }
            Button("Google Maps") { openInGoogleMaps() }
            Button("Waze") { openInWaze() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose which app to use for turn-by-turn navigation.")
        }
        // Chat sheet
        .sheet(isPresented: $showChat) {
            ChatView(otherName: donorName, otherBloodType: donorBloodType)
        }
        // Call confirmation
        .confirmationDialog(
            "Start anonymous call?",
            isPresented: $showCallConfirm,
            titleVisibility: .visible
        ) {
            Button("Call \(donorName)") { startCall() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your phone number will not be shared. The call is routed anonymously.")
        }
        // Full screen call
        .fullScreenCover(isPresented: $showCallScreen) {
            CallScreenView(
                otherName: donorName,
                otherBloodType: donorBloodType,
                callDuration: callTimer,
                onEnd: { endCall() }
            )
        }
        // Call timer
        .onReceive(timer) { _ in
            if callTimerActive { callTimer += 1 }
        }
    }

    // MARK: - Call actions
    func startCall() {
        callTimer = 0
        callTimerActive = true
        showCallScreen = true
    }

    func endCall() {
        callTimerActive = false
        showCallScreen = false
        callTimer = 0
    }

    // MARK: - Route calculation
    func calculateRoute() {
        isLoadingRoute = true

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: donorCoordinate))
        request.transportType = selectedMode.mkType

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            isLoadingRoute = false
            if let route = response?.routes.first {
                self.route = route
                self.estimatedTime = route.expectedTravelTime
                self.distanceMeters = route.distance

                if selectedMode == .cycling {
                    self.estimatedTime = self.distanceMeters / (selectedMode.averageSpeed * 1000 / 3600)
                }
            } else {
                let distance = estimateDistance()
                self.distanceMeters = distance
                self.estimatedTime = distance / (selectedMode.averageSpeed * 1000 / 3600)
            }
        }
    }

    func estimateDistance() -> Double {
        let r = 6371000.0
        let lat1 = userCoordinate.latitude * .pi / 180
        let lat2 = donorCoordinate.latitude * .pi / 180
        let dLat = (donorCoordinate.latitude - userCoordinate.latitude) * .pi / 180
        let dLon = (donorCoordinate.longitude - userCoordinate.longitude) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1) * cos(lat2) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return r * c
    }

    // MARK: - External map apps
    func openInAppleMaps() {
        let dest = MKMapItem(placemark: MKPlacemark(coordinate: donorCoordinate))
        dest.name = donorName

        let mode: String
        switch selectedMode {
        case .driving: mode = MKLaunchOptionsDirectionsModeDriving
        case .walking: mode = MKLaunchOptionsDirectionsModeWalking
        case .transit: mode = MKLaunchOptionsDirectionsModeTransit
        case .cycling: mode = MKLaunchOptionsDirectionsModeWalking
        }

        dest.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: mode])
    }

    func openInGoogleMaps() {
        let mode: String
        switch selectedMode {
        case .driving: mode = "driving"
        case .walking: mode = "walking"
        case .transit: mode = "transit"
        case .cycling: mode = "bicycling"
        }

        let appURLString = "comgooglemaps://?daddr=\(donorCoordinate.latitude),\(donorCoordinate.longitude)&directionsmode=\(mode)"
        let webURLString = "https://www.google.com/maps/dir/?api=1&destination=\(donorCoordinate.latitude),\(donorCoordinate.longitude)&travelmode=\(mode)"

        #if os(iOS)
        if let appURL = URL(string: appURLString),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = URL(string: webURLString) {
            UIApplication.shared.open(webURL)
        }
        #endif
    }

    func openInWaze() {
        let appURLString = "waze://?ll=\(donorCoordinate.latitude),\(donorCoordinate.longitude)&navigate=yes"
        let webURLString = "https://www.waze.com/ul?ll=\(donorCoordinate.latitude),\(donorCoordinate.longitude)&navigate=yes"

        #if os(iOS)
        if let appURL = URL(string: appURLString),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = URL(string: webURLString) {
            UIApplication.shared.open(webURL)
        }
        #endif
    }
}

// MARK: - ETA metric card
struct ETAMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(value)
                    .font(.headline)
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Triangle for pin tail
struct RouteTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationRouteView(
        donorName: "Hasan",
        donorBloodType: "A+",
        donorPhone: nil,
        donorCoordinate: CLLocationCoordinate2D(latitude: 23.8140, longitude: 90.4080)
    )
}
