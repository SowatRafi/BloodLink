//
//  ProfileView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 20/4/26.
//

import SwiftUI
import PhotosUI
import Combine
#if os(iOS)
import AVFoundation
#endif

// MARK: - Message type
enum MessageType {
    case text
    case image(Data)
    case pdf
    case call(duration: String, missed: Bool)
}

// MARK: - Message model
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let type: MessageType
    let isSender: Bool
    let timestamp: Date
}

// MARK: - Audio route
enum AudioRoute: String, CaseIterable {
    case speaker    = "Speaker"
    case earpiece   = "Phone"
    case headphones = "Headphones"

    var icon: String {
        switch self {
        case .speaker:    return "speaker.wave.3.fill"
        case .earpiece:   return "phone.fill"
        case .headphones: return "headphones"
        }
    }
}

// MARK: - Full screen call view
struct CallScreenView: View {
    let otherName: String
    let otherBloodType: String
    let callDuration: Int
    let onEnd: () -> Void

    @State private var isMuted = false
    @State private var audioRoute: AudioRoute = .earpiece
    @State private var pulse = false

    var formattedTime: String {
        let m = callDuration / 60
        let s = callDuration % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [Color(red: 0.08, green: 0.08, blue: 0.12),
                         Color(red: 0.15, green: 0.05, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                VStack(spacing: 16) {

                    ZStack {
                        Circle()
                            .stroke(Color.red.opacity(0.15), lineWidth: 20)
                            .frame(width: pulse ? 160 : 130, height: pulse ? 160 : 130)
                            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)

                        Circle()
                            .stroke(Color.red.opacity(0.08), lineWidth: 30)
                            .frame(width: pulse ? 200 : 160, height: pulse ? 200 : 160)
                            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.2), value: pulse)

                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Text(String(otherName.prefix(1)))
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    .onAppear { pulse = true }

                    VStack(spacing: 6) {
                        Text(otherName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.white)

                        Text(otherBloodType + " Donor")
                            .font(.subheadline)
                            .foregroundStyle(Color.red.opacity(0.8))

                        Text(formattedTime)
                            .font(.system(size: 20, weight: .light, design: .monospaced))
                            .foregroundStyle(Color.white.opacity(0.7))
                            .padding(.top, 4)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.caption)
                        Text("Anonymous call · number hidden")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.white.opacity(0.4))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
                }

                Spacer()

                VStack(spacing: 12) {
                    Text("Audio output")
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.4))

                    HStack(spacing: 20) {
                        ForEach(AudioRoute.allCases, id: \.self) { route in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    audioRoute = route
                                    applyAudioRoute(route)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(audioRoute == route
                                                  ? Color.white
                                                  : Color.white.opacity(0.12))
                                            .frame(width: 56, height: 56)
                                        Image(systemName: route.icon)
                                            .font(.title3)
                                            .foregroundStyle(audioRoute == route
                                                             ? Color.black
                                                             : Color.white)
                                    }
                                    Text(route.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(audioRoute == route
                                                         ? Color.white
                                                         : Color.white.opacity(0.5))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 40)

                HStack(spacing: 40) {

                    Button {
                        withAnimation { isMuted.toggle() }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(isMuted
                                          ? Color.white
                                          : Color.white.opacity(0.12))
                                    .frame(width: 64, height: 64)
                                Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                    .font(.title2)
                                    .foregroundStyle(isMuted ? Color.black : Color.white)
                            }
                            Text(isMuted ? "Unmute" : "Mute")
                                .font(.caption2)
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        onEnd()
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 72, height: 72)
                                    .shadow(color: Color.red.opacity(0.5), radius: 12)
                                Image(systemName: "phone.down.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.white)
                            }
                            Text("End")
                                .font(.caption2)
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 64, height: 64)
                                Image(systemName: "circle.grid.3x3.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.white)
                            }
                            Text("Keypad")
                                .font(.caption2)
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 60)
            }
        }
    }

    func applyAudioRoute(_ route: AudioRoute) {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(true)
        switch route {
        case .speaker:
            try? session.overrideOutputAudioPort(.speaker)
        case .earpiece:
            try? session.overrideOutputAudioPort(.none)
        case .headphones:
            try? session.overrideOutputAudioPort(.none)
        }
        #endif
    }
}

// MARK: - Chat view
struct ChatView: View {

