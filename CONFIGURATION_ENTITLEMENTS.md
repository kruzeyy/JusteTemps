# Configuration des Entitlements pour Screen Time

## Erreur "Sandbox restriction" (Erreur 159)

Si vous voyez cette erreur :
```
Error Domain=NSCocoaErrorDomain Code=4099 "The connection to service named com.apple.FamilyControlsAgent was invalidated: Connection init failed at lookup with error 159 - Sandbox restriction."
```

Cela signifie que l'application n'a pas l'entitlement "Family Controls" configuré correctement dans Xcode.

## Solution : Configuration des Entitlements dans Xcode

### Option 1 : Via l'interface Xcode (Recommandé)

1. **Ouvrez votre projet dans Xcode**

2. **Sélectionnez le target "JusteTemps"** dans le navigateur de projet (à gauche)

3. **Allez dans l'onglet "Signing & Capabilities"**

4. **Cliquez sur le bouton "+ Capability"** en haut à gauche

5. **Recherchez et ajoutez "Family Controls"**
   - Tapez "Family Controls" dans la barre de recherche
   - Double-cliquez sur "Family Controls" pour l'ajouter

6. **Xcode ajoutera automatiquement** :
   - L'entitlement `com.apple.developer.family-controls`
   - Le fichier `JusteTemps.entitlements` (si nécessaire)

### Option 2 : Ajout manuel du fichier entitlements

Si l'option 1 ne fonctionne pas, vous pouvez créer manuellement le fichier entitlements :

1. **Créez un nouveau fichier entitlements** :
   - Faites un clic droit sur le dossier "JusteTemps" dans Xcode
   - Sélectionnez "New File..."
   - Choisissez "Property List"
   - Nommez-le `JusteTemps.entitlements`

2. **Ajoutez l'entitlement** :
   - Ouvrez le fichier `JusteTemps.entitlements`
   - Ajoutez une clé `com.apple.developer.family-controls` avec la valeur `true`

3. **Configurez le fichier dans les Build Settings** :
   - Sélectionnez le target "JusteTemps"
   - Allez dans "Build Settings"
   - Recherchez "Code Signing Entitlements"
   - Ajoutez `JusteTemps/JusteTemps.entitlements` comme valeur

### Option 3 : Utiliser le fichier existant

Un fichier `JusteTemps.entitlements` a été créé à la racine du dossier `JusteTemps/`. 

Pour l'utiliser :

1. **Ajoutez-le au projet Xcode** :
   - Faites glisser le fichier `JusteTemps.entitlements` dans Xcode
   - Cochez "Copy items if needed" si nécessaire
   - Assurez-vous que le target "JusteTemps" est coché

2. **Configurez-le dans les Build Settings** :
   - Sélectionnez le target "JusteTemps"
   - Allez dans "Build Settings"
   - Recherchez "Code Signing Entitlements"
   - Entrez `JusteTemps/JusteTemps.entitlements`

## Vérification

Après avoir configuré les entitlements :

1. **Nettoyez le build** : `Product` → `Clean Build Folder` (⇧⌘K)

2. **Recompilez** : `Product` → `Build` (⌘B)

3. **Testez sur un appareil réel** (pas dans le simulateur) :
   - L'API FamilyControls ne fonctionne pas dans le simulateur
   - Vous devez tester sur un iPhone réel avec iOS 15.0 ou supérieur

## Important

- ⚠️ **L'API FamilyControls ne fonctionne PAS dans le simulateur iOS**
- ✅ **Vous DEVEZ tester sur un appareil réel**
- ✅ **L'appareil doit avoir iOS 15.0 ou supérieur**
- ✅ **L'utilisateur doit accepter l'autorisation dans les paramètres iOS**

## Après la configuration

Une fois les entitlements correctement configurés, vous devriez pouvoir :
- Demander l'autorisation Screen Time sans erreur
- Voir la popup d'autorisation système
- Accéder aux données Screen Time (si autorisé)

