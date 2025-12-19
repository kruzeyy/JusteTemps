import Foundation
import SwiftUI
import UserNotifications
import FamilyControls
import DeviceActivity
import ManagedSettings

class ScreenTimeManager: ObservableObject {
    @Published var totalScreenTime: TimeInterval = 0 // en secondes
    @Published var dailyLimit: TimeInterval = 3600 // 1 heure par défaut
    @Published var apps: [AppInfo] = []
    @Published var dailyStats: [DailyStats] = []
    @Published var notificationsEnabled: Bool = true
    @Published var screenTimeAuthorizationStatus: AuthorizationStatus = .notDetermined
    @Published var screenTimeError: String?
    
    private let userDefaults = UserDefaults.standard
    private let appsKey = "blockedApps"
    private let statsKey = "dailyStats"
    private let limitKey = "dailyLimit"
    private let notificationsKey = "notificationsEnabled"
    private let authorizationCenter = AuthorizationCenter.shared
    private let deviceActivityCenter = DeviceActivityCenter()
    
    init() {
        loadData()
        checkScreenTimeAuthorization()
        requestNotificationPermission()
        setupScreenTimeNotifications()
        if screenTimeAuthorizationStatus == .approved {
            startRealTimeTracking()
            startPeriodicDataRefresh()
        } else {
            // Utiliser les données simulées seulement si l'autorisation n'est pas accordée
            generateSampleDataIfNeeded()
            startTracking()
        }
    }
    
