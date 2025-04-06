import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

// Custom colors for consistent theming
struct AppColors {
    static let primaryGold = Color(hex: "D4AF37")
    static let darkGold = Color(hex: "B8860B")
    static let backgroundBlack = Color(hex: "0A0A0A")
    static let surfaceBlack = Color(hex: "121212")
    static let textGray = Color(hex: "9A9A9A")
}

// Hex color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct LoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.backgroundBlack, AppColors.surfaceBlack]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {
                    Spacer()

                    // App Logo/Title Area
                    VStack(spacing: 8) {
                        Text("EDUCE")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(AppColors.primaryGold)
                        
                        Text("AI")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textGray)
                            .tracking(8)
                    }
                    .padding(.bottom, 40)

                    // Input Fields Group
                    VStack(spacing: 16) {
                        // Email Field
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(AppColors.primaryGold)
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textContentType(.emailAddress)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(AppColors.surfaceBlack)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)

                        // Password Field
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppColors.primaryGold)
                            SecureField("Password", text: $password)
                                .textContentType(.password)
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

                    // Login Button
                    Button(action: handleLogin) {
                        Text("LOGIN")
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
                    .padding(.top, 16)

                    // Google Sign-In Button
                    Button(action: handleGoogleSignIn) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(AppColors.primaryGold)
                            Text("Sign in with Google")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.surfaceBlack)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)

                    // Registration Link
                    NavigationLink(destination: RegistrationScreen()) {
                        Text("Don't have an account? ")
                            .foregroundColor(AppColors.textGray) +
                        Text("Register")
                            .foregroundColor(AppColors.primaryGold)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 16)

                    Spacer()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), 
                      message: Text(alertMessage), 
                      dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                DashboardScreen()
            }
            .navigationBarHidden(true)
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
                    isLoggedIn = true
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
                    isLoggedIn = true
                }
            }
        }
    }

    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        }
    }
}

#Preview {
    LoginScreen()
}
