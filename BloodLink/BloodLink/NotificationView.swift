//
//  NotificationView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 19/4/26.
//

import SwiftUI

// MARK: - Notification type
enum BloodLinkNotificationType {
    case bloodRequest
    case chat
    case donationReminder
    case eligibilityUpdate
    case idVerification
    case system

    var icon: String {
        switch self {
        case .bloodRequest:      return "drop.fill"
        case .chat:              return "message.fill"
        case .donationReminder:  return "calendar.badge.clock"
        case .eligibilityUpdate: return "checkmark.circle.fill"
        case .idVerification:    return "creditcard.fill"
        case .system:            return "bell.fill"
        }
    }

    var color: Color {
        switch self {
        case .bloodRequest:      return .red
        case .chat:              return .blue
        case .donationReminder:  return .purple
        case .eligibilityUpdate: return .green
        case .idVerification:    return .orange
        case .system:            return .gray
        }
    }

    var label: String {
        switch self {
        case .bloodRequest:      return "Blood request"
        case .chat:              return "Message"
        case .donationReminder:  return "Reminder"
        case .eligibilityUpdate: return "Eligibility"
        case .idVerification:    return "Verification"
        case .system:            return "System"
        }
    }
}

// MARK: - Notification model
struct BloodLinkNotification: Identifiable {
    let id = UUID()
    let type: BloodLinkNotificationType
    let title: String
    let body: String
    let date: Date
    var isRead: Bool = false
    var actionLabel: String? = nil
}

// MARK: - Date group
enum NotificationDateGroup: String {
    case today     = "Today"
    case yesterday = "Yesterday"
    case earlier   = "Earlier"
}

// MARK: - Notification view
struct NotificationView: View {

    @State private var notifications: [BloodLinkNotification] = [

        BloodLinkNotification(
            type: .bloodRequest,
            title: "Urgent: A+ blood needed",
            body: "Rahim is looking for an A+ donor within 2 km of your location.",
            date: Date().addingTimeInterval(-600),
            isRead: false,
            actionLabel: "View request"
        ),
        BloodLinkNotification(
            type: .chat,
            title: "New message from Farida",
            body: "Can you come to Square Hospital today?",
            date: Date().addingTimeInterval(-1800),
            isRead: false,
            actionLabel: "Reply"
        ),
        BloodLinkNotification(
            type: .eligibilityUpdate,
            title: "You are eligible to donate!",
            body: "90 days have passed since your last donation. You can donate again now.",
            date: Date().addingTimeInterval(-3600),
            isRead: false,
            actionLabel: "Go online"
        ),
        BloodLinkNotification(
            type: .bloodRequest,
            title: "B+ blood needed nearby",
            body: "Salma needs B+ blood at City Hospital, 1.4 km away.",
            date: Date().addingTimeInterval(-86400),
            isRead: true,
            actionLabel: "View request"
        ),
        BloodLinkNotification(
            type: .idVerification,
            title: "ID verification approved",
            body: "Your identity documents have been reviewed and approved. Your donor badge is now active.",
            date: Date().addingTimeInterval(-90000),
            isRead: true
        ),
        BloodLinkNotification(
            type: .chat,
            title: "New message from Tariq",
            body: "Thank you so much for your help yesterday!",
            date: Date().addingTimeInterval(-100000),
            isRead: true,
            actionLabel: "Reply"
        ),
        BloodLinkNotification(
            type: .donationReminder,
            title: "Donation reminder",
            body: "You'll be eligible to donate again in 14 days. Keep an eye out for requests!",
            date: Date().addingTimeInterval(-172800),
            isRead: true
        ),
        BloodLinkNotification(
            type: .system,
            title: "Welcome to BloodLink",
            body: "Your account is set up and ready. Go online to start helping donors near you.",
            date: Date().addingTimeInterval(-259200),
            isRead: true
        ),
        BloodLinkNotification(
            type: .idVerification,
            title: "ID under review",
            body: "Your identity documents have been submitted and are being reviewed. This usually takes up to 24 hours.",
            date: Date().addingTimeInterval(-270000),
            isRead: true
        ),
        BloodLinkNotification(
            type: .eligibilityUpdate,
            title: "Donation cooldown started",
            body: "Thank you for your donation! You'll be eligible to donate again in 90 days.",
            date: Date().addingTimeInterval(-345600),
            isRead: true
        ),
    ]

