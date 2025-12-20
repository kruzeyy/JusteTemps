import SwiftUI
import FamilyControls
import DeviceActivity

struct ScreenTimeView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showingLimitSettings = false
    @State private var showingProfile = false
    
    var progress: Double {
        guard screenTimeManager.dailyLimit > 0 else { return 0 }
        return min(screenTimeManager.totalScreenTime / screenTimeManager.dailyLimit, 1.0)
    }
    
    // Applications triées par temps d'utilisation (ordre décroissant)
    var topAppsByUsage: [AppInfo] {
        screenTimeManager.apps.sorted { app1, app2 in
            let time1 = screenTimeManager.getAppTimeToday(app1)
            let time2 = screenTimeManager.getAppTimeToday(app2)
            return time1 > time2
        }.prefix(5).map { $0 }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fond dégradé (même style que LoginView)
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    // Afficher la vue d'autorisation si l'autorisation n'est pas accordée
                    if screenTimeManager.screenTimeAuthorizationStatus != .approved {
                    ScreenTimeAuthorizationView()
                        .environmentObject(screenTimeManager)
                        .padding(.top, 50.0)
                } else {
                    VStack(spacing: 30) {
                        // En-tête avec logo (même style que LoginView)
                        VStack(spacing: 10) {
                            // Logo personnalisé
                            if UIImage(named: "AppLogo") != nil {
                                Image("AppLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(16)
                                    .padding(.bottom, 5)
                            }
                            
                            Text("JusteTemps")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Gérez votre temps d'écran")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    
                    // Carte principale du temps d'écran avec gradient vibrant
                    VStack(spacing: 20) {
                        // Temps d'écran total
                        VStack(spacing: 8) {
                            Text("Temps d'écran aujourd'hui")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            // Afficher les vraies données si l'autorisation est accordée
                            if screenTimeManager.screenTimeAuthorizationStatus == .approved {
                                RealScreenTimeText(screenTimeManager: screenTimeManager)
                                    .foregroundColor(.white)
                                    .onAppear {
                                        // Forcer le rechargement des données quand la vue apparaît
                                        screenTimeManager.loadRealScreenTimeData()
                                    }
                            } else {
                                Text(screenTimeManager.formatTime(screenTimeManager.totalScreenTime))
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            // Indicateur si les données sont réelles
                            if screenTimeManager.screenTimeAuthorizationStatus == .approved {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                    Text("Données réelles Screen Time")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.3))
                                )
                                .padding(.top, 4)
                            }
                        }
                        
                        // Barre de progression
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Limite quotidienne")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                Text(screenTimeManager.formatTime(screenTimeManager.dailyLimit))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.3))
                                        .frame(height: 20)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: progress >= 1.0 
                                                    ? [Color.red.opacity(0.9), Color.red.opacity(0.7)]
                                                    : progress >= 0.8 
                                                        ? [Color.orange.opacity(0.9), Color.orange.opacity(0.7)]
                                                        : [Color.white.opacity(0.9), Color.white.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: min(geometry.size.width * progress, geometry.size.width), height: 20)
                                        .animation(.spring(), value: progress)
                                }
                            }
                            .frame(height: 20)
                            
                            if progress >= 1.0 {
                                Text("⚠️ Limite dépassée")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                            } else if progress >= 0.8 {
                                Text("⚠️ Presque à la limite")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.4, blue: 0.9),   // Violet clair
                                Color(red: 0.4, green: 0.5, blue: 1.0),   // Bleu-violet
                                Color(red: 0.6, green: 0.45, blue: 0.95)  // Violet moyen
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: Color.purple.opacity(0.5), radius: 15, x: 0, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    
                    // Statistiques des applications
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Applications les plus utilisées")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        ForEach(Array(topAppsByUsage.enumerated()), id: \.element.id) { index, app in
                            AppUsageRow(app: app, colorIndex: index)
                                .environmentObject(screenTimeManager)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.8),   // Violet-rose
                                Color(red: 0.7, green: 0.5, blue: 0.85).opacity(0.8)  // Rose-violet clair
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Bouton pour ouvrir les paramètres Screen Time
                    Button(action: {
                        screenTimeManager.openScreenTimeSettings()
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Ouvrir les paramètres Screen Time")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.9),  // Bleu-violet
                                    Color(red: 0.5, green: 0.4, blue: 0.95).opacity(0.9) // Violet-bleu
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Informations
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 Astuce")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Pour bloquer réellement des applications, utilisez les paramètres Screen Time d'iOS. Cette application vous aide à suivre et gérer votre utilisation.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.55, blue: 0.95).opacity(0.8),  // Bleu moyen
                                Color(red: 0.5, green: 0.45, blue: 0.9).opacity(0.8)    // Violet-bleu
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        if let user = authManager.currentUser {
                            if let imageURL = user.profileImageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.white)
                                }
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .background(
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 36, height: 36)
                                    )
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingLimitSettings = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingLimitSettings) {
                LimitSettingsView()
                    .environmentObject(screenTimeManager)
            }
        }
    }
    
}

