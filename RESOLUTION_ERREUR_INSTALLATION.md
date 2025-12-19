# Résolution de l'erreur d'installation (CoreDeviceError 3002)

## Erreur

```
Failed to install the app on the device.
Domain: com.apple.dt.CoreDeviceError
Code: 3002
```

## Causes possibles

Cette erreur peut avoir plusieurs causes :
1. **Problème de provisioning profile** : Le profil de provisionnement n'est pas valide ou n'a pas les bonnes capabilities
2. **Problème de signature** : Le code n'est pas correctement signé
3. **Problème de certificat** : Le certificat de développement a expiré ou n'est pas valide
4. **Problème de bundle identifier** : Le bundle ID ne correspond pas au provisioning profile
5. **Problème d'entitlements** : Les entitlements ne correspondent pas au provisioning profile

## Solutions

### Solution 1 : Vérifier la signature dans Xcode

1. **Ouvrez Xcode**
2. **Sélectionnez le projet "JusteTemps"**
3. **Sélectionnez le target "JusteTemps"**
4. **Allez dans "Signing & Capabilities"**
5. **Vérifiez** :
   - ✅ **Team** : Votre équipe payante est sélectionnée (pas "Personal Team")
   - ✅ **Bundle Identifier** : `com.justetemps.app`
   - ✅ **Provisioning Profile** : Devrait être automatique, mais vérifiez qu'il n'y a pas d'erreur
   - ✅ **Signing Certificate** : Devrait être "Apple Development"

6. **Si vous voyez une erreur** (icône d'avertissement rouge) :
   - Cliquez sur "Try Again" ou "Download Manual Profiles"
   - Ou sélectionnez manuellement un provisioning profile

### Solution 2 : Nettoyer et régénérer les certificats

1. **Dans Xcode**, allez dans `Xcode` → `Settings` → `Accounts`
2. **Sélectionnez votre compte Apple Developer**
3. **Cliquez sur "Download Manual Profiles"**
4. **Sélectionnez votre équipe**
5. **Cliquez sur "Manage Certificates..."**
6. **Vérifiez qu'un certificat "Apple Development" existe**
   - Si ce n'est pas le cas, cliquez sur "+" et créez-en un

### Solution 3 : Vérifier le Developer Portal

1. **Allez sur** https://developer.apple.com/account/
2. **Connectez-vous**
3. **Allez dans "Certificates, Identifiers & Profiles"**
4. **Vérifiez** :
   - **Identifiers** → `com.justetemps.app` existe et a "Family Controls" activé
   - **Profiles** → Un profil de développement existe pour cet App ID
   - **Certificates** → Un certificat de développement valide existe

### Solution 4 : Supprimer et recréer le provisioning profile

1. **Dans le Developer Portal** :
   - Allez dans "Profiles"
   - Supprimez l'ancien profil de développement pour `com.justetemps.app`
   - Créez-en un nouveau :
     - Type : "iOS App Development"
     - App ID : `com.justetemps.app`
     - Certificats : Sélectionnez votre certificat
     - Devices : Sélectionnez votre iPhone
     - Téléchargez le profil

2. **Dans Xcode** :
   - Allez dans "Signing & Capabilities"
   - Changez "Automatically manage signing" à OFF puis ON
   - Ou sélectionnez manuellement le nouveau profil

### Solution 5 : Vérifier l'appareil

1. **Sur votre iPhone** :
   - Allez dans `Réglages` → `Général` → `Gestion du profil et des appareils`
   - Vérifiez que votre profil de développeur est installé
   - Si nécessaire, appuyez sur "Faire confiance"

2. **Vérifiez que l'appareil est bien connecté** :
   - Dans Xcode, vérifiez que votre iPhone apparaît dans la liste des destinations
   - Vérifiez qu'il n'y a pas d'avertissement à côté de l'appareil

### Solution 6 : Nettoyer le build

1. **Dans Xcode** :
   - `Product` → `Clean Build Folder` (⇧⌘K)
   - Fermez Xcode
   - Supprimez le dossier `DerivedData` :
     - Allez dans `~/Library/Developer/Xcode/DerivedData/`
     - Supprimez le dossier `JusteTemps-*`
   - Rouvrez Xcode
   - Recompilez

### Solution 7 : Vérifier les entitlements

1. **Vérifiez que le fichier `JusteTemps.entitlements` est correct** :
   - Il doit contenir `com.apple.developer.family-controls`
   - Il doit être référencé dans "Code Signing Entitlements" des Build Settings

2. **Vérifiez dans "Signing & Capabilities"** :
   - La capability "Family Controls" doit être présente
   - Elle doit avoir l'entitlement `com.apple.developer.family-controls`

## Solution rapide à essayer en premier

1. **Dans Xcode** → "Signing & Capabilities"
2. **Décochez "Automatically manage signing"**
3. **Attendez quelques secondes**
4. **Recochez "Automatically manage signing"**
5. **Sélectionnez votre équipe**
6. **Xcode devrait régénérer le provisioning profile**
7. **Recompilez et installez**

## Si rien ne fonctionne

1. **Vérifiez que votre compte Apple Developer est bien actif** :
   - Allez sur https://developer.apple.com/account/
   - Vérifiez que votre statut est "Active"

2. **Attendez quelques minutes** :
   - Parfois les services Apple mettent du temps à se synchroniser

3. **Contactez le support Apple Developer** si le problème persiste

