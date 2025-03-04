import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct DashboardScreen: View {
    @State private var userName: String = "User"
    @State private var userEmail: String = ""
    @State private var userParish: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showLogoutConfirmation = false
    @Environment(\.presentationMode) var presentationMode // For navigating back to login

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer(minLength: 20)
                
                // User Info Section
                VStack(spacing: 10) {
                    Text("Welcome, \(userName)!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    
                    VStack(spacing: 10) {
                        Text(userEmail)
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        Text("Parish: \(userParish)")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Dashboard Features Section (Settings & Statistics Navigation)
                VStack(spacing: 20) {
                    NavigationLink(destination: SettingsScreen()) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: StatisticsScreen()) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("Statistics")
                        }
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    Text("Log Out")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 30)
                
                Spacer(minLength: 10)
            }
            .padding(.top, 50)
            .onAppear {
                fetchUserData()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    handleLogout()
                    presentationMode.wrappedValue.dismiss() // Navigate back to login screen
                }
                Button("Cancel", role: .cancel, action: {})
            }
        }
    }

    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }
        self.userEmail = user.email ?? "No Email"
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { document, error in
            if let error = error {
                alertMessage = "Failed to load user data: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["name"] as? String ?? "User"
                self.userParish = data?["parish"] as? String ?? "Not Provided"
            }
        }
    }
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss() // Navigate back to login screen
        } catch {
            alertMessage = "Failed to log out: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    DashboardScreen()
}
