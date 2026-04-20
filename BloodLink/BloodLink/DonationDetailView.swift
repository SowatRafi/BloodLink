//
//  DonationDetailView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 20/4/26.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - Recovery status
enum RecoveryStatus: String {
    case critical    = "Critical"
    case recovering  = "Recovering"
    case stable      = "Stable"
    case discharged  = "Discharged"
    case fullRecovery = "Full recovery"

    var color: Color {
        switch self {
        case .critical:     return .red
        case .recovering:   return .orange
        case .stable:       return .yellow
        case .discharged:   return .blue
        case .fullRecovery: return .green
        }
    }

    var icon: String {
        switch self {
        case .critical:     return "heart.slash.fill"
        case .recovering:   return "bandage.fill"
        case .stable:       return "heart.fill"
        case .discharged:   return "figure.walk"
        case .fullRecovery: return "checkmark.seal.fill"
        }
    }

    var description: String {
        switch self {
        case .critical:     return "Patient needs immediate care"
        case .recovering:   return "Slowly improving"
        case .stable:       return "Out of danger"
        case .discharged:   return "Left the hospital"
        case .fullRecovery: return "Fully recovered"
        }
    }
}

// MARK: - Donation detail model
struct DonationDetail: Identifiable {
    let id = UUID()
    let record: DonationRecord
    let thankYouMessage: String
    let recoveryStatus: RecoveryStatus
    let recoveryNote: String
    let unitsDonated: Int
    let hospital: String
}

// MARK: - Donation detail view
struct DonationDetailView: View {

    @Environment(\.dismiss) private var dismiss

    let detail: DonationDetail
    @State private var showShareSheet = false
    @State private var showDownloadConfirm = false
    @State private var certificateImage: Data? = nil

    var formattedDate: String {
        let f = DateFormatter(); f.dateStyle = .full
        return f.string(from: detail.record.date)
    }

    var shortDate: String {
        let f = DateFormatter(); f.dateStyle = .medium
        return f.string(from: detail.record.date)
    }

