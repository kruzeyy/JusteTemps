import SwiftUI

@main
struct JusteTempsApp: App {
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var authManager = AuthManager()
    
    init() {
        // Personnaliser l'apparence de la barre de navigation avec un style moderne
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Fond avec effet de flou et couleur semi-transparente
        appearance.backgroundColor = UIColor.clear
        
        // Effet de flou
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        appearance.backgroundEffect = blurEffect
        
        // Style du titre
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        // Style des boutons de la barre
        appearance.buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        // Ombre subtile
        appearance.shadowColor = UIColor.clear
        
        // Appliquer l'apparence
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Personnaliser les boutons de la barre (toolbar items)
        UIBarButtonItem.appearance().tintColor = UIColor.white
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(screenTimeManager)
                    .environmentObject(authManager)
                    .onOpenURL { url in
                        // Gérer le callback OAuth (Google)
                        Task {
                            await authManager.handleOAuthCallback(url: url)
                        }
                    }
            } else {
                LoginView()
                    .environmentObject(authManager)
                    .onOpenURL { url in
                        // Gérer le callback OAuth (Google)
                        Task {
                            await authManager.handleOAuthCallback(url: url)
                        }
                    }
            }
        }
    }
}

