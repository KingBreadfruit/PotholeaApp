import SwiftUI
import AVFoundation
import Photos
import UIKit

struct ReportScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showCamera = false
    @State private var capturedImage: UIImage? = nil
    @State private var description: String = ""
    @State private var location: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [AppColors.backgroundBlack, AppColors.surfaceBlack]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("REPORT POTHOLE")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGold)
                        .tracking(2)
                        .padding(.top, 20)
                    
                    // Camera/Image Section
                    VStack(spacing: 16) {
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                                )
                            
                            // Retake button
                            Button(action: {
                                showCamera = true
                            }) {
                                Text("RETAKE PHOTO")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.primaryGold)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(AppColors.surfaceBlack)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.darkGold.opacity(0.5), lineWidth: 1)
                                    )
                                    .cornerRadius(8)
                            }
                        } else {
                            // Camera button
                            Button(action: {
                                checkCameraPermissions()
                            }) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.primaryGold)
                                        .padding(.bottom, 8)
                                    
                                    Text("TAP TO TAKE PHOTO")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textGray)
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.surfaceBlack)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Location Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textGray)
                            .padding(.leading, 4)
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(AppColors.primaryGold)
                            TextField("Enter location", text: $location)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(AppColors.surfaceBlack)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textGray)
                            .padding(.leading, 4)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.white)
                                .background(AppColors.surfaceBlack)
                                .frame(minHeight: 100)
                                .padding(4)
                            
                            if description.isEmpty {
                                Text("Describe the pothole and its severity")
                                    .foregroundColor(AppColors.textGray.opacity(0.5))
                                    .padding(.horizontal, 10)
                                    .padding(.top, 10)
                                    .allowsHitTesting(false)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    // Submit Button
                    Button(action: submitReport) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .padding(.trailing, 10)
                            }
                            
                            Text(isSubmitting ? "SUBMITTING..." : "SUBMIT REPORT")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.primaryGold, AppColors.darkGold]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: AppColors.primaryGold.opacity(0.3), radius: 10, x: 0, y: 5)
                        .opacity(capturedImage == nil ? 0.5 : 1.0)
                    }
                    .disabled(capturedImage == nil || isSubmitting)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.primaryGold)
                        Text("Back")
                            .foregroundColor(AppColors.primaryGold)
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $capturedImage, isShown: $showCamera)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert("Report Submitted", isPresented: $showSuccessAlert) {
            Button("OK") {
                // Reset form after submission
                capturedImage = nil
                description = ""
                location = ""
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your pothole report has been submitted successfully.")
        }
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.showCamera = true
                    }
                }
            }
        case .denied, .restricted:
            alertMessage = "Camera access is required to take photos. Please enable it in Settings."
            showAlert = true
        @unknown default:
            alertMessage = "Unknown error accessing camera."
            showAlert = true
        }
    }
    
    private func submitReport() {
        // Validate inputs
        if location.isEmpty {
            alertMessage = "Please enter a location."
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSubmitting = false
            showSuccessAlert = true
        }
        
        // In a real app, you would upload the image and data to Firebase here
    }
}

// Improved Camera View Implementation
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isShown = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShown = false
        }
    }
} 
