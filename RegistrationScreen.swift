import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct RegistrationScreen: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var address: String = ""
    @State private var parish: String = ""
    @State private var phoneNumber: String = ""
    @State private var showSuccess = false // State for showing success message
    @State private var showAlert = false // State for error messages
    @State private var alertMessage = ""
    
    let parishes = [
        "Kingston", "St. Andrew", "St. Catherine", "Clarendon", "Manchester",
        "St. Elizabeth", "Westmoreland", "Hanover", "St. James", "Trelawny",
        "St. Ann", "St. Mary", "Portland", "St. Thomas"
    ]
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Logo/Title Area
                        VStack(spacing: 8) {
                            Text("POTHOLE")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(AppColors.primaryGold)
                            
                            Text("REPORTER")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textGray)
                                .tracking(8)
                        }
                        .padding(.vertical, 20)
                        
                        // Form Title
                        Text("CREATE ACCOUNT")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textGray)
                            .tracking(4)
                            .padding(.bottom, 12)
                        
                        // Input Fields
                        customField(icon: "person.fill", placeholder: "Full Name", text: $name)
                        customField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                        customField(icon: "phone.fill", placeholder: "Phone Number", text: $phoneNumber, keyboardType: .phonePad)
                        customField(icon: "house.fill", placeholder: "Address", text: $address)
                        
                        // Parish Dropdown
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Parish")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textGray)
                                .padding(.leading, 4)
                            
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(AppColors.primaryGold)
                                
                                Picker("Select Parish", selection: $parish) {
                                    Text("Select Parish").tag("")
                                    ForEach(parishes, id: \.self) { parish in
                                        Text(parish).tag(parish)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .foregroundColor(parish.isEmpty ? AppColors.textGray.opacity(0.5) : .white)
                            }
                            .padding()
                            .background(AppColors.surfaceBlack)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        
                        // Password Fields
                        customSecureField(icon: "lock.fill", placeholder: "Password", text: $password)
                        customSecureField(icon: "lock.shield.fill", placeholder: "Confirm Password", text: $confirmPassword)
                        
                        // Register Button
                        Button(action: handleRegistration) {
                            Text("REGISTER")
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
                        .padding(.top, 8)
                        
                        // Login Link
                        NavigationLink(destination: LoginScreen()) {
                            Text("Already have an account? ")
                                .foregroundColor(AppColors.textGray) +
                            Text("Log in")
                                .foregroundColor(AppColors.primaryGold)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .overlay(
                    Group {
                        if showSuccess {
                            VStack {
                                Text("Registration successful! Please return to Login Page to log in.")
                                    .foregroundColor(.black)
                                    .font(.headline)
                                    .padding()
                                    .background(AppColors.primaryGold)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                                    .transition(.opacity)
                            }
                            .padding(.top, 50)
                        }
                    }
                )
                .animation(.easeInOut, value: showSuccess)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
    
    private func customField(icon: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryGold)
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
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
    
    private func customSecureField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryGold)
            SecureField(placeholder, text: text)
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
    
    private func handleRegistration() {
        // Input Validation
        if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || address.isEmpty || parish.isEmpty || phoneNumber.isEmpty {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }
        
        if password != confirmPassword {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        // Display on-success message
        showSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            showSuccess = false // Hide the message after 2 seconds
        }
        
        // Proceed with Firebase Registration
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "Registration failed: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let user = result?.user else { return }
            
            // Save additional user details to Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "name": name,
                "email": email,
                "address": address,
                "parish": parish,
                "phoneNumber": phoneNumber
            ]) { error in
                if let error = error {
                    alertMessage = "Failed to save user details: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    RegistrationScreen()
}