    var daysSince: Int {
        Calendar.current.dateComponents([.day], from: detail.record.date, to: Date()).day ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Certificate card
                    DonationCertificate(
                        donorName: "Sowad Hossain Rafi",
                        bloodType: detail.record.bloodType,
                        date: shortDate,
                        recipientName: detail.record.recipientName,
                        hospital: detail.hospital,
                        units: detail.unitsDonated
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // MARK: Share & download buttons
                    HStack(spacing: 10) {
                        Button {
                            showShareSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        Button {
                            showDownloadConfirm = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Download")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(Color.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)

                    // MARK: Donation info
                    DetailSectionHeader(title: "Donation details", icon: "drop.fill")

                    VStack(spacing: 10) {
                        DetailRow(
                            icon: "calendar",
                            iconColor: .blue,
                            label: "Date",
                            value: formattedDate
                        )
                        DetailRow(
                            icon: "clock.fill",
                            iconColor: .purple,
                            label: "Time since",
                            value: "\(daysSince) days ago"
                        )
                        DetailRow(
                            icon: "building.2.fill",
                            iconColor: .orange,
                            label: "Hospital",
                            value: detail.hospital
                        )
                        DetailRow(
                            icon: "drop.fill",
                            iconColor: .red,
                            label: "Blood type",
                            value: detail.record.bloodType
                        )
                        DetailRow(
                            icon: "testtube.2",
                            iconColor: .pink,
                            label: "Units donated",
                            value: "\(detail.unitsDonated)"
                        )
                        DetailRow(
                            icon: "person.fill",
                            iconColor: .green,
                            label: "Recipient",
                            value: detail.record.recipientName
                        )
                    }
                    .padding(14)
                    .background(Color.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)

                    // MARK: Recovery status
                    DetailSectionHeader(title: "Recipient recovery", icon: "heart.fill")

                    VStack(spacing: 12) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(detail.recoveryStatus.color.opacity(0.15))
                                    .frame(width: 56, height: 56)
                                Image(systemName: detail.recoveryStatus.icon)
                                    .font(.title2)
                                    .foregroundStyle(detail.recoveryStatus.color)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(detail.recoveryStatus.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(detail.recoveryStatus.color)
                                Text(detail.recoveryStatus.description)
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }

                            Spacer()
                        }

                        if !detail.recoveryNote.isEmpty {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "quote.opening")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray.opacity(0.5))
                                Text(detail.recoveryNote)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.primary)
                                    .italic()
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.gray.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Timeline
                        HStack(spacing: 0) {
                            ForEach([
                                RecoveryStatus.critical,
                                .recovering,
                                .stable,
                                .discharged,
                                .fullRecovery
                            ], id: \.self) { status in
                                let isActive = statusRank(detail.recoveryStatus) >= statusRank(status)
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(isActive ? status.color : Color.gray.opacity(0.2))
                                        .frame(width: 12, height: 12)
                                    Text(status.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(isActive ? Color.primary : Color.gray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth: .infinity)

                                if status != .fullRecovery {
                                    Rectangle()
                                        .fill(isActive ? status.color : Color.gray.opacity(0.2))
                                        .frame(height: 2)
                                        .padding(.bottom, 20)
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)

                    // MARK: Thank you message
                    if !detail.thankYouMessage.isEmpty {
                        DetailSectionHeader(title: "Thank you", icon: "heart.circle.fill")

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Text(String(detail.record.recipientName.prefix(1)))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color.red)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(detail.record.recipientName)
                                        .font(.subheadline.weight(.semibold))
                                    Text("Recipient")
                                        .font(.caption2)
                                        .foregroundStyle(Color.gray)
                                }
                                Spacer()
                            }

                            Text(detail.thankYouMessage)
                                .font(.subheadline)
                                .foregroundStyle(Color.primary)
                                .lineSpacing(3)

                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color.red)
                                Text("Sent with gratitude")
                                    .font(.caption2)
                                    .foregroundStyle(Color.gray)
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        .padding(14)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.red.opacity(0.05),
                                    Color.pink.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.red.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                    }

                    // MARK: Blood report
                    if detail.record.hasReport, let reportName = detail.record.reportName {
                        DetailSectionHeader(title: "Blood report", icon: "doc.text.fill")

                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue.opacity(0.12))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "doc.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.blue)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reportName)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                Text("Shared by \(detail.record.recipientName)")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                            Spacer()
                            Button {
                                // View report
                            } label: {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.blue)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(14)
                        .background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 16)
                    } else {
                        DetailSectionHeader(title: "Blood report", icon: "doc.text.fill")

                        HStack(spacing: 10) {
                            Image(systemName: "doc.badge.clock")
                                .foregroundStyle(Color.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("No report yet")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.orange)
                                Text("The recipient hasn't shared a report yet")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.orange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 16)
                    }

                    // MARK: Impact summary
                    HStack(spacing: 14) {
                        Image(systemName: "heart.fill")
                            .font(.title)
                            .foregroundStyle(Color.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("You helped save a life")
                                .font(.subheadline.weight(.bold))
                            Text("Every donation can save up to 3 lives")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.red.opacity(0.12),
                                Color.pink.opacity(0.08)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Donation details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.gray)
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.gray)
                }
                #endif
            }
            #if os(iOS)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [buildShareText()])
            }
            #endif
            .confirmationDialog(
                "Download certificate",
                isPresented: $showDownloadConfirm,
                titleVisibility: .visible
            ) {
                Button("Save as PDF") {
                    // PDF save handled in future update
                }
                Button("Save as image") {
                    // Image save handled in future update
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose how to save your donation certificate.")
            }
        }
    }

    func statusRank(_ status: RecoveryStatus) -> Int {
        switch status {
        case .critical:     return 0
        case .recovering:   return 1
        case .stable:       return 2
        case .discharged:   return 3
        case .fullRecovery: return 4
        }
    }

    func buildShareText() -> String {
        """
        🩸 I donated blood on BloodLink!

        Donated: \(detail.record.bloodType) blood
        Date: \(shortDate)
        Hospital: \(detail.hospital)
        Units: \(detail.unitsDonated)

        Every donation can save up to 3 lives.

        Download BloodLink and start saving lives today.
        """
    }
}

