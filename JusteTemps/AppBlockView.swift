import SwiftUI

struct AppBlockView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingAddApp = false
    @State private var newAppName = ""
    @State private var newAppBundleId = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Applications suivies")) {
                    ForEach(screenTimeManager.apps) { app in
                        AppRow(app: app)
                            .environmentObject(screenTimeManager)
                    }
                    .onDelete(perform: deleteApps)
                }
                
                Section(header: Text("Actions")) {
                    Button(action: {
                        showingAddApp = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Ajouter une application")
                        }
                    }
                    
                    Button(action: {
                        screenTimeManager.openScreenTimeSettings()
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Configurer Screen Time")
                        }
                    }
                }
                
                Section(header: Text("Information")) {
                    Text("Pour bloquer réellement des applications, vous devez utiliser les paramètres Screen Time d'iOS. Cette application vous aide à suivre et gérer votre utilisation.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Applications")
            .sheet(isPresented: $showingAddApp) {
                AddAppView()
                    .environmentObject(screenTimeManager)
            }
        }
    }
    
    func deleteApps(at offsets: IndexSet) {
        for index in offsets {
            screenTimeManager.removeApp(screenTimeManager.apps[index])
        }
    }
}

struct AppRow: View {
    let app: AppInfo
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingLimitPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icône de l'application (simulée)
                Circle()
                    .fill(app.isBlocked ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
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
                set: { _ in screenTimeManager.toggleAppBlock(app) }
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
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingLimitPicker) {
            AppLimitPickerView(app: app)
                .environmentObject(screenTimeManager)
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

