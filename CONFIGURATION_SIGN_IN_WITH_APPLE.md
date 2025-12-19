# Configuration de Sign in with Apple

## Erreur rencontrée
```
Authorization failed: Error Domain=AKAuthenticationError Code=-7026
ASAuthorizationController credential request failed with error: Error Domain=com.apple.AuthenticationServices.AuthorizationError Code=1000
```

Cette erreur indique que Sign in with Apple n'est pas correctement configuré dans votre projet Xcode ou dans le Developer Portal.

## Solution : Configurer Sign in with Apple

### Étape 1 : Activer la capacité dans Xcode

1. **Ouvrez votre projet dans Xcode**
   - Ouvrez `JusteTemps.xcodeproj`

2. **Sélectionnez le target "JusteTemps"**
   - Dans le navigateur de projet, cliquez sur l'icône bleue "JusteTemps"
   - Sous "TARGETS", sélectionnez "JusteTemps"

3. **Allez dans l'onglet "Signing & Capabilities"**

4. **Cliquez sur le bouton "+ Capability"** (en haut à gauche)

5. **Recherchez et ajoutez "Sign in with Apple"**
   - Tapez "Sign in with Apple" dans la recherche
   - Double-cliquez sur "Sign in with Apple" pour l'ajouter

6. **Vérifiez que la capacité apparaît**
   - Vous devriez voir "Sign in with Apple" dans la liste des capabilities

### Étape 2 : Configurer dans le Apple Developer Portal

1. **Allez sur https://developer.apple.com/account/**
   - Connectez-vous avec votre compte Apple Developer

2. **Accédez aux Identifiers**
   - Cliquez sur "Certificates, Identifiers & Profiles" dans le menu de gauche
   - Cliquez sur "Identifiers" dans le menu

3. **Sélectionnez votre App ID**
   - Recherchez `com.justetemps.app`
   - Cliquez dessus pour l'éditer

4. **Activez Sign in with Apple**
   - Cochez la case "Sign in with Apple"
   - Cliquez sur "Configure" à côté de "Sign in with Apple"
   - Sélectionnez "Enable as a primary App ID"
   - Cliquez sur "Save"
   - Cliquez sur "Continue"
   - Cliquez sur "Register"

### Étape 3 : Régénérer le provisioning profile

Après avoir activé Sign in with Apple dans le Developer Portal :

1. **Dans Xcode**
   - Allez dans "Signing & Capabilities"
   - Décochez "Automatically manage signing"
   - Attendez 2-3 secondes
   - Recochez "Automatically manage signing"
   - Sélectionnez votre équipe (votre compte Apple Developer payant)

2. **Ou téléchargez manuellement les profils**
   - Dans Xcode : `Xcode → Settings → Accounts`
   - Sélectionnez votre compte Apple Developer
   - Cliquez sur "Download Manual Profiles"

### Étape 4 : Nettoyer et reconstruire

1. **Nettoyez le build**
   - `Product → Clean Build Folder` (⇧⌘K)

2. **Fermez Xcode**

3. **Supprimez le cache**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/JusteTemps-*
   ```

4. **Rouvrez Xcode**

5. **Recompilez**
   - `Product → Build` (⌘B)

6. **Réinstallez sur l'appareil**
   - `Product → Run` (⌘R)

### Étape 5 : Vérifier les Entitlements

Assurez-vous que le fichier `JusteTemps.entitlements` contient :

```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

Si cette clé n'existe pas, Xcode devrait l'ajouter automatiquement lorsque vous ajoutez la capacité "Sign in with Apple" dans l'onglet "Signing & Capabilities".

## Vérification finale

Une fois configuré :

1. ✅ La capacité "Sign in with Apple" apparaît dans "Signing & Capabilities"
2. ✅ L'entitlement `com.apple.developer.applesignin` est présent dans `JusteTemps.entitlements`
3. ✅ Sign in with Apple est activé dans le Developer Portal pour `com.justetemps.app`
4. ✅ Le provisioning profile est régénéré
5. ✅ L'application peut se connecter avec Apple sans erreur

## Note importante

- ⚠️ Sign in with Apple nécessite un compte Apple Developer payant ($99/an)
- ⚠️ Vous devez tester sur un appareil réel (ne fonctionne pas dans le simulateur pour la première authentification)
- ⚠️ Si vous utilisez un compte de test, assurez-vous qu'il est configuré dans les paramètres de l'appareil (Réglages → [Votre nom] → Sign in with Apple)

