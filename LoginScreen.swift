import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false // State for login navigation

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // App Title
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Text("Log in to continue")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                // Email Field
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 40)

                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 40)

                // Login Button
                Button(action: handleLogin) {
                    Text("Log In")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)

                // Google Sign-In Button
                Button(action: handleGoogleSignIn) {
                    HStack {
                        Image(systemName: "globe") // Placeholder Google icon
                        Text("Sign in with Google")
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                }
                .padding(.top, 10)

                // Navigation to Registration Screen
                NavigationLink(destination: RegistrationScreen()) {
                    Text("Don't have an account? Register")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)

                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                DashboardScreen() // Navigate to Dashboard when isLoggedIn is true
            }
            .navigationBarTitle("Login", displayMode: .inline)
        }
        .onAppear {
            checkIfUserIsLoggedIn()
        }
    }

    private func handleLogin() {
        if email.isEmpty || password.isEmpty {
            alertMessage = "Please fill in all fields."
            showAlert = true
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    alertMessage = "Login failed. Check your credentials and try again. Error Code: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    isLoggedIn = true // Navigate to Dashboard
                }
            }
        }
    }

    private func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                alertMessage = "Google sign-in failed: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let user = signInResult?.user, let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    alertMessage = "Google login failed: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    isLoggedIn = true // Navigate to Dashboard
                }
            }
        }
    }

    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser != nil {
            isLoggedIn = true // If user is already logged in, go to Dashboard
        }
    }
}

#Preview {
    LoginScreen()
}
