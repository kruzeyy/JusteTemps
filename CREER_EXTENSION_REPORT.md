# Créer une Extension DeviceActivityReport pour les vraies données Screen Time

## Pourquoi une extension ?

Pour obtenir les **vraies données de temps d'écran** depuis Screen Time, Apple nécessite une **extension DeviceActivityReport** séparée. C'est la seule façon d'accéder aux données réelles.

## Étapes pour créer l'extension

### 1. Créer le nouveau target dans Xcode

1. **Ouvrez Xcode**
2. **Faites un clic droit sur le projet** "JusteTemps" dans le navigateur
3. **Sélectionnez "New Target..."**
4. **Choisissez "Device Activity Report Extension"** (sous iOS)
5. **Cliquez sur "Next"**
6. **Configurez l'extension** :
   - Product Name: `JusteTempsReportExtension`
   - Bundle Identifier: `com.justetemps.app.reportextension`
   - Language: Swift
7. **Cliquez sur "Finish"**

### 2. Configurer l'extension

1. **Sélectionnez le target** `JusteTempsReportExtension`
2. **Allez dans "Signing & Capabilities"**
3. **Sélectionnez la même équipe** que l'application principale
4. **Vérifiez que "Family Controls" est activé** (devrait être automatique)

### 3. Créer le fichier de rapport

1. **Dans le dossier de l'extension**, créez un nouveau fichier Swift
2. **Nommez-le** `ScreenTimeReport.swift`
3. **Copiez le contenu suivant** :

```swift
import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("totalActivity")
}

struct ScreenTimeReport: DeviceActivityReportScene {
    var body: some DeviceActivityReportScene {
        TotalActivityReport { total in
            // Extraire les données réelles
            let totalTime = total.totalActivityDuration
            
            // Sauvegarder dans UserDefaults partagé
            if let sharedDefaults = UserDefaults(suiteName: "group.com.justetemps.app") {
                sharedDefaults.set(totalTime, forKey: "totalScreenTime")
                sharedDefaults.synchronize()
            }
            
            // Afficher les données (optionnel)
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
        return "\(hours)h \(minutes)min"
    }
}
```

### 4. Configurer App Groups (pour partager les données)

1. **Dans l'application principale** (target JusteTemps) :
   - Allez dans "Signing & Capabilities"
   - Ajoutez la capability "App Groups"
   - Créez un groupe : `group.com.justetemps.app`

2. **Dans l'extension** (target JusteTempsReportExtension) :
   - Allez dans "Signing & Capabilities"
   - Ajoutez la capability "App Groups"
   - Cochez le même groupe : `group.com.justetemps.app`

### 5. Modifier ScreenTimeManager pour lire les données partagées

Le code a déjà été modifié pour lire depuis UserDefaults partagé. Assurez-vous que le groupe App Group est bien configuré.

### 6. Tester

1. **Compilez et lancez l'application** sur un appareil réel
2. **Les données réelles de Screen Time** devraient maintenant être affichées
3. **Vérifiez dans les logs** si les données sont bien récupérées

## Alternative : Utiliser directement dans l'application

Si vous ne voulez pas créer d'extension séparée, vous pouvez utiliser `DeviceActivityReportView` directement dans votre application SwiftUI, mais cela nécessite quand même une configuration spéciale.

## Note importante

- ⚠️ L'extension DeviceActivityReport ne peut pas être testée dans le simulateur
- ✅ Vous devez tester sur un appareil réel
- ✅ Les données peuvent prendre quelques minutes à apparaître après l'autorisation

