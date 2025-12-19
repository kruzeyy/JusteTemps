import SwiftUI
import DeviceActivity

// Extension pour les contextes de rapport
extension DeviceActivityReport.Context {
    static let totalActivity = Self("totalActivity")
}

// Vue pour obtenir les vraies données de Screen Time
// Cette vue doit être intégrée dans l'application pour récupérer les données réelles
struct RealScreenTimeDataView: View {
    @Binding var totalTime: TimeInterval
    @Binding var appUsage: [String: TimeInterval]
    
    var body: some View {
        // Utiliser DeviceActivityReportView pour obtenir les vraies données
        DeviceActivityReportView(.totalActivity) { report in
            // Cette closure reçoit les vraies données de Screen Time
            if let totalActivity = report.totalActivityDuration {
                // Mettre à jour le temps total
                DispatchQueue.main.async {
                    totalTime = totalActivity
                }
                
                // Extraire les données par application
                var usage: [String: TimeInterval] = [:]
                
                if let categories = report.categories {
                    for category in categories {
                        if let applications = category.applications {
                            for application in applications {
                                // Utiliser le token pour identifier l'application
                                let token = application.token
                                let duration = application.totalActivityDuration
                                
                                // Convertir le token en bundle ID si possible
                                // Note: Le token est un ApplicationToken, on doit le convertir
                                usage[token.description] = duration
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    appUsage = usage
                }
            }
        }
    }
}

