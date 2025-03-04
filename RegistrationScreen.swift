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
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Title
                    Text("Create Your Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    
                    // MARK: - Input Fields
                    inputField("Full Name", text: $name)
                    inputField("Email", text: $email, keyboardType: .emailAddress)
                    inputField("Phone Number", text: $phoneNumber, keyboardType: .phonePad)
                    inputField("Address", text: $address)
                    
                    // MARK: - Parish Dropdown
                    VStack(alignment: .leading) {
                        Text("Select Parish")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Select Parish", selection: $parish) {
                            ForEach(parishes, id: \.self) { parish in
                                Text(parish).tag(parish)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // MARK: - Password Fields
                    secureField("Password", text: $password)
                    secureField("Confirm Password", text: $confirmPassword)
                    
                    // MARK: - Register Button
                    Button(action: handleRegistration) {
                        Text("Register")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Login Button
                    NavigationLink(destination: LoginScreen()) {
                        Text("Already have an account? Log in")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 40)
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
                                    .foregroundColor(.green)
                                    .font(.headline)
                                    .padding()
                                    .background(Color.white)
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
            .navigationBarTitle("Register", displayMode: .inline)
            .navigationBarBackButtonHidden(true) // Hide the back button
        }
    }
    
    private func inputField(_ placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
    }
    
    private func secureField(_ placeholder: String, text: Binding<String>) -> some View {
        SecureField(placeholder, text: text)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
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
