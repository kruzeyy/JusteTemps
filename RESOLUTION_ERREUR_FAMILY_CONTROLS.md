# Résolution de l'erreur "Personal development teams do not support Family Controls"

## Problème

Même après avoir payé, vous voyez toujours :
```
Cannot create a iOS App Development provisioning profile for "com.justetemps.app".
Personal development teams, including "Maxime Pontus", do not support the Family Controls (Development) capability.
```

## Causes possibles

1. **Xcode utilise encore l'ancien compte gratuit** au lieu du compte payant
2. **Le compte payant n'est pas encore activé** (peut prendre quelques heures)
3. **L'App ID n'a pas Family Controls activé** dans le Developer Portal
4. **L'équipe sélectionnée dans Xcode est incorrecte**

## Solution étape par étape

### Étape 1 : Vérifier votre compte dans le Developer Portal

1. **Allez sur** https://developer.apple.com/account/
2. **Connectez-vous** avec votre compte
3. **Vérifiez votre statut d'adhésion** :
   - Vous devriez voir "Apple Developer Program" avec un statut "Active"
   - Si vous voyez "Pending" ou "Processing", attendez que l'activation soit terminée (peut prendre jusqu'à 48h)

### Étape 2 : Vérifier et activer Family Controls dans l'App ID

1. **Dans le Developer Portal**, allez dans **"Certificates, Identifiers & Profiles"**
2. **Cliquez sur "Identifiers"** dans le menu de gauche
3. **Recherchez ou créez votre App ID** :
   - Si `com.justetemps.app` existe déjà, cliquez dessus
   - Si il n'existe pas, créez-le :
     - Cliquez sur "+" en haut à droite
     - Sélectionnez "App IDs"
     - Cliquez sur "Continue"
     - Sélectionnez "App"
     - Entrez "JusteTemps" comme description
     - Entrez `com.justetemps.app` comme Bundle ID
     - **IMPORTANT** : Cochez "Family Controls" dans les capabilities
     - Cliquez sur "Continue" puis "Register"

4. **Si l'App ID existe déjà** :
   - Cliquez sur `com.justetemps.app`
   - Vérifiez que "Family Controls" est coché
   - Si ce n'est pas le cas, cochez-le et cliquez sur "Save"
   - ⚠️ **Note** : Si l'App ID a été créé avec un compte gratuit, vous devrez peut-être le supprimer et le recréer

### Étape 3 : Vérifier votre compte dans Xcode

1. **Ouvrez Xcode**
2. **Allez dans** `Xcode` → `Settings` (ou `Preferences`)
3. **Onglet "Accounts"**
4. **Vérifiez que votre compte payant est listé** :
   - Vous devriez voir votre nom avec "(Apple Developer)" ou "(Company/Organization)"
   - Si vous voyez "(Personal Team)", c'est le compte gratuit
5. **Si vous avez deux comptes** :
   - Le compte gratuit (Personal Team)
   - Le compte payant (Apple Developer)
   - **Supprimez le compte gratuit** si vous n'en avez plus besoin :
     - Sélectionnez-le
     - Cliquez sur "-" en bas
   - **OU gardez les deux** mais assurez-vous de sélectionner le bon dans le projet

### Étape 4 : Sélectionner la bonne équipe dans le projet

1. **Dans Xcode**, sélectionnez le projet "JusteTemps"
2. **Sélectionnez le target "JusteTemps"**
3. **Allez dans "Signing & Capabilities"**
4. **Dans la section "Signing"** :
   - Déroulez le menu "Team"
   - **Sélectionnez votre équipe payante** (pas "Personal Team")
   - Vous devriez voir quelque chose comme :
     - "Maxime Pontus (Apple Developer)" OU
     - "Votre Nom (Company/Organization)"
   - **PAS** "Maxime Pontus (Personal Team)"

5. **Si vous ne voyez que "Personal Team"** :
   - Votre compte payant n'est peut-être pas encore activé
   - Ou Xcode n'a pas détecté le compte payant
   - Essayez de déconnecter et reconnecter votre compte

### Étape 5 : Ajouter la capability Family Controls

1. **Toujours dans "Signing & Capabilities"**
2. **Cliquez sur "+ Capability"**
3. **Recherchez "Family Controls"**
4. **Ajoutez-la**
5. **Si vous voyez une erreur**, cela signifie que :
   - L'App ID n'a pas Family Controls activé dans le Portal
   - OU votre compte n'est pas encore activé

### Étape 6 : Nettoyer et reconstruire

1. **Nettoyez le build** : `Product` → `Clean Build Folder` (⇧⌘K)
2. **Supprimez les anciens provisioning profiles** :
   - Allez dans `~/Library/MobileDevice/Provisioning Profiles/`
   - Supprimez les fichiers liés à `com.justetemps.app`
3. **Recompilez** : `Product` → `Build` (⌘B)
4. **Xcode devrait télécharger un nouveau provisioning profile**

## Si ça ne fonctionne toujours pas

### Option A : Attendre l'activation du compte

- L'activation d'un compte Apple Developer peut prendre **jusqu'à 48 heures**
- Vérifiez votre email pour des confirmations d'Apple
- Vérifiez le statut dans le Developer Portal

### Option B : Supprimer et recréer l'App ID

Si l'App ID a été créé avec un compte gratuit, il peut être "verrouillé" :

1. **Dans le Developer Portal**, supprimez l'App ID `com.justetemps.app`
2. **Créez-en un nouveau** avec Family Controls activé dès le départ
3. **Mettez à jour le Bundle Identifier** dans Xcode si nécessaire

### Option C : Contacter le support Apple

Si rien ne fonctionne après 48h :
- Contactez le support Apple Developer
- Expliquez que vous avez payé mais que Family Controls n'est pas disponible

## Vérification finale

Quand tout fonctionne :
- ✅ Vous ne voyez plus l'erreur "Personal development teams"
- ✅ Le provisioning profile est créé avec succès
- ✅ La capability "Family Controls" apparaît dans "Signing & Capabilities"
- ✅ Vous pouvez compiler et tester l'application