    @State private var showClearConfirm = false

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var todayNotifications: [BloodLinkNotification] {
        notifications.filter { Calendar.current.isDateInToday($0.date) }
    }

    var yesterdayNotifications: [BloodLinkNotification] {
        notifications.filter { Calendar.current.isDateInYesterday($0.date) }
    }

    var earlierNotifications: [BloodLinkNotification] {
        notifications.filter {
            !Calendar.current.isDateInToday($0.date) &&
            !Calendar.current.isDateInYesterday($0.date)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .navigationTitle("Notifications")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    if unreadCount > 0 {
                        Button("Mark all read") {
                            withAnimation {
                                for i in notifications.indices {
                                    notifications[i].isRead = true
                                }
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(Color.blue)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    if !notifications.isEmpty {
                        Button {
                            showClearConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.red)
                        }
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    if unreadCount > 0 {
                        Button("Mark all read") {
                            withAnimation {
                                for i in notifications.indices {
                                    notifications[i].isRead = true
                                }
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(Color.blue)
                    }
                }
                ToolbarItem(placement: .automatic) {
                    if !notifications.isEmpty {
                        Button {
                            showClearConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.red)
                        }
                    }
                }
                #endif
            }
            .confirmationDialog(
                "Clear all notifications?",
                isPresented: $showClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Clear all", role: .destructive) {
                    withAnimation { notifications.removeAll() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove all notifications.")
            }
        }
    }

    // MARK: - List
    var notificationList: some View {
        List {
            if !todayNotifications.isEmpty {
                NotificationSection(
                    group: .today,
                    notifications: todayNotifications,
                    onTap: markAsRead,
                    onDelete: delete
                )
            }

            if !yesterdayNotifications.isEmpty {
                NotificationSection(
                    group: .yesterday,
                    notifications: yesterdayNotifications,
                    onTap: markAsRead,
                    onDelete: delete
                )
            }

            if !earlierNotifications.isEmpty {
                NotificationSection(
                    group: .earlier,
                    notifications: earlierNotifications,
                    onTap: markAsRead,
                    onDelete: delete
                )
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty state
    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.gray.opacity(0.3))
            Text("No notifications")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.gray)
            Text("You're all caught up! Blood request alerts, messages, and updates will appear here.")
                .font(.subheadline)
                .foregroundStyle(Color.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Actions
    func markAsRead(_ notification: BloodLinkNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            withAnimation { notifications[index].isRead = true }
        }
    }

    func delete(_ notification: BloodLinkNotification) {
        withAnimation {
            notifications.removeAll { $0.id == notification.id }
        }
    }
}

// MARK: - Notification section
struct NotificationSection: View {
    let group: NotificationDateGroup
    let notifications: [BloodLinkNotification]
    let onTap: (BloodLinkNotification) -> Void
    let onDelete: (BloodLinkNotification) -> Void

    var body: some View {
        Section {
            ForEach(notifications) { notification in
                NotificationRow(notification: notification)
                    .onTapGesture { onTap(notification) }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDelete(notification)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            onTap(notification)
                        } label: {
                            Label("Read", systemImage: "envelope.open")
                        }
                        .tint(.blue)
                    }
            }
        } header: {
            HStack {
                Text(group.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
                let unread = notifications.filter { !$0.isRead }.count
                if unread > 0 {
                    Text("\(unread) new")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Notification row
struct NotificationRow: View {
    let notification: BloodLinkNotification

    var timeString: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f.localizedString(for: notification.date, relativeTo: Date())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: notification.type.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(notification.type.color)

                if !notification.isRead {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 16, y: -16)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(notification.title)
                        .font(.subheadline.weight(notification.isRead ? .regular : .semibold))
                        .foregroundStyle(notification.isRead ? Color.gray : Color.primary)
                        .lineLimit(2)
                    Spacer()
                    Text(timeString)
                        .font(.caption2)
                        .foregroundStyle(Color.gray)
                        .fixedSize()
                }

                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(notification.type.label)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(notification.type.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(notification.type.color.opacity(0.1))
                        .clipShape(Capsule())

                    if let action = notification.actionLabel {
                        Text(action)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .background(
            notification.isRead
            ? Color.clear
            : Color.red.opacity(0.02)
        )
    }
}

#Preview {
    NotificationView()
}
