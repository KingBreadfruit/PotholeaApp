import SwiftUI
import Firebase

@main
struct PotholeAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            WelcomeScreen()
        }
    }
}
