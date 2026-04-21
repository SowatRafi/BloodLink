//
//  RecoveryUpdateView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 21/4/26.
//

import SwiftUI
import PhotosUI

// MARK: - Recovery updater role
enum UpdaterRole: String, CaseIterable {
    case recipient    = "Recipient"
    case familyMember = "Family member"
    case doctor       = "Doctor"

    var icon: String {
        switch self {
        case .recipient:    return "person.fill"
        case .familyMember: return "person.2.fill"
        case .doctor:       return "cross.case.fill"
        }
    }

    var color: Color {
        switch self {
        case .recipient:    return .blue
        case .familyMember: return .purple
        case .doctor:       return .green
        }
    }
}

// MARK: - Recovery update model
struct RecoveryUpdate: Identifiable {
    let id = UUID()
    let status: RecoveryStatus
    let note: String
    let date: Date
    let updaterName: String
    let updaterRole: UpdaterRole
    let photoData: Data?

    var timeAgo: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Recovery update view (timeline of updates + new update form)
struct RecoveryUpdateView: View {

    @Environment(\.dismiss) private var dismiss

    let donorName: String
    let donationDate: Date
    @State var updates: [RecoveryUpdate]
    var onAdd: ((RecoveryUpdate) -> Void)? = nil

    @State private var showAddForm = false

    var latestUpdate: RecoveryUpdate? {
        updates.sorted { $0.date > $1.date }.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Header banner
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.12))
                                .frame(width: 56, height: 56)
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundStyle(Color.red)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Recovery journey")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                            Text("Recipient of \(donorName)'s donation")
                                .font(.subheadline.weight(.semibold))
                            if let latest = latestUpdate {
                                HStack(spacing: 4) {
                                    Image(systemName: latest.status.icon)
                                        .font(.caption2)
                                        .foregroundStyle(latest.status.color)
                                    Text(latest.status.rawValue)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(latest.status.color)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(Color.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)

                    // MARK: Add update button
                    Button {
                        showAddForm = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Post a new update")
                                .font(.body.weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)

                    // MARK: Who can update
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WHO CAN UPDATE")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.gray)
                            .kerning(0.8)
                            .padding(.horizontal, 16)

                        HStack(spacing: 8) {
                            ForEach(UpdaterRole.allCases, id: \.self) { role in
                                HStack(spacing: 6) {
                                    Image(systemName: role.icon)
                                        .font(.caption)
                                    Text(role.rawValue)
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(role.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(role.color.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // MARK: Timeline
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("UPDATES")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color.gray)
                                .kerning(0.8)
                            Spacer()
                            Text("\(updates.count) posts")
                                .font(.caption2)
                                .foregroundStyle(Color.gray)
                        }
                        .padding(.horizontal, 16)

                        if updates.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "clock.badge.questionmark")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color.gray.opacity(0.4))
                                Text("No updates yet")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.gray)
                                Text("Post the first update to let \(donorName) know how the recipient is doing.")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.vertical, 30)
                            .frame(maxWidth: .infinity)
                        } else {
                            ForEach(Array(updates.sorted { $0.date > $1.date }.enumerated()), id: \.element.id) { index, update in
                                RecoveryUpdateRow(
                                    update: update,
                                    isLast: index == updates.count - 1
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Donation info footer
                    HStack(spacing: 8) {
                        Image(systemName: "drop.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.red)
                        Text("Donation received \(formattedDonationDate)")
                            .font(.caption2)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Recovery updates")
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
            .sheet(isPresented: $showAddForm) {
                AddRecoveryUpdateView { newUpdate in
                    withAnimation {
                        updates.append(newUpdate)
                    }
                    onAdd?(newUpdate)
                }
            }
        }
    }

    var formattedDonationDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: donationDate)
    }
}

// MARK: - Recovery update row (timeline item)
struct RecoveryUpdateRow: View {
    let update: RecoveryUpdate
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Timeline dot + line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(update.status.color)
                        .frame(width: 16, height: 16)
                    Image(systemName: update.status.icon)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.white)
                }
                .padding(.top, 4)

                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 2)
                }
            }
            .frame(width: 16)

            // Content card
            VStack(alignment: .leading, spacing: 10) {

                // Header
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(update.updaterRole.color.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Text(String(update.updaterName.prefix(1)))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(update.updaterRole.color)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(update.updaterName)
                            .font(.caption.weight(.semibold))
                        HStack(spacing: 4) {
                            Image(systemName: update.updaterRole.icon)
                                .font(.system(size: 9))
                            Text(update.updaterRole.rawValue)
                                .font(.caption2)
                        }
                        .foregroundStyle(update.updaterRole.color)
                    }

                    Spacer()

                    Text(update.timeAgo)
                        .font(.caption2)
                        .foregroundStyle(Color.gray)
                }

                // Status pill
                HStack(spacing: 6) {
                    Image(systemName: update.status.icon)
                        .font(.caption)
                    Text(update.status.rawValue)
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(update.status.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(update.status.color.opacity(0.1))
                .clipShape(Capsule())

                // Note
                if !update.note.isEmpty {
                    Text(update.note)
                        .font(.subheadline)
                        .foregroundStyle(Color.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Photo
                if let data = update.photoData {
                    UpdatePhotoView(data: data)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(maxHeight: 200)
                }

                // Timestamp
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(update.formattedDate)
                        .font(.caption2)
                }
                .foregroundStyle(Color.gray.opacity(0.7))
            }
            .padding(14)
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.bottom, isLast ? 0 : 8)
        }
    }
}

