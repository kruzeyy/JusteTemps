# Solution pour obtenir les vraies données de Screen Time

## Problème actuel

Votre application affiche 0 minutes alors que Jomo affiche 8 minutes. C'est parce que l'API FamilyControls d'Apple ne permet pas de récupérer directement les données historiques de Screen Time sans créer une extension séparée.

## Solution : Créer une extension DeviceActivityReport

Pour obtenir les vraies données comme Jomo, vous devez créer une **extension DeviceActivityReport** séparée. C'est la seule façon d'accéder aux données réelles de Screen Time.

### Étapes pour créer l'extension

1. **Dans Xcode**, faites un clic droit sur le projet "JusteTemps"
2. **Sélectionnez "New Target..."**
3. **Choisissez "Device Activity Report Extension"** (sous iOS)
4. **Configurez l'extension** :
   - Product Name: `JusteTempsReportExtension`
   - Bundle Identifier: `com.justetemps.app.reportextension`
   - Language: Swift
5. **Cliquez sur "Finish"**

### Code pour l'extension

Dans le fichier créé par Xcode (généralement `Report.swift`), remplacez le contenu par :

```swift
import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("totalActivity")
}

struct JusteTempsReport: DeviceActivityReportScene {
    var body: some DeviceActivityReportScene {
        TotalActivityReport { total in
            // Extraire les vraies données de Screen Time
            let totalTime = total.totalActivityDuration
            
            // Sauvegarder dans UserDefaults partagé
            if let sharedDefaults = UserDefaults(suiteName: "group.com.justetemps.app") {
                sharedDefaults.set(totalTime, forKey: "realScreenTimeToday")
                sharedDefaults.synchronize()
            }
            
            // Afficher les données
            VStack {
                Text("Temps d'écran")
                    .font(.headline)
                Text(formatTime(totalTime))
                    .font(.title)
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes)min"
    }
}
```

### Configurer App Groups

1. **Dans l'application principale** (target JusteTemps) :
   - "Signing & Capabilities" → "+ Capability" → "App Groups"
   - Créez : `group.com.justetemps.app`

2. **Dans l'extension** (target JusteTempsReportExtension) :
   - "Signing & Capabilities" → "+ Capability" → "App Groups"
   - Cochez le même groupe : `group.com.justetemps.app`

### Modifier ScreenTimeManager pour lire les données

Le code a déjà été modifié pour lire depuis UserDefaults partagé. Assurez-vous que `loadRealScreenTimeData()` lit depuis la clé `realScreenTimeToday`.

## Alternative : Utiliser directement dans l'application

Si vous ne voulez pas créer d'extension, vous pouvez utiliser `DeviceActivityReportView` directement dans votre application, mais cela nécessite une configuration spéciale et peut ne pas fonctionner pour toutes les données.

## Important

- ⚠️ L'extension DeviceActivityReport ne peut pas être testée dans le simulateur
- ✅ Vous devez tester sur un appareil réel
- ✅ Les données peuvent prendre quelques minutes à apparaître après l'autorisation

