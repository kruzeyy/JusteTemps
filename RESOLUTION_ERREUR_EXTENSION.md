# Résolution de l'erreur d'installation de l'extension

## Erreur
```
Expected executable at "JusteTemps.app/Extensions/JusteTempsReportExtension.appex/JusteTempsReportExtension" to have a __swift5_entry section
```

## Solution

J'ai créé le fichier `JusteTempsReportExtension.swift` avec un point d'entrée `@main`. Maintenant, vous devez vérifier quelques points dans Xcode :

### 1. Vérifier que le fichier est dans le target

1. Dans Xcode, sélectionnez le fichier `JusteTempsReportExtension.swift`
2. Ouvrez le "File Inspector" (⌥⌘1)
3. Dans la section "Target Membership", vérifiez que **JusteTempsReportExtension** est coché
4. Assurez-vous que **JusteTemps** (l'application principale) n'est PAS coché pour ce fichier

### 2. Vérifier la configuration du target

1. Sélectionnez le projet "JusteTemps" dans le navigateur
2. Sélectionnez le target **JusteTempsReportExtension**
3. Allez dans l'onglet "General"
4. Vérifiez que :
   - **Product Name** : `JusteTempsReportExtension`
   - **Bundle Identifier** : `com.justetemps.app.reportextension`
   - **Deployment Target** : Même version que l'application principale

### 3. Vérifier les Build Settings

1. Toujours dans le target **JusteTempsReportExtension**
2. Allez dans l'onglet "Build Settings"
3. Recherchez "Swift Compiler - General"
4. Vérifiez que **Swift Language Version** est défini (généralement "Swift 5")

### 4. Nettoyer et reconstruire

1. Dans Xcode : `Product` → `Clean Build Folder` (⇧⌘K)
2. Fermez Xcode
3. Supprimez le dossier DerivedData :
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/JusteTemps-*
   ```
4. Rouvrez Xcode
5. Recompilez le projet (⌘B)
6. Essayez d'installer à nouveau sur l'appareil

### 5. Vérifier les Entitlements

1. Dans le target **JusteTempsReportExtension**
2. Allez dans "Signing & Capabilities"
3. Vérifiez que :
   - **App Groups** est activé avec `group.com.justetemps.app`
   - **Family Controls** est activé (si disponible)

### 6. Si le problème persiste

Si l'erreur persiste après ces étapes, essayez :

1. **Supprimer l'extension et la recréer** :
   - Supprimez le target "JusteTempsReportExtension" dans Xcode
   - Recréez-le avec "New Target" → "Device Activity Report Extension"
   - Recopiez les fichiers `TotalActivityReport.swift` et `TotalActivityView.swift`

2. **Vérifier les dépendances** :
   - Assurez-vous que l'extension n'a pas de dépendances vers l'application principale
   - L'extension doit être indépendante

3. **Vérifier la version de Xcode** :
   - Assurez-vous d'utiliser une version récente de Xcode
   - Les extensions DeviceActivityReport nécessitent Xcode 14+ et iOS 16+

## Note importante

L'extension DeviceActivityReport ne peut pas être testée dans le simulateur. Vous devez tester sur un appareil réel.

Une fois l'extension correctement installée, elle sauvegardera automatiquement les vraies données de Screen Time dans UserDefaults partagé avec la clé `realScreenTimeToday`, et l'application principale les affichera.

