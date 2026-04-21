//
//  ProfileView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 19/4/26.
//

import SwiftUI
import PhotosUI

// MARK: - Avatar image helper
struct AvatarImageView: View {
    let data: Data
    let size: CGFloat

    var body: some View {
        #if canImport(UIKit)
        if let uiImg = UIImage(data: data) {
            Image(uiImage: uiImg)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
        #elseif canImport(AppKit)
        if let nsImg = NSImage(data: data) {
            Image(nsImage: nsImg)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
        #endif
    }
}

// MARK: - Badge tier
enum DonorBadge: String {
    case bronze   = "Bronze"
    case silver   = "Silver"
    case gold     = "Gold"
    case platinum = "Platinum"

    init(donationCount: Int) {
        switch donationCount {
        case 0..<3:  self = .bronze
        case 3..<6:  self = .silver
        case 6..<10: self = .gold
        default:     self = .platinum
        }
    }

    var color: Color {
        switch self {
        case .bronze:   return Color(red: 0.80, green: 0.50, blue: 0.20)
        case .silver:   return Color(red: 0.60, green: 0.60, blue: 0.65)
        case .gold:     return Color(red: 0.85, green: 0.70, blue: 0.10)
        case .platinum: return Color(red: 0.40, green: 0.75, blue: 0.90)
        }
    }

    var icon: String {
        switch self {
        case .bronze:   return "medal.fill"
        case .silver:   return "medal.fill"
        case .gold:     return "trophy.fill"
        case .platinum: return "crown.fill"
        }
    }

    var nextMilestone: Int {
        switch self {
        case .bronze:   return 3
        case .silver:   return 6
        case .gold:     return 10
        case .platinum: return 999
        }
    }

    var description: String {
        switch self {
        case .bronze:   return "New donor — keep going!"
        case .silver:   return "Regular donor — great work!"
        case .gold:     return "Dedicated donor — amazing!"
        case .platinum: return "Elite donor — legend!"
        }
    }
}

// MARK: - Donation record
struct DonationRecord: Identifiable {
    let id = UUID()
    let date: Date
    let location: String
    let bloodType: String
    var hasReport: Bool
    var reportName: String?
    var recipientName: String = "Anonymous"
}

// MARK: - Profile view
struct ProfileView: View {

    @EnvironmentObject var themeManager: ThemeManager

    @State private var passportName = "Sowad Hossain Rafi"
    @State private var bloodGroup = "A+"
    @State private var sex = "Male"
    @State private var dateOfBirth = Calendar.current.date(
        from: DateComponents(year: 1998, month: 6, day: 15)
    ) ?? Date()
    @State private var heightCm: Double = 175
    @State private var weightKg: Double = 72
    @State private var address = "Dhaka, Bangladesh"
    @State private var isEditing = false
    @State private var showDatePicker = false
    @State private var showIDUpload = false
    @State private var showRecoveryUpdates = false
    @State private var selectedDonationForReport: DonationRecord? = nil
    @State private var selectedDonationDetail: DonationDetail? = nil

    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var avatarData: Data? = nil

    @State private var isOnline = true
    @State private var donationCount = 4

    @State private var donations: [DonationRecord] = [
        DonationRecord(
            date: Date().addingTimeInterval(-86400 * 200),
            location: "Dhaka Medical College",
            bloodType: "A+",
            hasReport: true,
            reportName: "Report_Jan2025.pdf",
            recipientName: "Hasan"
        ),
        DonationRecord(
            date: Date().addingTimeInterval(-86400 * 120),
            location: "Square Hospital",
            bloodType: "A+",
            hasReport: true,
            reportName: "Report_Apr2025.pdf",
            recipientName: "Farida"
        ),
        DonationRecord(
            date: Date().addingTimeInterval(-86400 * 60),
            location: "City Hospital",
            bloodType: "A+",
            hasReport: false,
            reportName: nil,
            recipientName: "Tariq"
        ),
        DonationRecord(
            date: Date().addingTimeInterval(-86400 * 10),
            location: "Popular Diagnostic",
            bloodType: "A+",
            hasReport: true,
            reportName: "Report_Dec2025.pdf",
            recipientName: "Nadia"
        ),
    ]

    let bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    let sexOptions   = ["Male", "Female", "Other"]

    // MARK: Computed
    var badge: DonorBadge { DonorBadge(donationCount: donationCount) }

    var ageString: String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: dateOfBirth, to: Date())
        return "\(c.year ?? 0) yrs, \(c.month ?? 0) mos, \(c.day ?? 0) days"
    }

