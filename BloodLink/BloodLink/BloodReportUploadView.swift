//
//  BloodReportUploadView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 20/4/26.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Report upload type
enum ReportUploadType {
    case none
    case pdf(Data, String)
    case image(Data)
}

// MARK: - Blood report upload view
struct BloodReportUploadView: View {

    @Environment(\.dismiss) private var dismiss

    let donorName: String
    let donorBloodType: String
    var donationDate: Date = Date()
    var hospital: String = ""
    var onComplete: ((ReportUploadType) -> Void)? = nil

    @State private var uploadType: ReportUploadType = .none
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showPDFPicker = false
    @State private var isUploading = false
    @State private var uploadComplete = false

    var hasFile: Bool {
        if case .none = uploadType { return false }
        return true
    }

    var fileTypeLabel: String {
        switch uploadType {
        case .none: return ""
        case .pdf:  return "PDF"
        case .image: return "Image"
        }
    }

    var fileName: String {
        switch uploadType {
        case .none: return ""
        case .pdf(_, let name): return name
        case .image: return "blood_report.jpg"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Donor info banner
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
                            Text("Share report with")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                            Text(donorName)
                                .font(.headline)
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color.red)
                                Text("Thank you for donating")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.gray.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)

                    // MARK: Info note
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.blue)
                        Text("Sharing the blood report helps donors know their donation made a difference. This is optional but appreciated.")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(14)
                    .background(Color.blue.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 16)

                    // MARK: Preview area
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.06))
                            .frame(height: 260)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        hasFile ? Color.green.opacity(0.4) : Color.gray.opacity(0.2),
                                        style: StrokeStyle(
                                            lineWidth: 1.5,
                                            dash: hasFile ? [] : [6]
                                        )
                                    )
                            )

                        switch uploadType {
                        case .none:
                            VStack(spacing: 14) {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color.gray.opacity(0.4))
                                Text("No report uploaded yet")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.gray)
                                Text("Choose a PDF or photo below")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray.opacity(0.7))
                            }

                        case .pdf(_, let name):
                            VStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                        .frame(width: 100, height: 130)
                                    VStack(spacing: 4) {
                                        Image(systemName: "doc.fill")
                                            .font(.system(size: 44))
                                            .foregroundStyle(Color.red)
                                        Text("PDF")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Color.red)
                                    }
                                }
                                Text(name)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                    .padding(.horizontal, 20)
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                    Text("Ready to send")
                                        .font(.caption)
                                        .foregroundStyle(Color.green)
                                }
                            }

                        case .image(let data):
                            ReportImageView(data: data)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Retake badge
                        if hasFile {
                            VStack {
                                HStack {
                                    Spacer()
                                    Label("Change", systemImage: "arrow.counterclockwise")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Color.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.black.opacity(0.55))
                                        .clipShape(Capsule())
                                        .padding(10)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Upload options
                    VStack(spacing: 10) {

                        // Image picker
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "photo.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.blue)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Photo")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.primary)
                                    Text("Take or choose a photo of the report")
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
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // PDF picker
                        Button {
                            showPDFPicker = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.red.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "doc.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.red)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PDF document")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.primary)
                                    Text("Choose a PDF from Files or iCloud")
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
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)

                    // MARK: File details
                    if hasFile {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("File details")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.gray)
                                .textCase(.uppercase)

                            HStack {
                                Label("Type", systemImage: "doc.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                Spacer()
                                Text(fileTypeLabel)
                                    .font(.caption.weight(.semibold))
                            }

                            HStack {
                                Label("Name", systemImage: "textformat")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                Spacer()
                                Text(fileName)
                                    .font(.caption.weight(.semibold))
                                    .lineLimit(1)
                            }

                            HStack {
                                Label("Privacy", systemImage: "lock.shield.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                Spacer()
                                Text("End-to-end encrypted")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.green)
                            }
                        }
                        .padding(14)
                        .background(Color.gray.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                    }

                    // MARK: Privacy note
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.caption)
                            .foregroundStyle(Color.blue)
                        Text("Your report is sent only to this donor. It is encrypted and is never shared publicly.")
                            .font(.caption2)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.horizontal, 20)

                    // MARK: Send button
                    Button {
                        sendReport()
                    } label: {
                        HStack(spacing: 10) {
                            if isUploading {
                                ProgressView().tint(.white)
                            } else if uploadComplete {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Sent")
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Send to \(donorName)")
                            }
                        }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            hasFile
                            ? (uploadComplete ? Color.green : Color.red)
                            : Color.gray.opacity(0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: hasFile ? Color.red.opacity(0.3) : .clear,
                            radius: 10, x: 0, y: 4
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!hasFile || isUploading || uploadComplete)
                    .padding(.horizontal, 16)

                    // MARK: Success card
                    if uploadComplete {
                        VStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.green)
                            Text("Report sent successfully")
                                .font(.headline)
                            Text("\(donorName) has been notified and can view the report in their chat with you.")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .background(Color.green.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Share blood report")
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
            // Photo handler
            .onChange(of: selectedPhoto) {
                Task {
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        withAnimation { uploadType = .image(data) }
                    }
                    selectedPhoto = nil
                }
            }
            // PDF picker sheet
            #if os(iOS)
            .sheet(isPresented: $showPDFPicker) {
                PDFDocumentPicker { data, name in
                    withAnimation { uploadType = .pdf(data, name) }
                }
            }
            #endif
        }
    }

    // MARK: - Send action
    func sendReport() {
        isUploading = true
        // Simulate upload delay — replace with Firebase upload later
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isUploading = false
            withAnimation { uploadComplete = true }
            onComplete?(uploadType)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                dismiss()
            }
        }
    }
}

// MARK: - Report image view (platform safe)
struct ReportImageView: View {
    let data: Data

    var body: some View {
        #if canImport(UIKit)
        if let img = UIImage(data: data) {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()
        }
        #elseif canImport(AppKit)
        if let img = NSImage(data: data) {
            Image(nsImage: img)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()
        }
        #endif
    }
}

// MARK: - PDF document picker (iOS only)
#if os(iOS)
struct PDFDocumentPicker: UIViewControllerRepresentable {
    let onPick: (Data, String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [UTType.pdf]
        )
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (Data, String) -> Void

        init(onPick: @escaping (Data, String) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(
            _ controller: UIDocumentPickerViewController,
            didPickDocumentsAt urls: [URL]
        ) {
            guard let url = urls.first else { return }
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess { url.stopAccessingSecurityScopedResource() }
            }
            if let data = try? Data(contentsOf: url) {
                onPick(data, url.lastPathComponent)
            }
        }
    }
}
#endif

#Preview {
    BloodReportUploadView(
        donorName: "Hasan",
        donorBloodType: "A+"
    )
}
