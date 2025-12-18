import Foundation
import SwiftUI
import UserNotifications

class ScreenTimeManager: ObservableObject {
    @Published var totalScreenTime: TimeInterval = 0 // en secondes
    @Published var dailyLimit: TimeInterval = 3600 // 1 heure par défaut
    @Published var apps: [AppInfo] = []
    @Published var dailyStats: [DailyStats] = []
    @Published var notificationsEnabled: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let appsKey = "blockedApps"
    private let statsKey = "dailyStats"
    private let limitKey = "dailyLimit"
    private let notificationsKey = "notificationsEnabled"
    
    init() {
        loadData()
        generateSampleDataIfNeeded()
        requestNotificationPermission()
        startTracking()
    }
    
    // Charger les données sauvegardées
    func loadData() {
        if let data = userDefaults.data(forKey: appsKey),
           let decoded = try? JSONDecoder().decode([AppInfo].self, from: data) {
            apps = decoded
        } else {
            // Applications par défaut
            apps = [
                AppInfo(name: "Instagram", bundleId: "com.burbn.instagram"),
                AppInfo(name: "TikTok", bundleId: "com.zhiliaoapp.musically"),
                AppInfo(name: "Facebook", bundleId: "com.facebook.Facebook"),
                AppInfo(name: "Twitter", bundleId: "com.atebits.Tweetie2"),
                AppInfo(name: "YouTube", bundleId: "com.google.ios.youtube"),
                AppInfo(name: "Snapchat", bundleId: "com.toyopagroup.picaboo"),
            ]
        }
        
        if let data = userDefaults.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode([DailyStats].self, from: data) {
            dailyStats = decoded
        }
        
        dailyLimit = userDefaults.double(forKey: limitKey)
        if dailyLimit == 0 {
            dailyLimit = 3600 // 1 heure par défaut
        }
        
        notificationsEnabled = userDefaults.bool(forKey: notificationsKey)
        if !userDefaults.bool(forKey: "hasSetNotifications") {
            notificationsEnabled = true
            userDefaults.set(true, forKey: "hasSetNotifications")
        }
        
        // Calculer le temps d'écran total d'aujourd'hui
        updateTodayScreenTime()
    }
    
    // Sauvegarder les données
    func saveData() {
        if let encoded = try? JSONEncoder().encode(apps) {
            userDefaults.set(encoded, forKey: appsKey)
        }
        if let encoded = try? JSONEncoder().encode(dailyStats) {
            userDefaults.set(encoded, forKey: statsKey)
        }
        userDefaults.set(dailyLimit, forKey: limitKey)
        userDefaults.set(notificationsEnabled, forKey: notificationsKey)
    }
    
    // Mettre à jour le temps d'écran d'aujourd'hui
    func updateTodayScreenTime() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayStats = dailyStats.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
        
