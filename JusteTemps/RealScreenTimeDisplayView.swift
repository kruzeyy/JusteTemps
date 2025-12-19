import SwiftUI
import DeviceActivity

// Extension pour les contextes de rapport
// Note: Cette extension doit correspondre à celle dans JusteTempsReportExtension
extension DeviceActivityReport.Context {
    static let totalActivity = Self("totalActivity")
}

// Vue pour afficher les vraies données de Screen Time
// Utilise DeviceActivityReportView pour obtenir les données réelles depuis iOS
struct RealScreenTimeDisplayView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var realTotalTime: TimeInterval = 0
    
    var body: some View {
        // Afficher le temps (mis à jour par DeviceActivityReportView en arrière-plan)
        Text(screenTimeManager.formatTime(realTotalTime > 0 ? realTotalTime : screenTimeManager.totalScreenTime))
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(.primary)
            .background(
                // Utiliser DeviceActivityReportView en arrière-plan pour récupérer les données
                DeviceActivityReportView(.totalActivity) { report in
                    // Cette closure reçoit les vraies données de Screen Time depuis iOS
                    let totalActivity = report.totalActivityDuration
                    let seconds = totalActivity
                    
                    // Mettre à jour le temps affiché
                    DispatchQueue.main.async {
                        self.realTotalTime = seconds
                        
                        // Mettre à jour le ScreenTimeManager avec les vraies données
                        screenTimeManager.updateRealScreenTime(totalTime: seconds)
                    }
                }
                .frame(width: 0, height: 0)
                .hidden()
            )
            .onAppear {
                // Charger les données sauvegardées en attendant
                loadSavedData()
            }
    }
    
    private func loadSavedData() {
        // Charger depuis UserDefaults en attendant les vraies données
        let sharedDefaults = UserDefaults(suiteName: "group.com.justetemps.app") ?? UserDefaults.standard
        
        // Essayer d'abord les vraies données depuis l'extension
        if let totalTime = sharedDefaults.object(forKey: "realScreenTimeToday") as? TimeInterval, totalTime > 0 {
            realTotalTime = totalTime
        } else if let totalTime = sharedDefaults.object(forKey: "totalScreenTimeToday") as? TimeInterval, totalTime > 0 {
            // Fallback : données collectées par le monitor
            realTotalTime = totalTime
        }
    }
}