    // Configurer les notifications pour recevoir les données Screen Time
    private func setupScreenTimeNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ScreenTimeDataUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let totalTime = notification.userInfo?["totalTime"] as? TimeInterval {
                self?.updateScreenTimeFromDeviceActivity(totalTime: totalTime)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AppUsageDataUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let appUsage = notification.userInfo?["appUsage"] as? [String: TimeInterval] {
                self?.updateAppUsageFromDeviceActivity(appUsage: appUsage)
            }
        }
    }
    
    // Mettre à jour le temps d'écran depuis DeviceActivity
    private func updateScreenTimeFromDeviceActivity(totalTime: TimeInterval) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Trouver ou créer les stats d'aujourd'hui
        if let index = dailyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyStats[index].totalScreenTime = totalTime
        } else {
            var newStats = DailyStats(date: today)
            newStats.totalScreenTime = totalTime
            dailyStats.append(newStats)
        }
        
        updateTodayScreenTime()
        saveData()
    }
    
    // Mettre à jour l'utilisation par application depuis DeviceActivity
    private func updateAppUsageFromDeviceActivity(appUsage: [String: TimeInterval]) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Trouver ou créer les stats d'aujourd'hui
        if let index = dailyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            // Mettre à jour l'utilisation par application
            for (bundleId, time) in appUsage {
                dailyStats[index].appUsage[bundleId] = time
            }
        } else {
            var newStats = DailyStats(date: today)
            newStats.appUsage = appUsage
            dailyStats.append(newStats)
        }
        
        updateTodayScreenTime()
        saveData()
    }
    
    // Fonction publique pour mettre à jour depuis DeviceActivityReportView
    func updateRealScreenTime(totalTime: TimeInterval) {
        updateScreenTimeFromDeviceActivity(totalTime: totalTime)
    }
    
    // Démarrer le rafraîchissement périodique des données
    private func startPeriodicDataRefresh() {
        // Rafraîchir les données toutes les 5 minutes
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self = self, self.screenTimeAuthorizationStatus == .approved else { return }
            // Recharger les données depuis UserDefaults
            self.loadRealScreenTimeData()
        }
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
    
    // Générer des données d'exemple si nécessaire (seulement si l'autorisation n'est pas accordée)
    private func generateSampleDataIfNeeded() {
        // Ne générer des données d'exemple que si l'autorisation Screen Time n'est pas accordée
        guard screenTimeAuthorizationStatus != .approved else {
            return
        }
        
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
    
    // Vérifier le statut d'autorisation Screen Time
    func checkScreenTimeAuthorization() {
        Task { @MainActor in
            screenTimeAuthorizationStatus = authorizationCenter.authorizationStatus
        }
    }
    
    // Demander l'autorisation Screen Time
    func requestScreenTimeAuthorization() async {
        // Note: Family Controls nécessite un compte Apple Developer payant
        // Si vous utilisez un compte gratuit, cette fonctionnalité ne sera pas disponible
        #if !targetEnvironment(simulator)
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            await MainActor.run {
                checkScreenTimeAuthorization()
                if screenTimeAuthorizationStatus == .approved {
                    startRealTimeTracking()
                }
            }
        } catch {
            await MainActor.run {
                print("Erreur lors de la demande d'autorisation Screen Time: \(error)")
                // En cas d'erreur (par exemple compte gratuit), utiliser les données simulées
                screenTimeError = "L'accès à Screen Time nécessite un compte Apple Developer payant ($99/an). L'application utilisera des données simulées."
                // Continuer avec les données simulées
                generateSampleDataIfNeeded()
                startTracking()
            }
        }
        #else
        await MainActor.run {
            errorMessage = "L'API FamilyControls ne fonctionne pas dans le simulateur. Testez sur un appareil réel."
        }
        #endif
    }
    
    // Démarrer le suivi en temps réel avec DeviceActivity
    private func startRealTimeTracking() {
        // Créer un DeviceActivitySchedule pour surveiller toute la journée
        // Note: Ce schedule surveillera l'activité et le DeviceActivityMonitor
        // sera appelé aux moments appropriés (début/fin d'intervalle, événements)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true,
            warningTime: nil
        )
        
        // Créer un nom d'activité pour identifier cette surveillance
        let activityName = DeviceActivityName("today")
        
        // Démarrer la surveillance
        // Signature correcte: startMonitoring(_ activity: DeviceActivityName, during: DeviceActivitySchedule)
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
            print("✅ Surveillance DeviceActivity démarrée")
        } catch {
            print("❌ Erreur lors du démarrage de la surveillance DeviceActivity: \(error)")
        }
        
        // Charger les données depuis les données sauvegardées
        // (Les vraies données seront collectées par le DeviceActivityMonitor)
        loadRealScreenTimeData()
    }
    
    // Charger les vraies données de temps d'écran
    private func loadRealScreenTimeData() {
        // Essayer de charger depuis UserDefaults partagé (si App Groups est configuré)
        // Sinon utiliser UserDefaults standard
        let sharedDefaults = UserDefaults(suiteName: "group.com.justetemps.app") ?? userDefaults
        
        // Charger les données sauvegardées depuis l'extension DeviceActivityReport
        if let totalTime = sharedDefaults.object(forKey: "realScreenTimeToday") as? TimeInterval, totalTime > 0 {
            updateScreenTimeFromDeviceActivity(totalTime: totalTime)
        } else if let totalTime = sharedDefaults.object(forKey: "totalScreenTimeToday") as? TimeInterval, totalTime > 0 {
            // Fallback : données collectées par le monitor
            updateScreenTimeFromDeviceActivity(totalTime: totalTime)
        } else {
            // Si pas de données sauvegardées, essayer de lire depuis Screen Time directement
            Task {
                await fetchRealScreenTimeFromSystem()
            }
        }
        
        // Mettre à jour les données périodiquement
        Task {
            await updateRealTimeData()
        }
    }
    
    // Essayer de récupérer les vraies données depuis le système Screen Time
    private func fetchRealScreenTimeFromSystem() async {
        // Note: Pour obtenir les vraies données historiques, il faut utiliser DeviceActivityReport
        // qui nécessite une extension séparée. Cependant, on peut essayer d'utiliser
        // les données disponibles via le monitor qui sont collectées en temps réel.
        
        // Pour l'instant, on utilise les données collectées par le monitor
        // qui sont sauvegardées dans UserDefaults
        await MainActor.run {
            updateTodayScreenTime()
        }
    }
    
    // Mettre à jour les données en temps réel
    private func updateRealTimeData() async {
        // Utiliser DeviceActivityReport pour obtenir les vraies données
        // Note: Cela nécessite que l'extension DeviceActivityReport soit configurée
        // Pour l'instant, on utilise les données collectées par le monitor
        
        await MainActor.run {
            // Mettre à jour avec les données sauvegardées localement
            // Le DeviceActivityMonitor et les rapports enregistreront les données
            updateTodayScreenTime()
        }
        
        // Essayer de récupérer les données via DeviceActivityReport
        await fetchDeviceActivityReport()
    }
    
    // Récupérer les données depuis DeviceActivityReport
    private func fetchDeviceActivityReport() async {
        // Note: DeviceActivityReport nécessite une extension séparée pour fonctionner
        // Les données sont collectées via le DeviceActivityMonitor qui les sauvegarde
        // dans UserDefaults. On les lit depuis là.
        
        // Les données sont déjà chargées via loadRealScreenTimeData()
        // Cette fonction est là pour référence future si on crée une extension DeviceActivityReport
        
        // Pour l'instant, on utilise les données collectées par le monitor
        // qui sont sauvegardées dans UserDefaults et mises à jour via les notifications
    }
    
    // Démarrer le suivi (simulation - utilisé seulement si l'autorisation n'est pas accordée)
    private func startTracking() {
        // Simuler l'ajout de temps d'écran toutes les minutes
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            // Simulation : ajouter 30 secondes de temps d'écran toutes les minutes
            // En production, cela devrait être remplacé par un vrai suivi
            if let self = self, !self.apps.isEmpty, self.screenTimeAuthorizationStatus != .approved {
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

