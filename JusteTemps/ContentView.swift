import SwiftUI

struct ContentView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var selectedTab = 0
    
    init() {
        // Personnaliser l'apparence de la barre d'onglets avec un style moderne et élégant
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Fond avec dégradé bleu-violet vibrant et sombre pour un rendu premium
        appearance.backgroundColor = UIColor(red: 0.35, green: 0.15, blue: 0.85, alpha: 0.98)
        
        // Effet de flou premium pour un rendu élégant
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        appearance.backgroundEffect = blurEffect
        
        // Couleur des icônes non sélectionnées (blanc avec transparence modérée)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.55)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.55),
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ]
        
        // Couleur des icônes sélectionnées (blanc pur avec effet de brillance)
        let selectedColor = UIColor.white
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.white.withAlphaComponent(0.3)
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .shadow: shadow
        ]
        
        // Ombre prononcée en haut pour créer de la profondeur
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.25)
        appearance.shadowImage = UIImage()
        
        // Appliquer l'apparence
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Style de la barre avec bordure brillante
        UITabBar.appearance().clipsToBounds = false
        UITabBar.appearance().isTranslucent = true
        
        // Ajouter une bordure brillante en haut pour un effet premium
        UITabBar.appearance().layer.borderWidth = 0.5
        UITabBar.appearance().layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScreenTimeView()
                .tabItem {
                    Image(systemName: "clock.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Temps d'écran")
                }
                .tag(0)
            
            AppBlockView()
                .tabItem {
                    Image(systemName: "app.badge.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Applications")
                }
                .tag(1)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text("Statistiques")
                }
                .tag(2)
        }
        .accentColor(.white)
    }
}

#Preview {
    ContentView()
        .environmentObject(ScreenTimeManager())
}

