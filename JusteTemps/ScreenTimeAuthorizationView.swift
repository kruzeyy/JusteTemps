import SwiftUI
import FamilyControls

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

