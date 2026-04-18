//
//  ContentView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 18/4/26.
//

import SwiftUI
import Combine

// MARK: - Theme manager
class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
}

// MARK: - Theme option model
struct ThemeOption {
    let label: String
    let icon: String
    let scheme: ColorScheme?
}

let themeOptions: [ThemeOption] = [
    ThemeOption(label: "System", icon: "circle.lefthalf.filled", scheme: nil),
    ThemeOption(label: "Light",  icon: "sun.max.fill",           scheme: .light),
    ThemeOption(label: "Dark",   icon: "moon.fill",              scheme: .dark)
]

// MARK: - App root
struct ContentView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var isLoggedIn = false
    @State private var isRegistered = false
    @State private var signedInWith: String = ""

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true
    @State private var showSplash = true

    var body: some View {
        ZStack {

            // MARK: Main app content
            Group {
                if isRegistered {
                    HomeView()
                } else if isLoggedIn {
                    RegistrationView(
                        signedInWith: signedInWith,
                        onSignOut: {
                            withAnimation {
                                isLoggedIn = false
                                signedInWith = ""
                            }
                        },
                        onComplete: {
                            withAnimation {
                                isRegistered = true
                            }
                        }
                    )
                } else {
                    LoginView(onLogin: { provider in
                        withAnimation {
                            signedInWith = provider
                            isLoggedIn = true
                        }
                    })
                }
            }
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.colorScheme)

            // MARK: Splash overlay
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                            hasSeenOnboarding = true
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            // Small delay so the root view is fully loaded first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !hasSeenOnboarding {
                    showSplash = true
                }
            }
        }
    }
}