// MARK: - Photo view (platform safe)
struct UpdatePhotoView: View {
    let data: Data

    var body: some View {
        #if canImport(UIKit)
        if let img = UIImage(data: data) {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        }
        #elseif canImport(AppKit)
        if let img = NSImage(data: data) {
            Image(nsImage: img)
                .resizable()
                .scaledToFill()
        }
        #endif
    }
}

// MARK: - Add update form
struct AddRecoveryUpdateView: View {

    @Environment(\.dismiss) private var dismiss

    let onSave: (RecoveryUpdate) -> Void

    @State private var selectedStatus: RecoveryStatus = .recovering
    @State private var note: String = ""
    @State private var updaterName: String = ""
    @State private var updaterRole: UpdaterRole = .familyMember
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil

    var isValid: Bool {
        !updaterName.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    // MARK: Updater info
                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel(title: "Your role", required: true)
                        HStack(spacing: 8) {
                            ForEach(UpdaterRole.allCases, id: \.self) { role in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        updaterRole = role
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: role.icon)
                                            .font(.title3)
                                            .foregroundStyle(
                                                updaterRole == role ? Color.white : role.color
                                            )
                                        Text(role.rawValue)
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(
                                                updaterRole == role ? Color.white : Color.primary
                                            )
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        updaterRole == role ? role.color : Color.gray.opacity(0.08)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Name
                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel(title: "Your name", required: true)
                        TextField("e.g. Ayesha Khan", text: $updaterName)
                            .padding(14)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                    }
                    .padding(.horizontal, 16)

                    // MARK: Status
                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel(title: "Current status", required: true)
                        VStack(spacing: 8) {
                            ForEach([
                                RecoveryStatus.critical,
                                .recovering,
                                .stable,
                                .discharged,
                                .fullRecovery
                            ], id: \.self) { status in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedStatus = status
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: status.icon)
                                            .font(.title3)
                                            .foregroundStyle(status.color)
                                            .frame(width: 32)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(status.rawValue)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color.primary)
                                            Text(status.description)
                                                .font(.caption)
                                                .foregroundStyle(Color.gray)
                                        }
                                        Spacer()
                                        Image(systemName: selectedStatus == status ? "largecircle.fill.circle" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(selectedStatus == status ? status.color : Color.gray.opacity(0.4))
                                    }
                                    .padding(12)
                                    .background(
                                        selectedStatus == status
                                        ? status.color.opacity(0.08)
                                        : Color.gray.opacity(0.05)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedStatus == status ? status.color : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Note
                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel(title: "Update note", required: false)
                        ZStack(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("e.g. Out of ICU today, vital signs improving. Doctor says we'll know more tomorrow.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.gray.opacity(0.6))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                            }
                            TextEditor(text: $note)
                                .frame(minHeight: 100)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 16)

                    // MARK: Photo
                    VStack(alignment: .leading, spacing: 8) {
                        SectionLabel(title: "Photo (optional)", required: false)

                        if let data = photoData {
                            ZStack(alignment: .topTrailing) {
                                UpdatePhotoView(data: data)
                                    .frame(height: 180)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Button {
                                    withAnimation { photoData = nil }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.white)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                        .padding(8)
                                }
                                .buttonStyle(.plain)
                            }
                        } else {
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                HStack(spacing: 10) {
                                    Image(systemName: "photo.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.blue)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Add a photo")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Color.primary)
                                        Text("Show a moment from the recovery journey")
                                            .font(.caption)
                                            .foregroundStyle(Color.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                }
                                .padding(14)
                                .background(Color.gray.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Privacy note
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.caption)
                            .foregroundStyle(Color.blue)
                        Text("This update is shared only with the donor and is kept private. It helps them know their donation is making a difference.")
                            .font(.caption2)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.horizontal, 20)

                    // MARK: Submit
                    Button {
                        submit()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "paperplane.fill")
                            Text("Post update")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isValid ? Color.red : Color.gray.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: isValid ? Color.red.opacity(0.3) : .clear,
                            radius: 10, x: 0, y: 4
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isValid)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .navigationTitle("New update")
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
            .onChange(of: photoItem) {
                Task {
                    if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                    photoItem = nil
                }
            }
        }
    }

    func submit() {
        let newUpdate = RecoveryUpdate(
            status: selectedStatus,
            note: note,
            date: Date(),
            updaterName: updaterName,
            updaterRole: updaterRole,
            photoData: photoData
        )
        onSave(newUpdate)
        dismiss()
    }
}

// MARK: - Section label
struct SectionLabel: View {
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

#Preview {
    RecoveryUpdateView(
        donorName: "Sowad",
        donationDate: Date().addingTimeInterval(-86400 * 30),
        updates: [
            RecoveryUpdate(
                status: .critical,
                note: "Patient rushed to ICU. Surgery starting soon.",
                date: Date().addingTimeInterval(-86400 * 30),
                updaterName: "Ayesha Khan",
                updaterRole: .familyMember,
                photoData: nil
            ),
            RecoveryUpdate(
                status: .recovering,
                note: "Surgery went well. Patient is stable now.",
                date: Date().addingTimeInterval(-86400 * 25),
                updaterName: "Dr. Rahman",
                updaterRole: .doctor,
                photoData: nil
            ),
            RecoveryUpdate(
                status: .fullRecovery,
                note: "I'm back home! Thank you so much for your donation, it truly saved my life. I will be forever grateful.",
                date: Date().addingTimeInterval(-86400 * 7),
                updaterName: "Karim Rahman",
                updaterRole: .recipient,
                photoData: nil
            ),
        ]
    )
}