    let otherName: String
    let otherBloodType: String

    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            content: "Hi, I saw your blood request. I am available.",
            type: .text,
            isSender: false,
            timestamp: Date().addingTimeInterval(-600)
        ),
        ChatMessage(
            content: "Thank you so much! Can you come to City Hospital?",
            type: .text,
            isSender: true,
            timestamp: Date().addingTimeInterval(-540)
        ),
        ChatMessage(
            content: "",
            type: .call(duration: "2m 14s", missed: false),
            isSender: false,
            timestamp: Date().addingTimeInterval(-480)
        ),
        ChatMessage(
            content: "Yes I can be there in 30 minutes.",
            type: .text,
            isSender: false,
            timestamp: Date().addingTimeInterval(-300)
        ),
    ]

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showAttachMenu = false
    @State private var showCallConfirm = false
    @State private var showCallScreen = false
    @State private var showReportUpload = false
    @State private var showRecoveryUpdate = false
    @State private var callTimer = 0
    @State private var callTimerActive = false

    @Namespace private var bottomID
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var formattedCallTime: String {
        let m = callTimer / 60
        let s = callTimer % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 2)
                            }
                            Color.clear.frame(height: 1).id(bottomID)
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    }
                    .onChange(of: messages.count) {
                        withAnimation { proxy.scrollTo(bottomID, anchor: .bottom) }
                    }
                }

                Divider()

                // MARK: Input bar
                HStack(alignment: .bottom, spacing: 10) {
                    Button {
                        showAttachMenu = true
                    } label: {
                        Image(systemName: "paperclip")
                            .font(.title3)
                            .foregroundStyle(Color.gray)
                            .padding(10)
                    }
                    .buttonStyle(.plain)

                    ZStack(alignment: .leading) {
                        if messageText.isEmpty {
                            Text("Message")
                                .foregroundStyle(Color.gray.opacity(0.6))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        TextEditor(text: $messageText)
                            .frame(minHeight: 38, maxHeight: 120)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .scrollContentBackground(.hidden)
                    }
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Button {
                        sendTextMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                messageText.isEmpty
                                ? Color.gray.opacity(0.3)
                                : Color.red
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(uiColor: .systemBackground))
            }
            .navigationTitle(otherName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text(otherName).font(.headline)
                        Text(otherBloodType).font(.caption2).foregroundStyle(Color.red)
                    }
                }
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCallConfirm = true
                    } label: {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(Color.green)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Label("Anonymous", systemImage: "lock.shield.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.blue)
                        .labelStyle(.titleAndIcon)
                }
                #elseif os(macOS)
                ToolbarItem(placement: .automatic) {
                    Button {
                        showCallConfirm = true
                    } label: {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(Color.green)
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Label("Anonymous", systemImage: "lock.shield.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.blue)
                        .labelStyle(.titleAndIcon)
                }
                #endif
            }

            // Attach menu
            .confirmationDialog("Share", isPresented: $showAttachMenu, titleVisibility: .visible) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Photo", systemImage: "photo")
                }
                Button {
                    showReportUpload = true
                } label: {
                    Label("Blood report", systemImage: "doc.text.viewfinder")
                }
                Button {
                    showRecoveryUpdate = true
                } label: {
                    Label("Recovery update", systemImage: "heart.text.square.fill")
                }
                Button("Cancel", role: .cancel) {}
            }

            // Blood report upload
            .sheet(isPresented: $showReportUpload) {
                BloodReportUploadView(
                    donorName: otherName,
                    donorBloodType: otherBloodType,
                    onComplete: { uploadType in
                        switch uploadType {
                        case .pdf(_, let name):
                            withAnimation {
                                messages.append(ChatMessage(
                                    content: name,
                                    type: .pdf,
                                    isSender: true,
                                    timestamp: Date()
                                ))
                            }
                        case .image(let data):
                            withAnimation {
                                messages.append(ChatMessage(
                                    content: "Blood report",
                                    type: .image(data),
                                    isSender: true,
                                    timestamp: Date()
                                ))
                            }
                        case .none:
                            break
                        }
                    }
                )
            }

            // Recovery update
            .sheet(isPresented: $showRecoveryUpdate) {
                RecoveryUpdateView(
                    donorName: otherName,
                    donationDate: Date().addingTimeInterval(-86400 * 7),
                    updates: []
                )
            }

            // Call confirm
            .confirmationDialog(
                "Start anonymous call?",
                isPresented: $showCallConfirm,
                titleVisibility: .visible
            ) {
                Button("Call \(otherName)") { startCall() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your phone number will not be shared. The call is routed anonymously.")
            }

            .fullScreenCover(isPresented: $showCallScreen) {
                CallScreenView(
                    otherName: otherName,
                    otherBloodType: otherBloodType,
                    callDuration: callTimer,
                    onEnd: { endCall() }
                )
            }

            .onChange(of: selectedPhoto) {
                Task {
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        sendImageMessage(data)
                    }
                }
            }

            .onReceive(timer) { _ in
                if callTimerActive { callTimer += 1 }
            }
        }
    }

    // MARK: - Actions

    func sendTextMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation {
            messages.append(ChatMessage(content: messageText, type: .text, isSender: true, timestamp: Date()))
        }
        messageText = ""
    }

    func sendImageMessage(_ data: Data) {
        withAnimation {
            messages.append(ChatMessage(content: "Photo", type: .image(data), isSender: true, timestamp: Date()))
        }
        selectedPhoto = nil
    }

    func startCall() {
        callTimer = 0
        callTimerActive = true
        showCallScreen = true
        withAnimation {
            messages.append(ChatMessage(content: "", type: .call(duration: "", missed: false), isSender: true, timestamp: Date()))
        }
    }

    func endCall() {
        callTimerActive = false
        showCallScreen = false
        withAnimation {
            messages.append(ChatMessage(content: "", type: .call(duration: formattedCallTime, missed: false), isSender: true, timestamp: Date()))
        }
        callTimer = 0
    }
}

