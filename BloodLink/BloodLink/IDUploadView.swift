//
//  IDUploadView.swift
//  BloodLink
//
//  Created by Sowad Hossain Rafi on 19/4/26.
//

import SwiftUI
import PhotosUI

// MARK: - ID upload step
enum IDUploadStep: Int, CaseIterable {
    case front  = 0
    case back   = 1
    case selfie = 2

    var title: String {
        switch self {
        case .front:  return "Front of ID"
        case .back:   return "Back of ID"
        case .selfie: return "Selfie with ID"
        }
    }

    var subtitle: String {
        switch self {
        case .front:  return "Place the front of your passport or national ID card in the frame."
        case .back:   return "Flip your ID and capture the back side clearly."
        case .selfie: return "Hold your ID next to your face and take a selfie."
        }
    }

    var icon: String {
        switch self {
        case .front:  return "creditcard.fill"
        case .back:   return "creditcard"
        case .selfie: return "person.crop.square.fill"
        }
    }

    var tip: String {
        switch self {
        case .front:  return "Make sure your name and photo are clearly visible."
        case .back:   return "Ensure the barcode or MRZ strip is in focus."
        case .selfie: return "Hold the ID beside your face — both must be visible."
        }
    }
}

// MARK: - Image display helper (platform safe)
struct IDImageView: View {
    let data: Data
    let height: CGFloat

    var body: some View {
        #if canImport(UIKit)
        if let img = UIImage(data: data) {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .clipped()
        }
        #elseif canImport(AppKit)
        if let img = NSImage(data: data) {
            Image(nsImage: img)
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .clipped()
        }
        #endif
    }
}

