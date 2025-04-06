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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.backgroundBlack, AppColors.surfaceBlack]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header with app title
                    VStack(spacing: 0) {
                        Text("POTHOLE")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(AppColors.primaryGold)
                        
                        Text("REPORTER")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textGray)
                            .tracking(5)
                    }
                    .padding(.top, 20)
                    
                    // User Info Card
                    VStack(spacing: 16) {
                        Text("Welcome, \(userName)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.primaryGold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(AppColors.primaryGold)
                                Text(userEmail)
                                    .foregroundColor(AppColors.textGray)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(AppColors.primaryGold)
                                Text("Parish: \(userParish)")
                                    .foregroundColor(AppColors.textGray)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(20)
                    .background(AppColors.surfaceBlack)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    
                    // Report Pothole Button - NEW ADDITION
                    NavigationLink(destination: ReportScreen()) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                                .foregroundColor(.black)
                            Text("REPORT POTHOLE")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
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
                    .padding(.top, 12)
                    
                    // Features Section
                    Text("DASHBOARD")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textGray)
                        .tracking(4)
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                    
                    // Settings Button
                    NavigationLink(destination: SettingsScreen()) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundColor(AppColors.primaryGold)
                            Text("Settings")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.primaryGold.opacity(0.7))
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
                    
                    // Statistics Button
                    NavigationLink(destination: StatisticsScreen()) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title3)
                                .foregroundColor(AppColors.primaryGold)
                            Text("Statistics")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.primaryGold.opacity(0.7))
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
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Text("LOG OUT")
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
                    .padding(.bottom, 30)
                }
            }
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
            .navigationBarHidden(true)
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
