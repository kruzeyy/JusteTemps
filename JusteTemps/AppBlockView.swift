import SwiftUI
import FamilyControls

struct AppBlockView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingAppPicker = false
    @State private var selectedActivity: FamilyActivitySelection = FamilyActivitySelection()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Icône et description
                VStack(spacing: 15) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Bloquer des applications")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Sélectionnez les applications que vous souhaitez bloquer pour limiter votre temps d'écran")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Bouton principal pour bloquer des applications
                Button(action: {
                    showingAppPicker = true
                }) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                        Text("Bloquer des applications")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.red, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                
                // Bouton pour débloquer toutes les applications
                Button(action: {
                    screenTimeManager.unblockAllApps()
                }) {
                    HStack {
                        Image(systemName: "lock.open.fill")
                            .font(.title3)
                        Text("Débloquer toutes les applications")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                
                // Bouton pour configurer Screen Time
                Button(action: {
                    screenTimeManager.openScreenTimeSettings()
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Configurer Screen Time")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Applications")
            .familyActivityPicker(isPresented: $showingAppPicker, selection: $selectedActivity)
            .onChange(of: selectedActivity) { oldValue, newValue in
                // Quand l'utilisateur sélectionne des applications
                if !newValue.applicationTokens.isEmpty {
                    // Appliquer le blocage directement avec la sélection
                    screenTimeManager.applyBlocking(selection: newValue)
                }
            }
        }
    }
}

struct AppRow: View {
    let app: AppInfo
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingLimitPicker = false
    @State private var showingAppPicker = false
    @State private var selectedActivity: FamilyActivitySelection = FamilyActivitySelection()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icône de l'application (simulée)
                Circle()
                    .fill(
                        app.isBlocked ? 
                        LinearGradient(colors: [Color.red.opacity(0.3), Color.orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(app.name.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(app.isBlocked ? .red : .blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.headline)
                    
                    Text("Temps aujourd'hui: \(screenTimeManager.formatTime(screenTimeManager.getAppTimeToday(app)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if app.dailyLimit > 0 {
                        Text("Limite: \(screenTimeManager.formatTime(app.dailyLimit))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Toggle de blocage
            Toggle(isOn: Binding(
                get: { app.isBlocked },
                set: { shouldBlock in
                    if shouldBlock {
                        // Si l'app n'a pas de token, ouvrir le sélecteur d'applications
                        if app.applicationTokenData == nil {
                            showingAppPicker = true
                        } else {
                            screenTimeManager.toggleAppBlock(app)
                        }
                    } else {
                        screenTimeManager.toggleAppBlock(app)
                    }
                }
            )) {
                Text(app.isBlocked ? "Bloquée" : "Non bloquée")
                    .font(.subheadline)
            }
            .tint(app.isBlocked ? .red : .blue)
            
            // Bouton pour définir une limite
            Button(action: {
                showingLimitPicker = true
            }) {
                HStack {
                    Image(systemName: "clock")
                    Text("Définir une limite quotidienne")
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingLimitPicker) {
            AppLimitPickerView(app: app)
                .environmentObject(screenTimeManager)
        }
        .familyActivityPicker(isPresented: $showingAppPicker, selection: $selectedActivity)
        .onChange(of: selectedActivity) { oldValue, newValue in
            // Quand l'utilisateur sélectionne des applications
            if !newValue.applicationTokens.isEmpty {
                screenTimeManager.setActivitySelection(newValue, for: app)
                // Activer le blocage après avoir défini la sélection
                screenTimeManager.toggleAppBlock(app)
            }
        }
    }
}

struct AddAppView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.dismiss) var dismiss
    @State private var appName = ""
    @State private var bundleId = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations de l'application")) {
                    TextField("Nom de l'application", text: $appName)
                    TextField("Bundle ID (optionnel)", text: $bundleId)
                        .autocapitalization(.none)
                }
                
                Section(footer: Text("Le Bundle ID est utilisé pour identifier l'application. Vous pouvez le trouver dans les paramètres de l'application ou le laisser vide.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Ajouter une application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        if !appName.isEmpty {
                            screenTimeManager.addApp(name: appName, bundleId: bundleId.isEmpty ? "com.unknown.\(appName.lowercased())" : bundleId)
                            dismiss()
                        }
                    }
                    .disabled(appName.isEmpty)
                }
            }
        }
    }
}

struct AppLimitPickerView: View {
    let app: AppInfo
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Environment(\.dismiss) var dismiss
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Limite quotidienne pour \(app.name)")) {
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
                
                Section(footer: Text("Vous recevrez une notification lorsque vous atteindrez cette limite pour cette application.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Limite d'application")
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
                        screenTimeManager.setAppLimit(app, limit: totalSeconds)
                        dismiss()
                    }
                }
            }
            .onAppear {
                let total = Int(app.dailyLimit)
                hours = total / 3600
                minutes = (total % 3600) / 60
            }
        }
    }
}

#Preview {
    AppBlockView()
        .environmentObject(ScreenTimeManager())
}

