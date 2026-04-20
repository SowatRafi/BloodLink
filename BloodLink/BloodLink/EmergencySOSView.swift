//
//  EmergencySOSView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 20/4/26.
//

import SwiftUI
import MapKit
import Combine

// MARK: - Urgency level
enum SOSUrgency: String, CaseIterable {
    case urgent   = "Urgent"
    case critical = "Critical"
    case lifeOrDeath = "Life-or-death"

    var color: Color {
        switch self {
        case .urgent:      return .orange
        case .critical:    return .red
        case .lifeOrDeath: return Color(red: 0.7, green: 0.1, blue: 0.1)
        }
    }

    var icon: String {
        switch self {
        case .urgent:      return "exclamationmark.circle.fill"
        case .critical:    return "exclamationmark.triangle.fill"
        case .lifeOrDeath: return "heart.slash.fill"
        }
    }

    var description: String {
        switch self {
        case .urgent:      return "Needed within hours"
        case .critical:    return "Needed immediately"
        case .lifeOrDeath: return "Life is at risk right now"
        }
    }
}

// MARK: - Broadcast wave
enum BroadcastWave: Int {
    case first  = 0  // 5 km
    case second = 1  // 15 km
    case third  = 2  // 50 km

    var radius: Double {
        switch self {
        case .first:  return 5
        case .second: return 15
        case .third:  return 50
        }
    }

    var label: String {
        "Wave \(rawValue + 1)"
    }

    var delaySeconds: Int {
        switch self {
        case .first:  return 0
        case .second: return 90
        case .third:  return 180
        }
    }
}

// MARK: - SOS form view (step 1)
struct EmergencySOSView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var bloodType = "A+"
    @State private var hospital = ""
    @State private var location = "Dhaka, Bangladesh"
    @State private var unitsNeeded = 2
    @State private var patientCondition = ""
    @State private var contactNumber = ""
    @State private var urgency: SOSUrgency = .critical
    @State private var showBroadcastConfirm = false
    @State private var showBroadcastScreen = false

    let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

    var isFormValid: Bool {
        !hospital.isEmpty && !location.isEmpty && !contactNumber.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Warning banner
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Emergency SOS")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.red)
                            Text("Use only for genuine emergencies. False requests may result in account suspension.")
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.8))
                        }
                    }
                    .padding(14)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)

                    // MARK: Blood type selector
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Blood type needed", required: true)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(bloodTypes, id: \.self) { type in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        bloodType = type
                                    }
                                } label: {
                                    Text(type)
                                        .font(.headline)
                                        .foregroundStyle(
                                            bloodType == type ? Color.white : Color.red
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            bloodType == type ? Color.red : Color.red.opacity(0.08)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Urgency
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Urgency level", required: true)

                        VStack(spacing: 8) {
                            ForEach(SOSUrgency.allCases, id: \.self) { level in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        urgency = level
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: level.icon)
                                            .font(.title3)
                                            .foregroundStyle(level.color)
                                            .frame(width: 32)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(level.rawValue)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color.primary)
                                            Text(level.description)
                                                .font(.caption)
                                                .foregroundStyle(Color.gray)
                                        }
                                        Spacer()
                                        Image(systemName: urgency == level
                                              ? "largecircle.fill.circle"
                                              : "circle")
                                            .font(.title3)
                                            .foregroundStyle(urgency == level ? level.color : Color.gray.opacity(0.4))
                                    }
                                    .padding(14)
                                    .background(
                                        urgency == level
                                        ? level.color.opacity(0.08)
                                        : Color.gray.opacity(0.06)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                urgency == level ? level.color : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Hospital
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Hospital / medical facility", required: true)
                        TextField("e.g. Dhaka Medical College", text: $hospital)
                            .padding(14)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                    }
                    .padding(.horizontal, 16)

                    // MARK: Location
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Location / area", required: true)
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(Color.blue)
                            TextField("City or neighborhood", text: $location)
                                #if os(iOS)
                                .textInputAutocapitalization(.words)
                                #endif
                        }
                        .padding(14)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 16)

                    // MARK: Units needed
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Units needed", required: true)

                        HStack(spacing: 16) {
                            Button {
                                if unitsNeeded > 1 {
                                    withAnimation { unitsNeeded -= 1 }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(unitsNeeded > 1 ? Color.red : Color.gray.opacity(0.3))
                            }
                            .buttonStyle(.plain)
                            .disabled(unitsNeeded <= 1)

                            VStack(spacing: 2) {
                                Text("\(unitsNeeded)")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.red)
                                    .contentTransition(.numericText())
                                Text(unitsNeeded == 1 ? "unit" : "units")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                            .frame(maxWidth: .infinity)

                            Button {
                                if unitsNeeded < 20 {
                                    withAnimation { unitsNeeded += 1 }
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(unitsNeeded < 20 ? Color.red : Color.gray.opacity(0.3))
                            }
                            .buttonStyle(.plain)
                            .disabled(unitsNeeded >= 20)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)

                    // MARK: Patient condition
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Patient condition", required: false)
                        ZStack(alignment: .topLeading) {
                            if patientCondition.isEmpty {
                                Text("e.g. Post-surgery bleeding, accident trauma, thalassemia treatment...")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.gray.opacity(0.6))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                            }
                            TextEditor(text: $patientCondition)
                                .frame(minHeight: 80)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 16)

                    // MARK: Contact number
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Contact number", required: true)
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(Color.green)
                            TextField("+880 1XXX XXX XXX", text: $contactNumber)
                                #if os(iOS)
                                .keyboardType(.phonePad)
                                #endif
                        }
                        .padding(14)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Text("Donors will see this number to reach you directly. Your personal phone number is never shared for anonymous chat or call.")
                            .font(.caption2)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.horizontal, 16)

                    // MARK: Broadcast button
                    Button {
                        showBroadcastConfirm = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.title3)
                            Text("Broadcast SOS")
                                .font(.body.weight(.bold))
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            isFormValid ? urgency.color : Color.gray
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: isFormValid ? urgency.color.opacity(0.4) : .clear,
                            radius: 12, x: 0, y: 6
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isFormValid)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Emergency SOS")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.gray)
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.gray)
                }
                #endif
            }
            .confirmationDialog(
                "Broadcast SOS now?",
                isPresented: $showBroadcastConfirm,
                titleVisibility: .visible
            ) {
                Button("Yes, broadcast now", role: .destructive) {
                    showBroadcastScreen = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will alert all \(bloodType) donors nearby. Only proceed if this is a real emergency.")
            }
            .fullScreenCover(isPresented: $showBroadcastScreen) {
                SOSBroadcastScreen(
                    bloodType: bloodType,
                    hospital: hospital,
                    location: location,
                    unitsNeeded: unitsNeeded,
                    patientCondition: patientCondition,
                    contactNumber: contactNumber,
                    urgency: urgency,
                    onClose: {
                        showBroadcastScreen = false
                        dismiss()
                    }
                )
            }
        }
    }
}

