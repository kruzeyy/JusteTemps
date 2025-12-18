import SwiftUI

struct ScreenTimeView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showingLimitSettings = false
    @State private var showingProfile = false
    
    var progress: Double {
        guard screenTimeManager.dailyLimit > 0 else { return 0 }
        return min(screenTimeManager.totalScreenTime / screenTimeManager.dailyLimit, 1.0)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // En-tête
                    VStack(spacing: 10) {
                        Text("JusteTemps")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Gérez votre temps d'écran")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Carte principale du temps d'écran
                    VStack(spacing: 20) {
                        // Temps d'écran total
                        VStack(spacing: 8) {
                            Text("Temps d'écran aujourd'hui")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(screenTimeManager.formatTime(screenTimeManager.totalScreenTime))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        // Barre de progression
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Limite quotidienne")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(screenTimeManager.formatTime(screenTimeManager.dailyLimit))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 20)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(progressColor)
                                        .frame(width: geometry.size.width * progress, height: 20)
                                        .animation(.spring(), value: progress)
                                }
                            }
                            .frame(height: 20)
                            
                            if progress >= 1.0 {
                                Text("⚠️ Limite dépassée")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            } else if progress >= 0.8 {
                                Text("⚠️ Presque à la limite")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Statistiques des applications
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Applications les plus utilisées")
                                .font(.headline)
                            
                            Spacer()
                        }
                        
                        ForEach(Array(screenTimeManager.apps.prefix(5))) { app in
                            AppUsageRow(app: app)
                                .environmentObject(screenTimeManager)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
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
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // Informations
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💡 Astuce")
                            .font(.headline)
                        
                        Text("Pour bloquer réellement des applications, utilisez les paramètres Screen Time d'iOS. Cette application vous aide à suivre et gérer votre utilisation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
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
                                        .foregroundColor(.blue)
                                }
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingLimitSettings = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
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
    
    var progressColor: Color {
        if progress >= 1.0 {
            return .red
        } else if progress >= 0.8 {
            return .orange
        } else {
            return .blue
        }
    }
}

struct AppUsageRow: View {
    let app: AppInfo
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        HStack {
            // Icône de l'application (simulée)
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(app.name.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(screenTimeManager.formatTime(screenTimeManager.getAppTimeToday(app)))
                    .font(.caption)
                    .foregroundColor(.secondary)
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

#Preview {
    ScreenTimeView()
        .environmentObject(ScreenTimeManager())
}