// MARK: - Message bubble
struct MessageBubble: View {
    let message: ChatMessage

    var timeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: message.timestamp)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if message.isSender { Spacer(minLength: 60) }

            VStack(alignment: message.isSender ? .trailing : .leading, spacing: 3) {
                switch message.type {

                case .text:
                    Text(message.content)
                        .font(.body)
                        .foregroundStyle(message.isSender ? Color.white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(message.isSender ? Color.red : Color.gray.opacity(0.15))
                        .clipShape(BubbleShape(isSender: message.isSender))

                case .image(let data):
                    #if os(iOS)
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 160)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: data) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 160)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    #endif

                case .pdf:
                    HStack(spacing: 10) {
                        Image(systemName: "doc.fill")
                            .font(.title2)
                            .foregroundStyle(message.isSender ? Color.white : Color.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(message.content)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(message.isSender ? Color.white : Color.primary)
                            Text("Blood report · PDF")
                                .font(.caption)
                                .foregroundStyle(message.isSender ? Color.white.opacity(0.7) : Color.gray)
                        }
                        Spacer()
                        Image(systemName: "arrow.down.circle")
                            .foregroundStyle(message.isSender ? Color.white.opacity(0.8) : Color.blue)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(width: 240)
                    .background(message.isSender ? Color.red : Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                case .call(let duration, let missed):
                    HStack(spacing: 10) {
                        Image(systemName: missed ? "phone.down.fill" : "phone.fill")
                            .foregroundStyle(missed ? Color.red : Color.green)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(missed ? "Missed call" : (duration.isEmpty ? "Calling…" : "Call ended"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(message.isSender ? Color.white : Color.primary)
                            if !duration.isEmpty {
                                Text("Duration · \(duration)")
                                    .font(.caption)
                                    .foregroundStyle(message.isSender ? Color.white.opacity(0.7) : Color.gray)
                            }
                        }
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(message.isSender ? Color.white.opacity(0.5) : Color.gray.opacity(0.5))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(width: 220)
                    .background(message.isSender ? Color.red : Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Text(timeString)
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
            }

            if !message.isSender { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Bubble shape
struct BubbleShape: Shape {
    let isSender: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18
        let tail: CGFloat = 6
        var path = Path()

        if isSender {
            path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r), control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r - tail))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - tail, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - r), control: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
            path.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        } else {
            path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r), control: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - r, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + tail, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - tail), control: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
            path.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Conversation list
struct ConversationListView: View {

    let conversations: [(name: String, bloodType: String, lastMessage: String, time: String, unread: Int)] = [
        ("Hasan",  "A+",  "Yes I can be there in 30 minutes.", "2m ago",    0),
        ("Farida", "A+",  "Blood_Report.pdf",                  "1h ago",    2),
        ("Tariq",  "B+",  "Is the hospital nearby?",           "3h ago",    1),
        ("Nadia",  "AB+", "Thank you so much!",                "Yesterday", 0),
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(conversations, id: \.name) { convo in
                    NavigationLink(destination: ChatView(
                        otherName: convo.name,
                        otherBloodType: convo.bloodType
                    )) {
                        ConversationRow(
                            name: convo.name,
                            bloodType: convo.bloodType,
                            lastMessage: convo.lastMessage,
                            time: convo.time,
                            unread: convo.unread
                        )
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Messages")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Label("End-to-end encrypted", systemImage: "lock.shield.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.blue)
                        .labelStyle(.titleAndIcon)
                }
                #elseif os(macOS)
                ToolbarItem(placement: .automatic) {
                    Label("End-to-end encrypted", systemImage: "lock.shield.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.blue)
                        .labelStyle(.titleAndIcon)
                }
                #endif
            }
        }
    }
}

// MARK: - Conversation row
struct ConversationRow: View {
    let name: String
    let bloodType: String
    let lastMessage: String
    let time: String
    let unread: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.12))
                    .frame(width: 50, height: 50)
                VStack(spacing: 0) {
                    Text(String(name.prefix(1)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.red)
                    Text(bloodType)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.red.opacity(0.7))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(name).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(time).font(.caption2).foregroundStyle(Color.gray)
                }
                HStack {
                    if lastMessage.hasSuffix(".pdf") {
                        Label(lastMessage, systemImage: "doc.fill")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .lineLimit(1)
                    } else {
                        Text(lastMessage)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .lineLimit(1)
                    }
                    Spacer()
                    if unread > 0 {
                        Text("\(unread)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ConversationListView()
}