    var formattedDOB: String {
        let f = DateFormatter(); f.dateStyle = .long
        return f.string(from: dateOfBirth)
    }

    var bmi: Double {
        let hm = heightCm / 100
        guard hm > 0 else { return 0 }
        return weightKg / (hm * hm)
    }

    var bmiLabel: String {
        switch bmi {
        case ..<18.5:   return "Underweight"
        case 18.5..<25: return "Healthy"
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

    var nextEligibleDate: Date {
        donations.sorted { $0.date > $1.date }.first.map {
            Calendar.current.date(byAdding: .day, value: 90, to: $0.date) ?? Date()
        } ?? Date()
    }

    var isEligible: Bool { nextEligibleDate <= Date() }

    var formattedNextEligible: String {
        let f = DateFormatter(); f.dateStyle = .medium
        return f.string(from: nextEligibleDate)
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            Form {

                // MARK: Avatar + name header
                Section {
                    HStack(spacing: 16) {
                        PhotosPicker(selection: $avatarItem, matching: .images) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.12))
                                    .frame(width: 72, height: 72)

                                if let data = avatarData {
                                    AvatarImageView(data: data, size: 72)
                                } else {
                                    Text(String(passportName.prefix(1)))
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundStyle(Color.red)
                                }

                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Color.white)
                                    )
                                    .offset(x: 24, y: 24)
                            }
                        }
                        .onChange(of: avatarItem) {
                            Task {
                                if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                                    avatarData = data
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(passportName).font(.title3.weight(.bold))
                            Text(bloodGroup + " · " + sex)
                                .font(.subheadline).foregroundStyle(Color.red)
                            Text(ageString).font(.caption).foregroundStyle(Color.gray)
                        }

                        Spacer()

                        VStack(spacing: 4) {
                            Circle()
                                .fill(isOnline ? Color.green : Color.gray)
                                .frame(width: 12, height: 12)
                            Text(isOnline ? "Online" : "Offline")
                                .font(.caption2).foregroundStyle(Color.gray)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // MARK: Donation badge
                Section {
                    VStack(spacing: 14) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(badge.color.opacity(0.15))
                                    .frame(width: 64, height: 64)
                                Image(systemName: badge.icon)
                                    .font(.system(size: 28))
                                    .foregroundStyle(badge.color)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(badge.rawValue)
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(badge.color)
                                    Text("Donor").font(.title3.weight(.bold))
                                }
                                Text(badge.description)
                                    .font(.caption).foregroundStyle(Color.gray)
                            }

                            Spacer()

                            VStack(spacing: 2) {
                                Text("\(donationCount)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.red)
                                Text("donations").font(.caption2).foregroundStyle(Color.gray)
                            }
                        }

                        if badge != .platinum {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Progress to \(nextBadge(badge).rawValue)")
                                        .font(.caption).foregroundStyle(Color.gray)
                                    Spacer()
                                    Text("\(donationCount) / \(badge.nextMilestone)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(badge.color)
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(height: 8)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(badge.color)
                                            .frame(
                                                width: geo.size.width * min(
                                                    Double(donationCount) / Double(badge.nextMilestone), 1.0
                                                ),
                                                height: 8
                                            )
                                    }
                                }
                                .frame(height: 8)
                            }
                        } else {
                            Label("You have reached the highest tier!", systemImage: "crown.fill")
                                .font(.caption).foregroundStyle(badge.color)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: isEligible ? "checkmark.circle.fill" : "clock.fill")
                                .foregroundStyle(isEligible ? Color.green : Color.orange)
                            Text(isEligible
                                 ? "Eligible to donate now"
                                 : "Next eligible: \(formattedNextEligible)")
                                .font(.caption)
                                .foregroundStyle(isEligible ? Color.green : Color.orange)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background((isEligible ? Color.green : Color.orange).opacity(0.1))
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 6)
                }

                // MARK: Personal details
                Section("Personal details") {
                    if isEditing {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Full name as per passport", text: $passportName)
                                .autocorrectionDisabled()
                                #if os(iOS)
                                .textInputAutocapitalization(.words)
                                #endif
                            Text("As it appears on your passport or government ID.")
                                .font(.caption).foregroundStyle(Color.gray)
                        }

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
                                in: ...Date(),
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .onChange(of: dateOfBirth) {
                                withAnimation { showDatePicker = false }
                            }
                        }

                        Picker("Blood group", selection: $bloodGroup) {
                            ForEach(bloodGroups, id: \.self) { Text($0) }
                        }

                        TextField("Address", text: $address)

                    } else {
                        ProfileRow(label: "Name",       value: passportName)
                        ProfileRow(label: "Sex",        value: sex)
                        ProfileRow(label: "Born",       value: formattedDOB)
                        ProfileRow(label: "Age",        value: ageString)
                        ProfileRow(label: "Blood type", value: bloodGroup)
                        ProfileRow(label: "Address",    value: address)
                    }
                }

                // MARK: Body stats
                Section("Body stats") {
                    if isEditing {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Height")
                                Spacer()
                                Text("\(Int(heightCm)) cm").foregroundStyle(Color.gray)
                            }
                            Slider(value: $heightCm, in: 50...250, step: 1).tint(.blue)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Weight")
                                Spacer()
                                Text("\(Int(weightKg)) kg").foregroundStyle(Color.gray)
                            }
                            Slider(value: $weightKg, in: 20...250, step: 1).tint(.blue)
                        }
                    } else {
                        ProfileRow(label: "Height", value: "\(Int(heightCm)) cm")
                        ProfileRow(label: "Weight", value: "\(Int(weightKg)) kg")
                    }

                    HStack {
                        Text("BMI")
                        Spacer()
                        Text(String(format: "%.1f", bmi))
                            .fontWeight(.semibold).foregroundStyle(bmiColor)
                        Text("·").foregroundStyle(Color.gray)
                        Text(bmiLabel).font(.subheadline).foregroundStyle(bmiColor)
                    }
                }

                // MARK: Identity verification
                Section("Identity verification") {
                    Button {
                        showIDUpload = true
                    } label: {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundStyle(Color.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ID documents")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.primary)
                                Text("Update your passport or national ID")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Color.green)
                                .font(.caption)
                        }
                    }
                }
                .sheet(isPresented: $showIDUpload) {
                    IDUploadView(isEditMode: true)
                }

                // MARK: Donations received (recipient side)
                Section("Donations received") {
                    Button {
                        showRecoveryUpdates = true
                    } label: {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                                .foregroundStyle(Color.red)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("My recovery journey")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.primary)
                                Text("Post updates to your donors")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .sheet(isPresented: $showRecoveryUpdates) {
                    RecoveryUpdateView(
                        donorName: "Sowad Hossain Rafi",
                        donationDate: Date().addingTimeInterval(-86400 * 30),
                        updates: []
                    )
                }

                // MARK: Donation timeline
                Section("Donation history") {
                    if donations.isEmpty {
                        Text("No donations recorded yet.")
                            .font(.subheadline).foregroundStyle(Color.gray)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(Array(donations.enumerated()), id: \.element.id) { index, donation in
                            Button {
                                selectedDonationDetail = buildDetail(for: donation)
                            } label: {
                                DonationTimelineRow(
                                    donation: donation,
                                    isLast: index == donations.count - 1,
                                    onUploadReport: {
                                        selectedDonationForReport = donation
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .sheet(item: $selectedDonationForReport) { donation in
                    BloodReportUploadView(
                        donorName: donation.recipientName,
                        donorBloodType: donation.bloodType,
                        donationDate: donation.date,
                        hospital: donation.location,
                        onComplete: { uploadType in
                            if let index = donations.firstIndex(where: { $0.id == donation.id }) {
                                withAnimation {
                                    donations[index].hasReport = true
                                    switch uploadType {
                                    case .pdf(_, let name):
                                        donations[index].reportName = name
                                    case .image:
                                        donations[index].reportName = "Blood_Report.jpg"
                                    case .none:
                                        break
                                    }
                                }
                            }
                        }
                    )
                }
                .sheet(item: $selectedDonationDetail) { detail in
                    DonationDetailView(detail: detail)
                }

                // MARK: Danger zone
                Section {
                    Button("Sign out") {}.foregroundStyle(Color.red)
                    Button("Delete account") {}.foregroundStyle(Color.red)
                }
            }
            .navigationTitle("My Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        withAnimation { isEditing.toggle() }
                    }
                    .fontWeight(isEditing ? .bold : .regular)
                    .foregroundStyle(isEditing ? Color.green : Color.blue)
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(
                        destination: SettingsView().environmentObject(themeManager)
                    ) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.gray)
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(isEditing ? "Save" : "Edit") {
                        withAnimation { isEditing.toggle() }
                    }
                    .fontWeight(isEditing ? .bold : .regular)
                    .foregroundStyle(isEditing ? Color.green : Color.blue)
                }
                ToolbarItem(placement: .automatic) {
                    NavigationLink(
                        destination: SettingsView().environmentObject(themeManager)
                    ) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.gray)
                    }
                }
                #endif
            }
        }
    }

    func nextBadge(_ current: DonorBadge) -> DonorBadge {
        switch current {
        case .bronze:   return .silver
        case .silver:   return .gold
        case .gold:     return .platinum
        case .platinum: return .platinum
        }
    }

    // MARK: - Build detail
    func buildDetail(for donation: DonationRecord) -> DonationDetail {
        let messages: [String] = [
            "Thank you so much for your donation. My father is recovering well thanks to your kindness. We are forever grateful to you and BloodLink. May Allah bless you always.",
            "Your kindness saved my sister's life. She just came home from the hospital yesterday. Thank you from the bottom of our hearts.",
            "I can never thank you enough. Because of you, my wife made it through surgery. You are an angel sent to us.",
            "You will always be in our prayers. Thank you for caring about a stranger."
        ]
        let statuses: [RecoveryStatus] = [.fullRecovery, .discharged, .stable, .recovering]
        let notes: [String] = [
            "Patient fully recovered after 3 weeks. Discharged and back to normal life.",
            "Released from hospital last week. Returning for follow-up in 2 weeks.",
            "Vital signs stable. Expected to be discharged soon.",
            "Still in recovery. Responding well to treatment."
        ]
        let index = abs(donation.recipientName.hashValue) % messages.count
        return DonationDetail(
            record: donation,
            thankYouMessage: donation.hasReport ? messages[index] : "",
            recoveryStatus: statuses[index],
            recoveryNote: notes[index],
            unitsDonated: Int.random(in: 1...2),
            hospital: donation.location
        )
    }
}

