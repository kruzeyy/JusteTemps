# Solution : Sign in with Apple - Méthode alternative

## Problème
La capability "Sign in with Apple" n'apparaît pas dans la liste des capabilities de Xcode.

## Solution : L'entitlement est déjà ajouté

J'ai déjà ajouté l'entitlement `com.apple.developer.applesignin` dans le fichier `JusteTemps.entitlements`. C'est suffisant ! Vous n'avez pas besoin de l'ajouter via l'interface Xcode si l'entitlement est déjà dans le fichier.

## Étapes à suivre

### Étape 1 : Vérifier que l'entitlement est présent

Le fichier `JusteTemps.entitlements` contient déjà :
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

✅ C'est fait ! L'entitlement est déjà là.

### Étape 2 : Activer dans le Apple Developer Portal (IMPORTANT)

**C'est la partie la plus importante !**

1. **Allez sur https://developer.apple.com/account/**
   - Connectez-vous avec votre compte Apple Developer (payant)

2. **Accédez aux Identifiers**
   - Dans le menu de gauche, cliquez sur **"Certificates, Identifiers & Profiles"**
   - Cliquez sur **"Identifiers"** dans le menu de gauche

3. **Sélectionnez votre App ID**
   - Recherchez `com.justetemps.app` dans la liste
   - Cliquez dessus pour l'éditer

4. **Activez Sign in with Apple**
   - Faites défiler jusqu'à **"Sign in with Apple"**
   - **Cochez la case** à côté de "Sign in with Apple"
   - Cliquez sur le bouton **"Configure"** à droite
   - Dans la fenêtre qui s'ouvre :
     - Sélectionnez **"Enable as a primary App ID"**
     - Cliquez sur **"Save"**
   - Cliquez sur **"Continue"**
   - Cliquez sur **"Register"** pour enregistrer les modifications

### Étape 3 : Régénérer le provisioning profile

Après avoir activé dans le Developer Portal :

1. **Dans Xcode**
   - Ouvrez votre projet
   - Sélectionnez le target **"JusteTemps"**
   - Allez dans l'onglet **"Signing & Capabilities"**
   - **Décochez** "Automatically manage signing"
   - Attendez 2-3 secondes
   - **Recochez** "Automatically manage signing"
   - Sélectionnez votre équipe (votre compte Apple Developer)

2. **Ou téléchargez manuellement**
   - Dans Xcode : `Xcode → Settings → Accounts`
   - Sélectionnez votre compte Apple Developer
   - Cliquez sur **"Download Manual Profiles"**

### Étape 4 : Nettoyer et reconstruire

1. **Nettoyez le build**
   - `Product → Clean Build Folder` (⇧⌘K)

2. **Fermez Xcode**

3. **Supprimez le cache**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/JusteTemps-*
   ```

4. **Rouvrez Xcode**

5. **Recompilez et réinstallez**
   - `Product → Build` (⌘B)
   - `Product → Run` (⌘R) sur votre appareil

### Étape 5 : Vérifier dans Xcode (optionnel)

Après avoir régénéré le provisioning profile, Xcode devrait automatiquement reconnaître l'entitlement. Vous pouvez vérifier :

1. Sélectionnez le target **"JusteTemps"**
2. Allez dans **"Signing & Capabilities"**
3. Vous devriez maintenant voir **"Sign in with Apple"** dans la liste des capabilities (si elle n'y était pas avant)

**Mais ce n'est pas obligatoire !** Si l'entitlement est dans le fichier `.entitlements` et qu'il est activé dans le Developer Portal, cela fonctionnera.

## Vérification finale

Pour vérifier que tout est correctement configuré :

1. ✅ L'entitlement `com.apple.developer.applesignin` est présent dans `JusteTemps.entitlements` → **FAIT**
2. ✅ Sign in with Apple est activé dans le Developer Portal pour `com.justetemps.app` → **À FAIRE**
3. ✅ Le provisioning profile est régénéré → **À FAIRE après l'étape 2**
4. ✅ L'application est recompilée et réinstallée → **À FAIRE**

## Note importante

- ⚠️ **Sign in with Apple nécessite un compte Apple Developer payant** ($99/an)
- ⚠️ **Vous devez activer dans le Developer Portal** pour que cela fonctionne
- ⚠️ **Testez sur un appareil réel** (ne fonctionne pas dans le simulateur pour la première authentification)

Une fois ces étapes terminées, Sign in with Apple devrait fonctionner dans votre application !

