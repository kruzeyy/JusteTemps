import Foundation
import DeviceActivity
import ManagedSettings

// Extension pour surveiller l'activité de l'appareil
extension DeviceActivityName {
    static let today = Self("today")
}

// Monitor pour enregistrer l'activité et collecter les vraies données
class MyMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // L'intervalle de surveillance a commencé
        print("📱 DeviceActivity interval started: \(activity)")
        
        // Réinitialiser les données pour le nouveau jour
        if activity == DeviceActivityName("today") {
            // Utiliser UserDefaults partagé si disponible, sinon standard (fallback silencieux)
            let sharedDefaults: UserDefaults
            if let suiteDefaults = UserDefaults(suiteName: "group.com.justetemps.app") {
                sharedDefaults = suiteDefaults
            } else {
                sharedDefaults = UserDefaults.standard
            }
            sharedDefaults.set(0, forKey: "todayStartTime")
            sharedDefaults.set(Date().timeIntervalSince1970, forKey: "intervalStartTime")
            sharedDefaults.synchronize()
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // L'intervalle de surveillance est terminé
        print("📱 DeviceActivity interval ended: \(activity)")
        
        // Calculer le temps total écoulé
        if activity == DeviceActivityName("today") {
            // Utiliser UserDefaults partagé si disponible, sinon standard (fallback silencieux)
            let sharedDefaults: UserDefaults
            if let suiteDefaults = UserDefaults(suiteName: "group.com.justetemps.app") {
                sharedDefaults = suiteDefaults
            } else {
                sharedDefaults = UserDefaults.standard
            }
            if let startTime = sharedDefaults.object(forKey: "intervalStartTime") as? TimeInterval {
                let elapsed = Date().timeIntervalSince1970 - startTime
                let currentTotal = sharedDefaults.double(forKey: "totalScreenTimeToday")
                let newTotal = currentTotal + elapsed
                
                sharedDefaults.set(newTotal, forKey: "totalScreenTimeToday")
                sharedDefaults.synchronize()
                
                // Notifier le ScreenTimeManager
                NotificationCenter.default.post(
                    name: NSNotification.Name("ScreenTimeDataUpdated"),
                    object: nil,
                    userInfo: ["totalTime": newTotal]
                )
            }
        }
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Un événement de seuil a été atteint
        print("⚠️ DeviceActivity event reached threshold: \(event) for \(activity)")
    }
}

// Extension pour récupérer les données d'activité
extension ScreenTimeManager {
    // Cette fonction sera appelée périodiquement pour mettre à jour les données
    func refreshScreenTimeData() {
        guard screenTimeAuthorizationStatus == .approved else {
            return
        }
        
        // Note: Pour obtenir les données réelles de Screen Time, nous devons utiliser
        // une DeviceActivityReport qui nécessite une vue SwiftUI spécifique.
        // Pour l'instant, nous mettons à jour les données depuis UserDefaults
        // qui sont sauvegardées par le monitor.
        updateTodayScreenTime()
    }
}