        if let stats = todayStats {
            totalScreenTime = stats.totalScreenTime
        } else {
            totalScreenTime = 0
        }
    }
    
    // Ajouter du temps d'écran (simulation)
    func addScreenTime(_ time: TimeInterval, for appBundleId: String? = nil) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Trouver ou créer les stats d'aujourd'hui
        if let index = dailyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyStats[index].totalScreenTime += time
            if let bundleId = appBundleId {
                dailyStats[index].appUsage[bundleId, default: 0] += time
            }
        } else {
            var newStats = DailyStats(date: today)
            newStats.totalScreenTime = time
            if let bundleId = appBundleId {
                newStats.appUsage[bundleId] = time
            }
            dailyStats.append(newStats)
        }
        
        updateTodayScreenTime()
        saveData()
        
        // Vérifier si la limite est dépassée
        checkLimit()
    }
    
    // Vérifier si la limite quotidienne est dépassée
    func checkLimit() {
        if totalScreenTime >= dailyLimit && notificationsEnabled {
            sendLimitReachedNotification()
        }
    }
    
    // Basculer le blocage d'une application
    func toggleAppBlock(_ app: AppInfo) {
        if let index = apps.firstIndex(where: { $0.id == app.id }) {
            apps[index].isBlocked.toggle()
            saveData()
            
            if apps[index].isBlocked {
                sendAppBlockedNotification(app: apps[index])
            }
        }
    }
    
    // Définir la limite quotidienne
    func setDailyLimit(_ limit: TimeInterval) {
        dailyLimit = limit
        saveData()
    }
    
    // Définir la limite pour une application
    func setAppLimit(_ app: AppInfo, limit: TimeInterval) {
        if let index = apps.firstIndex(where: { $0.id == app.id }) {
            apps[index].dailyLimit = limit
            saveData()
        }
    }
    
    // Ajouter une nouvelle application
    func addApp(name: String, bundleId: String) {
        let newApp = AppInfo(name: name, bundleId: bundleId)
        apps.append(newApp)
        saveData()
    }
    
    // Supprimer une application
    func removeApp(_ app: AppInfo) {
        apps.removeAll { $0.id == app.id }
        saveData()
    }
    
    // Générer des données d'exemple si nécessaire
    private func generateSampleDataIfNeeded() {
        // Générer des données pour les 14 derniers jours si on n'a pas assez de données
        if dailyStats.count < 7 {
            let calendar = Calendar.current
            let today = Date()
            
            for i in 0..<14 {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    let dayStart = calendar.startOfDay(for: date)
                    
                    // Vérifier si les données existent déjà
                    if !dailyStats.contains(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
                        // Générer un temps d'écran aléatoire entre 2 et 6 heures
                        let randomHours = Double.random(in: 2.0...6.0)
                        let randomTime = randomHours * 3600
                        
                        var newStats = DailyStats(date: dayStart)
                        newStats.totalScreenTime = randomTime
                        
                        // Ajouter de l'utilisation pour quelques applications
                        let shuffledApps = apps.shuffled().prefix(Int.random(in: 2...5))
                        for app in shuffledApps {
                            let appTime = randomTime * Double.random(in: 0.1...0.4)
                            newStats.appUsage[app.bundleId] = appTime
                        }
                        
                        dailyStats.append(newStats)
                    }
                }
            }
            
            // Trier par date
            dailyStats.sort { $0.date < $1.date }
            saveData()
        }
    }
    
    // Démarrer le suivi (simulation)
    private func startTracking() {
        // Simuler l'ajout de temps d'écran toutes les minutes
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            // Simulation : ajouter 30 secondes de temps d'écran toutes les minutes
            // En production, cela devrait être remplacé par un vrai suivi
            if let self = self, !self.apps.isEmpty {
                let randomApp = self.apps.randomElement()!
                self.addScreenTime(30, for: randomApp.bundleId)
            }
        }
    }
    
    // Demander la permission pour les notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Permission de notification accordée")
                } else {
                    print("Permission de notification refusée")
                }
            }
        }
    }
    
    // Envoyer une notification de limite atteinte
    func sendLimitReachedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Limite de temps d'écran atteinte"
        content.body = "Vous avez atteint votre limite quotidienne de \(formatTime(dailyLimit))."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "limitReached", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Envoyer une notification d'application bloquée
    func sendAppBlockedNotification(app: AppInfo) {
        let content = UNMutableNotificationContent()
        content.title = "Application bloquée"
        content.body = "\(app.name) a été ajoutée à votre liste de blocage."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "appBlocked-\(app.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Formater le temps en heures:minutes
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes)min"
        }
    }
    
    // Obtenir le temps d'écran pour une application aujourd'hui
    func getAppTimeToday(_ app: AppInfo) -> TimeInterval {
        let today = Calendar.current.startOfDay(for: Date())
        if let stats = dailyStats.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            return stats.appUsage[app.bundleId] ?? 0
        }
        return 0
    }
    
    // Ouvrir les paramètres Screen Time d'iOS
    func openScreenTimeSettings() {
        if let url = URL(string: "App-Prefs:SCREEN_TIME") {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

