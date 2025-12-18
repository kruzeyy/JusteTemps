import SwiftUI

struct ContentView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ScreenTimeView()
                .tabItem {
                    Label("Temps d'écran", systemImage: "clock")
                }
                .tag(0)
            
            AppBlockView()
                .tabItem {
                    Label("Applications", systemImage: "app.badge")
                }
                .tag(1)
            
            StatisticsView()
                .tabItem {
                    Label("Statistiques", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScreenTimeManager())
}