// MARK: - Section header
struct SectionHeader: View {
    let title: String
    let required: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.primary)
            if required {
                Text("*").foregroundStyle(Color.red)
            }
            Spacer()
        }
    }
}

// MARK: - Broadcast screen
struct SOSBroadcastScreen: View {

    let bloodType: String
    let hospital: String
    let location: String
    let unitsNeeded: Int
    let patientCondition: String
    let contactNumber: String
    let urgency: SOSUrgency
    let onClose: () -> Void

    @State private var currentWave: BroadcastWave = .first
    @State private var secondsElapsed: Int = 0
    @State private var donorsReached: Int = 0
    @State private var respondersCount: Int = 0
    @State private var pulse = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var elapsedString: String {
        let m = secondsElapsed / 60
        let s = secondsElapsed % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.02, blue: 0.05),
                    Color(red: 0.15, green: 0.03, blue: 0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .scaleEffect(pulse ? 1.4 : 1)
                                .animation(
                                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                    value: pulse
                                )
                            Text("LIVE SOS")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.red)
                                .kerning(1)
                        }
                        Text("Broadcasting")
                            .font(.caption2)
                            .foregroundStyle(Color.white.opacity(0.5))
                    }

                    Spacer()

                    Text(elapsedString)
                        .font(.system(size: 16, weight: .light, design: .monospaced))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // MARK: Expanding radar
                ZStack {
                    // Wave 3 circle (outermost, 50km)
                    Circle()
                        .stroke(
                            currentWave.rawValue >= 2
                            ? Color.red.opacity(0.3)
                            : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                        .frame(width: 280, height: 280)
                        .scaleEffect(currentWave.rawValue >= 2 && pulse ? 1.08 : 1)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: pulse
                        )

                    // Wave 2 circle (middle, 15km)
                    Circle()
                        .stroke(
                            currentWave.rawValue >= 1
                            ? Color.red.opacity(0.5)
                            : Color.white.opacity(0.15),
                            lineWidth: 1.5
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(currentWave.rawValue >= 1 && pulse ? 1.08 : 1)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3),
                            value: pulse
                        )

                    // Wave 1 circle (innermost, 5km)
                    Circle()
                        .stroke(Color.red.opacity(0.8), lineWidth: 2)
                        .frame(width: 130, height: 130)
                        .scaleEffect(pulse ? 1.1 : 1)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.6),
                            value: pulse
                        )

                    // Center circle with blood type
                    ZStack {
                        Circle()
                            .fill(urgency.color)
                            .frame(width: 90, height: 90)
                            .shadow(color: urgency.color.opacity(0.6), radius: 20)

                        VStack(spacing: 0) {
                            Image(systemName: "drop.fill")
                                .font(.title)
                                .foregroundStyle(Color.white)
                            Text(bloodType)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    }

                    // Radius labels
                    VStack {
                        HStack {
                            Spacer()
                            Text("5 km")
                                .font(.caption2)
                                .foregroundStyle(Color.red.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                                .offset(x: -40, y: 38)
                        }
                        Spacer()
                    }
                    .frame(width: 280, height: 280)
                }
                .onAppear { pulse = true }

                Spacer()

                // MARK: Wave info
                VStack(spacing: 10) {
                    Text(currentWave.label.uppercased() + " · \(Int(currentWave.radius)) KM RADIUS")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.red)
                        .kerning(1.2)

                    HStack(spacing: 20) {
                        SOSMetric(
                            icon: "antenna.radiowaves.left.and.right",
                            value: "\(donorsReached)",
                            label: "Reached"
                        )

                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1, height: 40)

                        SOSMetric(
                            icon: "hand.raised.fill",
                            value: "\(respondersCount)",
                            label: "Responding"
                        )

                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1, height: 40)

                        SOSMetric(
                            icon: "clock.fill",
                            value: elapsedString,
                            label: "Elapsed"
                        )
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)

                Spacer()

                // MARK: Wave progress
                VStack(spacing: 12) {
                    ForEach([BroadcastWave.first, .second, .third], id: \.rawValue) { wave in
                        SOSWaveRow(
                            wave: wave,
                            isActive: wave == currentWave,
                            isCompleted: wave.rawValue < currentWave.rawValue
                        )
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // MARK: Cancel button
                Button {
                    onClose()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Stop broadcasting")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .onReceive(timer) { _ in
            secondsElapsed += 1

            // Simulate donors being reached over time
            if secondsElapsed % 3 == 0 {
                donorsReached += Int.random(in: 1...3)
            }

            // Simulate responders (slower)
            if secondsElapsed % 12 == 0 && donorsReached > 0 {
                respondersCount += 1
            }

            // Advance waves
            if secondsElapsed == BroadcastWave.second.delaySeconds {
                withAnimation(.easeInOut(duration: 0.6)) {
                    currentWave = .second
                }
            } else if secondsElapsed == BroadcastWave.third.delaySeconds {
                withAnimation(.easeInOut(duration: 0.6)) {
                    currentWave = .third
                }
            }
        }
    }
}

// MARK: - SOS metric
struct SOSMetric: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.red)
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.white)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Wave progress row
struct SOSWaveRow: View {
    let wave: BroadcastWave
    let isActive: Bool
    let isCompleted: Bool

    var statusIcon: String {
        if isCompleted { return "checkmark.circle.fill" }
        if isActive    { return "dot.radiowaves.left.and.right" }
        return "circle"
    }

    var statusColor: Color {
        if isCompleted { return .green }
        if isActive    { return .red }
        return .white.opacity(0.3)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.body)
                .foregroundStyle(statusColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(wave.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isActive || isCompleted ? Color.white : Color.white.opacity(0.5))
                Text("\(Int(wave.radius)) km radius")
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.5))
            }

            Spacer()

            if isActive {
                Text("BROADCASTING")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.red)
                    .kerning(0.8)
            } else if isCompleted {
                Text("COMPLETED")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.green)
                    .kerning(0.8)
            } else {
                Text("WAITING")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.white.opacity(0.3))
                    .kerning(0.8)
            }
        }
        .padding(12)
        .background(
            isActive
            ? Color.red.opacity(0.1)
            : Color.white.opacity(0.03)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isActive ? Color.red.opacity(0.4) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    EmergencySOSView()
}