// MARK: - Profile row
struct ProfileRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).foregroundStyle(Color.primary)
            Spacer()
            Text(value).foregroundStyle(Color.gray).multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Donation timeline row
struct DonationTimelineRow: View {
    let donation: DonationRecord
    let isLast: Bool
    let onUploadReport: () -> Void

    var formattedDate: String {
        let f = DateFormatter(); f.dateStyle = .medium
        return f.string(from: donation.date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(donation.hasReport ? Color.green : Color.orange)
                    .frame(width: 12, height: 12)
                    .padding(.top, 4)
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 2)
                }
            }
            .frame(width: 12)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(formattedDate).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(donation.bloodType)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .clipShape(Capsule())
                }

                Text(donation.location).font(.caption).foregroundStyle(Color.gray)

                if donation.hasReport, let reportName = donation.reportName {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.fill").font(.caption).foregroundStyle(Color.blue)
                        Text(reportName).font(.caption).foregroundStyle(Color.blue)
                        Spacer()
                        Image(systemName: "arrow.down.circle").font(.caption).foregroundStyle(Color.blue)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Button {
                        onUploadReport()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.caption)
                                .foregroundStyle(Color.orange)
                            Text("Upload report")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.orange)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(Color.orange.opacity(0.6))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 4) {
                    Image(systemName: "arrow.right.circle")
                        .font(.caption2)
                    Text("Tap for details")
                        .font(.caption2)
                }
                .foregroundStyle(Color.gray.opacity(0.6))
                .padding(.top, 2)
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfileView()
        .environmentObject(ThemeManager())
}