// MARK: - Progress step indicator
struct IDProgressStep: View {
    let step: IDUploadStep
    let isCurrent: Bool
    let isDone: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isDone
                          ? Color.green
                          : (isCurrent ? Color.red : Color.gray.opacity(0.2)))
                    .frame(width: 36, height: 36)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.white)
                } else {
                    Image(systemName: step.icon)
                        .font(.caption)
                        .foregroundStyle(isCurrent ? Color.white : Color.gray)
                }
            }
            Text(step.title)
                .font(.caption2)
                .foregroundStyle(isCurrent ? Color.primary : Color.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Image preview card
struct IDPreviewCard: View {
    let imageData: Data?
    let step: IDUploadStep
    let onTap: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.06))
                .frame(height: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            imageData != nil
                            ? Color.green.opacity(0.4)
                            : Color.gray.opacity(0.2),
                            style: StrokeStyle(
                                lineWidth: 1.5,
                                dash: imageData != nil ? [] : [6]
                            )
                        )
                )

            if let data = imageData {
                IDImageView(data: data, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Retake badge
                VStack {
                    HStack {
                        Spacer()
                        Label("Tap to retake", systemImage: "arrow.counterclockwise")
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
            } else {
                VStack(spacing: 12) {
                    Image(systemName: step.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(Color.gray.opacity(0.4))
                    Text("No image uploaded yet")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                }
            }
        }
        .onTapGesture {
            if imageData != nil { onTap() }
        }
    }
}

// MARK: - Step info block
struct IDStepInfo: View {
    let step: IDUploadStep

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(step.title)
                .font(.title3.weight(.bold))
            Text(step.subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.gray)
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(Color.orange)
                Text(step.tip)
                    .font(.caption)
                    .foregroundStyle(Color.orange)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

// MARK: - Upload buttons
struct IDUploadButtons: View {
    let step: IDUploadStep
    @Binding var selectedPhoto: PhotosPickerItem?
    let onCamera: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button {
                onCamera()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                        .font(.body.weight(.semibold))
                    Text("Take photo")
                        .font(.body.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.body.weight(.semibold))
                    Text("Choose from library")
                        .font(.body.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                }
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

// MARK: - Step navigation buttons
struct IDStepNavigation: View {
    let currentStep: IDUploadStep
    let allUploaded: Bool
    let isUploading: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if currentStep != .front {
                Button {
                    onPrevious()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }

            Button {
                onNext()
            } label: {
                HStack(spacing: 6) {
                    if isUploading {
                        ProgressView().tint(.white)
                    } else {
                        Text(currentStep == .selfie
                             ? (allUploaded ? "Submit for verification" : "Upload selfie first")
                             : "Next")
                        if currentStep != .selfie {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    currentStep == .selfie && !allUploaded
                    ? Color.gray
                    : Color.red
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(currentStep == .selfie && !allUploaded)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Success card
struct IDSuccessCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.green)
            Text("ID submitted for verification")
                .font(.headline)
            Text("Our team will review your documents within 24 hours. You'll be notified once approved.")
                .font(.caption)
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color.green.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }
}

// MARK: - Privacy note
struct IDPrivacyNote: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.caption)
                .foregroundStyle(Color.blue)
            Text("Your ID is encrypted and stored securely. It is never shared publicly and is only used for donor verification.")
                .font(.caption2)
                .foregroundStyle(Color.gray)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Main ID upload view
struct IDUploadView: View {

    var onComplete: (() -> Void)? = nil
    var isEditMode: Bool = false

    @State private var currentStep: IDUploadStep = .front
    @State private var frontImageData: Data? = nil
    @State private var backImageData: Data? = nil
    @State private var selfieImageData: Data? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showCamera = false
    @State private var isUploading = false
    @State private var uploadComplete = false

    var currentImageData: Data? {
        switch currentStep {
        case .front:  return frontImageData
        case .back:   return backImageData
        case .selfie: return selfieImageData
        }
    }

    var allUploaded: Bool {
        frontImageData != nil && backImageData != nil && selfieImageData != nil
    }

    var completedCount: Int {
        [frontImageData, backImageData, selfieImageData].compactMap { $0 }.count
    }

    func imageData(for step: IDUploadStep) -> Data? {
        switch step {
        case .front:  return frontImageData
        case .back:   return backImageData
        case .selfie: return selfieImageData
        }
    }

    func setImageData(_ data: Data) {
        withAnimation {
            switch currentStep {
            case .front:  frontImageData  = data
            case .back:   backImageData   = data
            case .selfie: selfieImageData = data
            }
        }
    }

    func goNext() {
        if currentStep == .selfie {
            if allUploaded { submitVerification() }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentStep = IDUploadStep(rawValue: currentStep.rawValue + 1) ?? .selfie
            }
        }
    }

    func goPrevious() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = IDUploadStep(rawValue: currentStep.rawValue - 1) ?? .front
        }
    }

    func submitVerification() {
        isUploading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            isUploading = false
            withAnimation { uploadComplete = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete?()
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Progress indicator
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            ForEach(IDUploadStep.allCases, id: \.self) { step in
                                IDProgressStep(
                                    step: step,
                                    isCurrent: currentStep == step,
                                    isDone: imageData(for: step) != nil
                                )
                                if step != .selfie {
                                    Rectangle()
                                        .fill(imageData(for: step) != nil
                                              ? Color.green
                                              : Color.gray.opacity(0.2))
                                        .frame(height: 2)
                                        .padding(.bottom, 20)
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        Text("\(completedCount) of 3 completed")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.top, 8)

                    // MARK: Current step card
                    VStack(spacing: 20) {
                        IDPreviewCard(
                            imageData: currentImageData,
                            step: currentStep,
                            onTap: { showCamera = true }
                        )

                        IDStepInfo(step: currentStep)

                        IDUploadButtons(
                            step: currentStep,
                            selectedPhoto: $selectedPhoto,
                            onCamera: { showCamera = true }
                        )
                    }
                    .padding(.horizontal, 16)

                    // MARK: Navigation
                    IDStepNavigation(
                        currentStep: currentStep,
                        allUploaded: allUploaded,
                        isUploading: isUploading,
                        onPrevious: goPrevious,
                        onNext: goNext
                    )

                    // MARK: Success
                    if uploadComplete {
                        IDSuccessCard()
                    }

                    // MARK: Privacy
                    IDPrivacyNote()
                }
            }
            .navigationTitle(isEditMode ? "Update ID documents" : "Verify your identity")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(iOS)
            .sheet(isPresented: $showCamera) {
                CameraPickerView { data in
                    setImageData(data)
                }
            }
            #endif
            .onChange(of: selectedPhoto) {
                Task {
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        setImageData(data)
                    }
                    selectedPhoto = nil
                }
            }
        }
    }
}

// MARK: - Camera picker (iOS only)
#if os(iOS)
struct CameraPickerView: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (Data) -> Void

        init(onCapture: @escaping (Data) -> Void) {
            self.onCapture = onCapture
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            picker.dismiss(animated: true)
            if let img = info[.originalImage] as? UIImage,
               let data = img.jpegData(compressionQuality: 0.8) {
                onCapture(data)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
#endif

// MARK: - Thumbnail helper
struct IDThumbnail: View {
    let data: Data?
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.08))
                    .frame(height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                data != nil
                                ? Color.green.opacity(0.4)
                                : Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )

                if let data = data {
                    IDImageView(data: data, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(Color.gray.opacity(0.4))
                }

                if data != nil {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.green)
                                .padding(4)
                        }
                        Spacer()
                    }
                }
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.gray)
        }
    }
}

#Preview {
    IDUploadView()
}