// MARK: - Reusable theme picker bar
struct ThemePickerBar: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<themeOptions.count, id: \.self) { i in
                let option = themeOptions[i]
                let isSelected = themeManager.colorScheme == option.scheme
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        themeManager.colorScheme = option.scheme
                    }
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected
                                      ? Color.blue.opacity(0.12)
                                      : Color.gray.opacity(0.15))
                                .frame(height: 48)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            isSelected ? Color.blue : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            Image(systemName: option.icon)
                                .font(.title3)
                                .foregroundStyle(isSelected ? Color.blue : Color.gray)
                        }
                        Text(option.label)
                            .font(.caption)
                            .fontWeight(isSelected ? .semibold : .regular)
                            .foregroundStyle(isSelected ? Color.blue : Color.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Login screen
struct LoginView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onLogin: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // Logo
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "drop.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.red)
                }

                Text("BloodLink")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("Connecting donors with those who need them most.")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 14) {

                Text("SIGN IN TO CONTINUE")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
                    .kerning(0.8)

                // Apple button
                Button {
                    onLogin("Apple")
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "apple.logo")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.primary)
                        Text("Continue with Apple")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                // Google button
                Button {
                    onLogin("Google")
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                            Text("G")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.blue)
                        }
                        Text("Continue with Google")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Text("By continuing you agree to BloodLink's Terms of Service and Privacy Policy.")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            // Theme picker
            VStack(spacing: 8) {
                Text("APPEARANCE")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
                    .kerning(0.8)
                ThemePickerBar()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Registration form
struct RegistrationView: View {
    @EnvironmentObject var themeManager: ThemeManager

    let signedInWith: String
    let onSignOut: () -> Void
    let onComplete: () -> Void

    // Personal details
    @State private var passportName = ""
    @State private var dateOfBirth = Date()
    @State private var bloodGroup = "A+"
    @State private var sex = "Male"
    @State private var showDatePicker = false
    @State private var showAgeError = false

    // Height & weight
    @State private var heightCm: Double = 170
    @State private var weightKg: Double = 70
    @State private var heightUnit = "cm"

    // Last donation
    @State private var hasDonateBefore = false
    @State private var lastDonationDate = Date()
    @State private var showLastDonationPicker = false
    @State private var lastDonationUnknown = false

    let bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    let sexOptions   = ["Male", "Female", "Other"]
    let heightUnits  = ["cm", "m", "ft"]

    // MARK: Age
    var ageComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: dateOfBirth, to: Date())
    }
    var exactAge: String {
        let y = ageComponents.year ?? 0
        let m = ageComponents.month ?? 0
        let d = ageComponents.day ?? 0
        return "\(y) yrs, \(m) mos, \(d) days"
    }
    var ageYears: Int { ageComponents.year ?? 0 }
    var formattedDOB: String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: dateOfBirth)
    }
    var maximumDate: Date {
        Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    }

    // MARK: Height
    var heightInMetres: Double { heightCm / 100 }
    var heightInFeet: Double   { heightCm / 30.48 }
    var heightFeetPart: Int    { Int(heightInFeet) }
    var heightInchesPart: Int  { Int((heightInFeet - Double(heightFeetPart)) * 12) }
    var heightDisplayValue: String {
        switch heightUnit {
        case "cm": return "\(Int(heightCm)) cm"
        case "m":  return String(format: "%.2f m", heightInMetres)
        case "ft": return "\(heightFeetPart) ft \(heightInchesPart) in"
        default:   return "\(Int(heightCm)) cm"
        }
    }
    var heightFullBreakdown: String {
        "\(Int(heightCm)) cm  ·  \(String(format: "%.2f", heightInMetres)) m  ·  \(heightFeetPart) ft \(heightInchesPart) in"
    }

    // MARK: BMI
    var bmi: Double {
        let hm = heightInMetres
        guard hm > 0 else { return 0 }
        return weightKg / (hm * hm)
    }
    var bmiLabel: String {
        switch bmi {
        case ..<18.5:   return "Underweight"
        case 18.5..<25: return "Healthy weight"
        case 25..<30:   return "Overweight"
        default:        return "Obese"
        }
    }
    var bmiColor: Color {
        switch bmi {
        case ..<18.5:   return .blue
        case 18.5..<25: return .green
        case 25..<30:   return .orange
        default:        return .red
        }
    }

    // MARK: Last donation
    var lastDonationDisplay: String {
        if lastDonationUnknown { return "Unknown" }
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: lastDonationDate)
    }
    var daysSinceLastDonation: Int? {
        guard hasDonateBefore && !lastDonationUnknown else { return nil }
        return Calendar.current.dateComponents([.day], from: lastDonationDate, to: Date()).day
    }
    var nextEligibleDateString: String? {
        guard let days = daysSinceLastDonation else { return nil }
        let remaining = 90 - days
        if remaining <= 0 { return "Eligible to donate now" }
        let next = Calendar.current.date(byAdding: .day, value: remaining, to: Date()) ?? Date()
        let f = DateFormatter()
        f.dateStyle = .long
        return "Eligible from \(f.string(from: next))"
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            Form {

                // MARK: Signed in banner
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: signedInWith == "Apple"
                              ? "apple.logo"
                              : "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(signedInWith == "Apple"
                                             ? Color.primary
                                             : Color.blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Signed in with \(signedInWith)")
                                .font(.subheadline.weight(.semibold))
                            Text("Your account is linked and secure.")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }

                        Spacer()

                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Color.green)
                    }
                    .padding(.vertical, 4)

                    Button("Sign out") {
                        onSignOut()
                    }
                    .foregroundStyle(Color.red)
                }

                // MARK: Personal details
                Section("Personal details") {

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Full name as per passport", text: $passportName)
                            .autocorrectionDisabled()
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                        Text("Enter your name exactly as it appears on your passport or government ID.")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.vertical, 2)

                    Picker("Sex", selection: $sex) {
                        ForEach(sexOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Date of birth")
                        Spacer()
                        Text(formattedDOB)
                            .foregroundStyle(Color.blue)
                            .onTapGesture {
                                withAnimation { showDatePicker.toggle() }
                            }
                    }

                    if showDatePicker {
                        DatePicker(
                            "Select date",
                            selection: $dateOfBirth,
                            in: ...maximumDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .onChange(of: dateOfBirth) {
                            withAnimation { showDatePicker = false }
                        }
                    }

                    if !showDatePicker {
                        HStack {
                            Text("Age")
                            Spacer()
                            Text(exactAge)
                                .foregroundStyle(Color.gray)
                                .font(.subheadline)
                        }
                    }

                    Picker("Blood group", selection: $bloodGroup) {
                        ForEach(bloodGroups, id: \.self) { Text($0) }
                    }
                }

                // MARK: Body measurements
                Section("Body measurements") {

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Height")
                            Spacer()
                            HStack(spacing: 0) {
                                ForEach(heightUnits, id: \.self) { unit in
                                    Button(unit) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            heightUnit = unit
                                        }
                                    }
                                    .font(.caption)
                                    .fontWeight(heightUnit == unit ? .semibold : .regular)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(heightUnit == unit
                                                ? Color.blue
                                                : Color.clear)
                                    .foregroundStyle(heightUnit == unit
                                                     ? Color.white
                                                     : Color.blue)
                                    .clipShape(Capsule())
                                }
                            }
                            .overlay(Capsule().stroke(Color.blue.opacity(0.4), lineWidth: 1))
                            .clipShape(Capsule())
                        }

                        Text(heightDisplayValue)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .contentTransition(.numericText())

                        Slider(value: $heightCm, in: 50...250, step: 1)
                            .tint(.blue)

                        Text(heightFullBreakdown)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.vertical, 6)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text("\(Int(weightKg)) kg  ·  \(String(format: "%.1f", weightKg * 2.205)) lbs")
                                .foregroundStyle(Color.gray)
                                .font(.subheadline)
                        }
                        Slider(value: $weightKg, in: 20...250, step: 1)
                            .tint(.blue)
                    }
                    .padding(.vertical, 4)
                }

                // MARK: BMI
                Section("BMI") {
                    VStack(spacing: 12) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", bmi))
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundStyle(bmiColor)
                                .contentTransition(.numericText())
                            Text("BMI")
                                .font(.title3)
                                .foregroundStyle(Color.gray)
                                .padding(.bottom, 6)
                        }
                        .frame(maxWidth: .infinity)

                        Text(bmiLabel)
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(bmiColor.opacity(0.15))
                            .foregroundStyle(bmiColor)
                            .clipShape(Capsule())

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(LinearGradient(
                                        colors: [.blue, .green, .orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(height: 10)
                                let clampedBMI = min(max(bmi, 10), 40)
                                let fraction   = (clampedBMI - 10) / 30
                                let xPos       = geo.size.width * fraction
                                Circle()
                                    .fill(Color.white)
                                    .overlay(Circle().stroke(bmiColor, lineWidth: 2.5))
                                    .frame(width: 18, height: 18)
                                    .offset(x: xPos - 9, y: -4)
                            }
                        }
                        .frame(height: 18)
                        .padding(.horizontal, 4)

                        HStack {
                            ForEach(["10", "18.5", "25", "30", "40+"], id: \.self) { label in
                                Text(label)
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                                if label != "40+" { Spacer() }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // MARK: Donation history
                Section("Donation history") {

                    Toggle("I have donated blood before", isOn: $hasDonateBefore.animation())

                    if hasDonateBefore {

                        Toggle(
                            "I don't know the exact date",
                            isOn: $lastDonationUnknown.animation()
                        )
                        .onChange(of: lastDonationUnknown) {
                            if lastDonationUnknown { showLastDonationPicker = false }
                        }

                        if !lastDonationUnknown {
                            HStack {
                                Text("Last donation")
                                Spacer()
                                Text(lastDonationDisplay)
                                    .foregroundStyle(Color.blue)
                                    .onTapGesture {
                                        withAnimation { showLastDonationPicker.toggle() }
                                    }
                            }

                            if showLastDonationPicker {
                                DatePicker(
                                    "Select date",
                                    selection: $lastDonationDate,
                                    in: ...Date(),
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.graphical)
                                .onChange(of: lastDonationDate) {
                                    withAnimation { showLastDonationPicker = false }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            if lastDonationUnknown {
                                Label(
                                    "Date unknown — we'll use today as your last donation date for safety.",
                                    systemImage: "calendar.badge.exclamationmark"
                                )
                                .font(.caption)
                                .foregroundStyle(Color.orange)
                            } else if let days = daysSinceLastDonation {
                                Label(
                                    "\(days) days since last donation",
                                    systemImage: "drop.fill"
                                )
                                .font(.caption)
                                .foregroundStyle(Color.red)
                                if let next = nextEligibleDateString {
                                    Label(
                                        next,
                                        systemImage: days >= 90
                                        ? "checkmark.circle.fill"
                                        : "clock"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(days >= 90 ? Color.green : Color.gray)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // MARK: Age error
                if showAgeError {
                    Section {
                        Label(
                            "You must be 18 or older to register as a donor.",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(Color.red)
                        .font(.footnote)
                    }
                }

                // MARK: Register button
                Section {
                    Button("Complete registration") {
                        showAgeError = ageYears < 18
                        if ageYears >= 18 {
                            onComplete()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(passportName.isEmpty)
                }
            }
            .navigationTitle("Donor registration")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

#Preview {
    ContentView()
}
