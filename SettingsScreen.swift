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
        NavigationView {
            VStack(spacing: 20) {
                Spacer(minLength: 20)
                
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    
                VStack(spacing: 10) {
                    TextField("Full Name", text: $name)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)

                    TextField("Email", text: $email)
                        .disabled(true) // Email should not be editable
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(8)

                    Picker("Select Parish", selection: $parish) {
                        ForEach(parishes, id: \ .self) { parish in
                            Text(parish).tag(parish)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 30)
                
                // Save Changes Button
                Button(action: updateUserProfile) {
                    Text("Save Changes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                // Change Password Button
                Button(action: resetPassword) {
                    Text("Change Password")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                // Delete Account Button
                Button(action: { showDeleteConfirmation = true }) {
                    Text("Delete Account")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.top, 20)
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
            .navigationBarBackButtonHidden(false) // Show back button
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
