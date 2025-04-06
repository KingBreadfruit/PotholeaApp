import SwiftUI
import AVKit

struct WelcomeScreen: View {
    @State private var animateText = false
    @State private var showNextScreen = false
    @State private var showLogo = true

    var body: some View {
        ZStack {
            if showLogo {
                LogoIntroView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                            withAnimation {
                                showLogo = false
                            }
                        }
                    }
            } else {
                ZStack {
                    // Gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.backgroundBlack, AppColors.surfaceBlack]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 40) {
                        // App Title/Logo
                        VStack(spacing: 12) {
                            Text("POTHOLE")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(AppColors.primaryGold)
                                .scaleEffect(animateText ? 1 : 0.95)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateText)
                            
                            Text("REPORTER")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textGray)
                                .tracking(8)
                                .opacity(0.8)
                                .padding(.top, -10)
                            
                            Text("Track and report potholes in your area")
                                .font(.headline)
                                .foregroundColor(AppColors.textGray)
                                .padding(.top, 8)
                        }
                        .padding(.top, 60)
                        
                        // Map Visualization
                        ZStack {
                            Circle()
                                .fill(AppColors.surfaceBlack)
                                .frame(width: 300, height: 300)
                                .overlay(
                                    Circle()
                                        .stroke(AppColors.darkGold.opacity(0.2), lineWidth: 2)
                                )
                                .shadow(color: AppColors.primaryGold.opacity(0.1), radius: 20, x: 0, y: 10)
                            
                            Image("custom_map_with_pins") // Replace with your custom map image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 275, height: 275)
                                .opacity(0.9)
                                .colorMultiply(Color(white: 0.9, opacity: 0.9)) // Slightly desaturate to match theme
                        }
                        
                        // Features Section
                        VStack(spacing: 14) {
                            featureRow(icon: "mappin.and.ellipse", text: "Report potholes with pinpoint accuracy")
                            featureRow(icon: "chart.bar.fill", text: "Track repair status in real-time")
                            featureRow(icon: "bell.fill", text: "Get notified when repairs are complete")
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer()
                        
                        // Get Started Button
                        Button(action: {
                            showNextScreen = true
                        }) {
                            Text("GET STARTED")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
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
                        .padding(.horizontal, 40)
                        .padding(.bottom, 50)
                    }
                }
                .onAppear {
                    animateText = true
                }
                .fullScreenCover(isPresented: $showNextScreen) {
                    LoginScreen()
                }
            }
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(AppColors.primaryGold)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(16)
        .background(AppColors.surfaceBlack)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct LogoIntroView: View {
    @State private var showPoweredBy = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            // Black background for splash screen
            Color.black.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo with animation
                VStack(spacing: 12) {
                    Image("company_logo") // Replace with actual logo asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .colorMultiply(AppColors.primaryGold) // Tint logo gold
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                    
                    if showPoweredBy {
                        Text("POWERED BY")
                            .font(.system(size: 12, weight: .medium))
                            .tracking(4)
                            .foregroundColor(AppColors.textGray)
                            .transition(.opacity)
                            .padding(.top, 20)
                        
                        Text("EDUCE 876")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.primaryGold)
                            .transition(.opacity)
                    }
                }
                .onAppear {
                    // Animate logo appearing
                    withAnimation(Animation.easeOut(duration: 1.5)) {
                        logoScale = 1.0
                        logoOpacity = 1.0
                    }
                    
                    // Show "Powered by" text with delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(Animation.easeInOut(duration: 1)) {
                            showPoweredBy = true
                        }
                    }
                    
                    // Start fading out with delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation(Animation.easeInOut(duration: 1.5)) {
                            logoOpacity = 0
                            showPoweredBy = false
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    WelcomeScreen()
}
