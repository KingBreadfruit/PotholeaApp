import SwiftUI

struct ContentView: View {
    var body: some View {
        WelcomeScreen()
            .edgesIgnoringSafeArea(.all) // Fullscreen camera
    }
}

#Preview {
    ContentView()
}
