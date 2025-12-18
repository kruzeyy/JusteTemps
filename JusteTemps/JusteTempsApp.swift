import SwiftUI

@main
struct JusteTempsApp: App {
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(screenTimeManager)
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