struct AppUsageRow: View {
    let app: AppInfo
    let colorIndex: Int
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        HStack(spacing: 14) {
            // Icône de l'application avec gradient coloré
            ZStack {
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 40)
                
                Text(String(app.name.prefix(1)))
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(screenTimeManager.formatTime(screenTimeManager.getAppTimeToday(app)))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            if app.isBlocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

struct LimitSettingsView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.dismiss) var dismiss
    @State private var hours: Int = 1
    @State private var minutes: Int = 0
    @State private var notificationsEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Limite quotidienne")) {
                    HStack {
                        Picker("Heures", selection: $hours) {
                            ForEach(0..<25) { hour in
                                Text("\(hour) h").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        
                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Activer les notifications", isOn: $notificationsEnabled)
                }
                
                Section(footer: Text("Vous recevrez une notification lorsque vous atteindrez votre limite quotidienne.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        let totalSeconds = TimeInterval(hours * 3600 + minutes * 60)
                        screenTimeManager.setDailyLimit(totalSeconds)
                        screenTimeManager.notificationsEnabled = notificationsEnabled
                        screenTimeManager.saveData()
                        dismiss()
                    }
                }
            }
            .onAppear {
                let total = Int(screenTimeManager.dailyLimit)
                hours = total / 3600
                minutes = (total % 3600) / 60
                notificationsEnabled = screenTimeManager.notificationsEnabled
            }
        }
    }
}

struct ScreenTimeAuthorizationView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Autorisation Screen Time requise")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Pour afficher vos vraies données de temps d'écran, JusteTemps a besoin de votre autorisation pour accéder aux données Screen Time de votre iPhone.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Afficher l'erreur si elle existe (par exemple compte gratuit)
            if let error = screenTimeManager.screenTimeError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 12) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Statistiques précises")
                            .font(.headline)
                        Text("Affichez vos vraies données d'utilisation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Respect de la vie privée")
                            .font(.headline)
                        Text("Vos données restent sur votre appareil")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notifications personnalisées")
                            .font(.headline)
                        Text("Soyez alerté lorsque vous atteignez vos limites")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            Button(action: {
                Task {
                    isRequesting = true
                    await screenTimeManager.requestScreenTimeAuthorization()
                    isRequesting = false
                }
            }) {
                HStack {
                    if isRequesting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.shield.fill")
                        Text("Autoriser l'accès")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .disabled(isRequesting)
            .padding(.horizontal)
            
            Button(action: {
                screenTimeManager.openScreenTimeSettings()
            }) {
                Text("Ouvrir les paramètres")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

// Vue simplifiée pour afficher les vraies données de Screen Time
// Lit directement depuis UserDefaults partagé (sauvegardé par l'extension DeviceActivityReport)
struct RealScreenTimeText: View {
    @ObservedObject var screenTimeManager: ScreenTimeManager
    @State private var realTotalTime: TimeInterval = 0
    @State private var refreshTimer: Timer?
    
    // UserDefaults partagé pour lire les données de l'extension
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.justetemps.app")
    }
    
    var body: some View {
        Text(screenTimeManager.formatTime(realTotalTime > 0 ? realTotalTime : screenTimeManager.totalScreenTime))
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(.white)
            .onAppear {
                setupDataRefresh()
            }
            .onDisappear {
                refreshTimer?.invalidate()
            }
            // Ne pas utiliser UserDefaults.didChangeNotification avec App Groups
            // car cela peut causer des warnings système. On utilise plutôt un Timer.
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScreenTimeDataUpdated"))) { notification in
                // Mettre à jour quand une notification est reçue avec les nouvelles données
                if let totalTime = notification.userInfo?["totalTime"] as? TimeInterval {
                    realTotalTime = totalTime
                } else {
                    loadRealData()
                }
            }
    }
    
    private func setupDataRefresh() {
        // Charger immédiatement
        loadRealData()
        
        // Rafraîchir toutes les 30 secondes pour avoir les données à jour
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            loadRealData()
        }
    }
    
    private func loadRealData() {
        guard let sharedDefaults = sharedDefaults else {
            // Si l'App Group n'est pas disponible, ne rien faire (éviter les warnings)
            return
        }
        
        // Essayer d'abord les vraies données depuis l'extension DeviceActivityReport
        if let totalTime = sharedDefaults.object(forKey: "realScreenTimeToday") as? TimeInterval, totalTime > 0 {
            DispatchQueue.main.async {
                self.realTotalTime = totalTime
                // Mettre à jour aussi le ScreenTimeManager pour la synchronisation
                self.screenTimeManager.updateRealScreenTime(totalTime: totalTime)
            }
        } else if let totalTime = sharedDefaults.object(forKey: "totalScreenTimeToday") as? TimeInterval, totalTime > 0 {
            // Fallback : données collectées par le monitor DeviceActivityMonitor
            DispatchQueue.main.async {
                self.realTotalTime = totalTime
                self.screenTimeManager.updateRealScreenTime(totalTime: totalTime)
            }
        }
        // Si aucune donnée n'est disponible, garder la valeur par défaut (0)
    }
}

#Preview {
    ScreenTimeView()
        .environmentObject(ScreenTimeManager())
}



