import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct SettingsScreen: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var parish: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation = false
    @Environment(\.presentationMode) var presentationMode // For navigating back

    let parishes = [
        "Kingston", "St. Andrew", "St. Catherine", "Clarendon", "Manchester",
        "St. Elizabeth", "Westmoreland", "Hanover", "St. James", "Trelawny",
        "St. Ann", "St. Mary", "Portland", "St. Thomas"
    ]
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [AppColors.backgroundBlack, AppColors.surfaceBlack]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("SETTINGS")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGold)
                        .tracking(2)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Settings Fields
                VStack(spacing: 18) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textGray)
                            .padding(.leading, 4)
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(AppColors.primaryGold)
                            TextField("Full Name", text: $name)
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
                    
                    // Email Field (Disabled)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textGray)
                            .padding(.leading, 4)
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(AppColors.primaryGold.opacity(0.6))
                            TextField("Email", text: $email)
                                .disabled(true)
                                .foregroundColor(AppColors.textGray)
                        }
                        .padding()
                        .background(AppColors.surfaceBlack.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.darkGold.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    
                    // Parish Dropdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Parish")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textGray)
                            .padding(.leading, 4)
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(AppColors.primaryGold)
                            
                            Picker("Select Parish", selection: $parish) {
                                ForEach(parishes, id: \.self) { parish in
                                    Text(parish).tag(parish)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
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
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
                
                // Save Changes Button
                Button(action: updateUserProfile) {
                    Text("SAVE CHANGES")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
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
                }
                .padding(.horizontal, 24)
                
                // Change Password Button
                Button(action: resetPassword) {
                    Text("CHANGE PASSWORD")
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryGold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.surfaceBlack)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.darkGold.opacity(0.5), lineWidth: 1.5)
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Delete Account Button
                Button(action: { showDeleteConfirmation = true }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(Color(hex: "FF3B30").opacity(0.9))
                        Text("DELETE ACCOUNT")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(hex: "FF3B30").opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.surfaceBlack)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "FF3B30").opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                Spacer()
            }
            .padding(.top, 32)
            .onAppear {
                loadUserProfile()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .confirmationDialog("Are you sure you want to delete your account? This action cannot be undone.", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive, action: deleteUserAccount)
                Button("Cancel", role: .cancel, action: {})
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
    }
    
    private func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        self.email = user.email ?? ""
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { document, error in
            if let error = error {
                alertMessage = "Failed to load user data: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.name = data?["name"] as? String ?? ""
                self.parish = data?["parish"] as? String ?? ""
            }
        }
    }
    
    private func updateUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).updateData([
            "name": name,
            "parish": parish
        ]) { error in
            if let error = error {
                alertMessage = "Failed to update profile: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Profile updated successfully!"
                showAlert = true
            }
        }
    }
    
    private func resetPassword() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        Auth.auth().sendPasswordReset(withEmail: userEmail) { error in
            if let error = error {
                alertMessage = "Error sending reset email: \(error.localizedDescription)"
            } else {
                alertMessage = "Password reset email sent!"
            }
            showAlert = true
        }
    }
    
    private func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete { error in
            if let error = error {
                alertMessage = "Failed to delete account: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Account deleted successfully!"
                showAlert = true
                presentationMode.wrappedValue.dismiss() // Navigate back
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
