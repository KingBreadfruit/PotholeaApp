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
                VStack {
                    // Top Zone
                    VStack {
                        Text("Pothole Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .scaleEffect(animateText ? 1 : 0.8)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animateText)

                        Text("Report and track potholes in your area")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    .padding(.top, 40)

                    // Spacer to center the map
                    Spacer()

                    // Middle Zone
                    Image("custom_map_with_pins") // Replace with your custom map image name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 275, height: 275)
                        .scaleEffect(1.2)

                    // Spacer to push the button down
                    Spacer()

                    // Bottom Zone
                    VStack {
                        Button(action: {
                            showNextScreen = true
                        }) {
                            Text("Get Started")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal, 40)
                        }
                        .padding(.bottom, 50)
                    }
                }
                .background(Color.white.ignoresSafeArea())
                .onAppear {
                    animateText = true
                }
                .fullScreenCover(isPresented: $showNextScreen) {
                    LoginScreen() // Placeholder for the next screen
                }
            }
        }
    }
}

struct LogoIntroView: View {
    @State private var showPoweredBy = false

    var body: some View {
        VStack {
            Spacer()

            Image("company_logo") // Replace with actual logo asset name
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .opacity(1.0)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1).delay(1)) {
                        showPoweredBy = true
                    }
                }

            if showPoweredBy {
                Text("Powered by Educe876")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation(Animation.easeInOut(duration: 1)) {
                                showPoweredBy = false
                            }
                        }
                    }
            }

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    WelcomeScreen()
}
