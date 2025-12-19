# Activation de Family Controls avec un compte Apple Developer payant

## Étapes pour activer Family Controls

### 1. Vérifier votre compte dans Xcode

1. **Ouvrez Xcode**
2. **Allez dans les préférences** : `Xcode` → `Settings` (ou `Preferences`)
3. **Onglet "Accounts"**
4. Vérifiez que votre compte Apple Developer payant est bien connecté
   - Si ce n'est pas le cas, cliquez sur "+" et ajoutez votre compte
   - Vous devrez vous connecter avec votre Apple ID associé au compte développeur payant

### 2. Sélectionner l'équipe de développement

1. **Sélectionnez le projet "JusteTemps"** dans le navigateur de projet (icône bleue en haut)
2. **Sélectionnez le target "JusteTemps"** (sous "TARGETS")
3. **Allez dans l'onglet "Signing & Capabilities"**
4. **Dans la section "Signing"**, sélectionnez votre équipe :
   - Déroulez le menu "Team"
   - Sélectionnez votre nom (ou votre équipe si vous en avez une)
   - Cela devrait maintenant afficher "Maxime Pontus (Personal Team)" OU votre équipe payante

### 3. Ajouter la capability "Family Controls"

1. **Toujours dans "Signing & Capabilities"**
2. **Cliquez sur le bouton "+ Capability"** en haut à gauche
3. **Dans la fenêtre qui s'ouvre**, recherchez "Family Controls"
   - Tapez "Family Controls" dans la barre de recherche
   - Ou faites défiler jusqu'à trouver "Family Controls"
4. **Double-cliquez sur "Family Controls"** pour l'ajouter

### 4. Vérifier que l'entitlement est présent

Après avoir ajouté la capability, vous devriez voir :
- Une section "Family Controls" dans la liste des capabilities
- L'entitlement `com.apple.developer.family-controls` devrait être présent

Si le fichier `JusteTemps.entitlements` est déjà dans votre projet, Xcode devrait le mettre à jour automatiquement avec l'entitlement.

### 5. Vérifier dans le Apple Developer Portal (optionnel mais recommandé)

1. **Allez sur** https://developer.apple.com/account/
2. **Connectez-vous** avec votre compte développeur payant
3. **Allez dans "Certificates, Identifiers & Profiles"**
4. **Sélectionnez "Identifiers"** dans le menu de gauche
5. **Trouvez votre App ID** (com.justetemps.app) et cliquez dessus
6. **Vérifiez que "Family Controls" est coché** dans les capabilities
   - Si ce n'est pas le cas, cochez-le et enregistrez

### 6. Nettoyer et reconstruire

1. **Nettoyez le build** : `Product` → `Clean Build Folder` (ou ⇧⌘K)
2. **Recompilez** : `Product` → `Build` (ou ⌘B)
3. **Si vous voyez des erreurs de provisioning**, allez dans "Signing & Capabilities" et cliquez sur "Try Again" ou "Download Manual Profiles"

### 7. Tester sur un appareil réel

⚠️ **Important** : L'API FamilyControls ne fonctionne PAS dans le simulateur.

1. **Connectez votre iPhone** à votre Mac
2. **Sélectionnez votre appareil** comme destination de build dans Xcode
3. **Lancez l'application** sur votre iPhone
4. **Testez la demande d'autorisation Screen Time**

## Vérification

Si tout est correctement configuré :
- ✅ Vous ne devriez plus voir l'erreur "Personal development teams do not support Family Controls"
- ✅ Le provisioning profile devrait être créé avec succès
- ✅ L'application devrait pouvoir demander l'autorisation Screen Time
- ✅ Vous verrez la popup système demandant l'autorisation Screen Time

## Si vous avez encore des problèmes

1. **Vérifiez que votre compte est bien un compte payant** :
   - Allez sur https://developer.apple.com/account/
   - Vérifiez votre statut d'adhésion

2. **Attendez quelques minutes** :
   - Parfois il faut attendre que les services Apple mettent à jour votre compte

3. **Déconnectez et reconnectez votre compte dans Xcode** :
   - Xcode → Settings → Accounts
   - Supprimez votre compte
   - Reconnectez-le

4. **Régénérez les certificats** :
   - Dans "Signing & Capabilities", changez le "Team" vers "None" puis remettez votre équipe
   - Xcode régénérera les certificats