// MARK: - Detail section header
struct DetailSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.red)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.gray)
                .textCase(.uppercase)
                .kerning(0.5)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
}

// MARK: - Detail row
struct DetailRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(iconColor)
            }
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.primary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Fancy certificate
struct DonationCertificate: View {
    let donorName: String
    let bloodType: String
    let date: String
    let recipientName: String
    let hospital: String
    let units: Int

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.96, blue: 0.96),
                            Color(red: 0.99, green: 0.95, blue: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .red.opacity(0.12), radius: 20, x: 0, y: 8)

            // Border decoration
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.red.opacity(0.6),
                            Color.red.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )

            // Inner border
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.red.opacity(0.15), lineWidth: 1)
                .padding(10)

            VStack(spacing: 14) {

                // Top decoration
                HStack {
                    Image(systemName: "laurel.leading")
                        .font(.title2)
                        .foregroundStyle(Color.red.opacity(0.6))
                    Spacer()
                    Image(systemName: "laurel.trailing")
                        .font(.title2)
                        .foregroundStyle(Color.red.opacity(0.6))
                }
                .padding(.horizontal, 30)

                // Blood drop with blood type
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.red.opacity(0.3),
                                    Color.red.opacity(0.05)
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 50
                            )
                        )
                        .frame(width: 90, height: 90)

                    ZStack {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 58))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.red,
                                        Color(red: 0.7, green: 0.05, blue: 0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .red.opacity(0.4), radius: 6, x: 0, y: 2)

                        Text(bloodType)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(Color.white)
                            .offset(y: 6)
                    }
                }

                // Title
                VStack(spacing: 4) {
                    Text("CERTIFICATE OF")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.red.opacity(0.7))
                        .kerning(3)

                    Text("Life Saved")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(Color.red)
                        .italic()
                }

                // Decorative divider
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.red.opacity(0.3))
                        .frame(height: 1)
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.red)
                    Rectangle()
                        .fill(Color.red.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, 40)

                // Donor name
                VStack(spacing: 6) {
                    Text("presented to")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                        .italic()

                    Text(donorName)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Text("for the generous donation of \(units) unit\(units > 1 ? "s" : "") of \(bloodType) blood")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .lineSpacing(2)
                }

                // Details row
                HStack(spacing: 20) {
                    VStack(spacing: 2) {
                        Text("DATE")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.gray.opacity(0.7))
                            .kerning(1)
                        Text(date)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.primary)
                    }

                    Rectangle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 1, height: 30)

                    VStack(spacing: 2) {
                        Text("FACILITY")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.gray.opacity(0.7))
                            .kerning(1)
                        Text(hospital)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                .padding(.top, 4)

                // Footer
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(Color.green)
                    Text("Verified by BloodLink")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.green)
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 26)
            .padding(.horizontal, 20)
        }
        .frame(minHeight: 460)
    }
}

// MARK: - Share sheet (iOS)
#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

#Preview {
    DonationDetailView(
        detail: DonationDetail(
            record: DonationRecord(
                date: Date().addingTimeInterval(-86400 * 30),
                location: "Dhaka Medical College",
                bloodType: "A+",
                hasReport: true,
                reportName: "Report_March2026.pdf",
                recipientName: "Hasan"
            ),
            thankYouMessage: "Thank you so much for your donation. My father is recovering well thanks to your kindness. We are forever grateful to you and BloodLink. May Allah bless you always.",
            recoveryStatus: .fullRecovery,
            recoveryNote: "Patient fully recovered after 3 weeks. Discharged and back to normal life.",
            unitsDonated: 2,
            hospital: "Dhaka Medical College"
        )
    )
}
