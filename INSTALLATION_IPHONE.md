# 📱 Installer JusteTemps sur votre iPhone

## Méthode 1 : Installation directe depuis Xcode (Recommandée)

### Prérequis
- Un iPhone avec iOS 17.0 ou supérieur
- Un câble USB (ou connexion WiFi)
- Un compte Apple ID (gratuit)
- Xcode installé sur votre Mac

### Étapes

#### 1. Connecter votre iPhone
- Connectez votre iPhone à votre Mac avec un câble USB
- Sur votre iPhone, si une alerte apparaît, appuyez sur **"Faire confiance à cet ordinateur"**
- Entrez votre code de déverrouillage si demandé

#### 2. Configurer le code signing dans Xcode
1. Ouvrez le projet `JusteTemps.xcodeproj` dans Xcode
2. Dans le navigateur de projet (panneau de gauche), cliquez sur le projet **"JusteTemps"** (icône bleue en haut)
3. Sous **"TARGETS"**, sélectionnez **"JusteTemps"**
4. Allez dans l'onglet **"Signing & Capabilities"**
5. Cochez **"Automatically manage signing"**
6. Dans **"Team"**, sélectionnez votre compte Apple ID
   - Si vous n'avez pas de team, cliquez sur **"Add Account..."**
   - Connectez-vous avec votre Apple ID
   - Xcode créera automatiquement un certificat de développement

#### 3. Sélectionner votre iPhone comme destination
1. En haut de Xcode, à côté du bouton Play (▶️), cliquez sur le menu déroulant
2. Sélectionnez votre iPhone dans la liste des appareils
   - Il devrait apparaître comme "iPhone de [Votre Nom]"
   - Si vous ne le voyez pas, assurez-vous qu'il est bien connecté et déverrouillé

#### 4. Installer l'application
1. Cliquez sur le bouton **Play** (▶️) ou appuyez sur **⌘R**
2. Xcode va :
   - Compiler l'application
   - L'installer sur votre iPhone
   - La lancer automatiquement

#### 5. Faire confiance au développeur (première fois seulement)
- Sur votre iPhone, allez dans **Réglages → Général → Gestion des appareils**
- Appuyez sur votre profil de développeur
- Appuyez sur **"Faire confiance [Votre Nom]"**
- Confirmez avec **"Faire confiance"**

#### 6. Lancer l'application
- L'application devrait maintenant s'ouvrir sur votre iPhone
- Si elle ne s'ouvre pas automatiquement, cherchez l'icône "JusteTemps" sur votre écran d'accueil

---

## Méthode 2 : Installation via WiFi (Sans câble)

### Prérequis
- Votre iPhone et votre Mac doivent être sur le même réseau WiFi
- Vous devez avoir connecté votre iPhone au moins une fois via USB

### Étapes

1. **Connecter une première fois via USB** (pour activer le mode WiFi)
   - Suivez les étapes 1-4 de la Méthode 1

2. **Activer le mode WiFi dans Xcode**
   - Dans Xcode, allez dans **Window → Devices and Simulators** (ou **⌘⇧2**)
   - Sélectionnez votre iPhone
   - Cochez **"Connect via network"**

3. **Déconnecter le câble USB**
   - Vous pouvez maintenant déconnecter votre iPhone
   - Il apparaîtra toujours dans Xcode avec une icône WiFi

4. **Installer via WiFi**
   - Sélectionnez votre iPhone (avec l'icône WiFi) comme destination
   - Cliquez sur Play (▶️)
   - L'application s'installera via WiFi

---

## Méthode 3 : TestFlight (Pour tester avec d'autres personnes)

### Prérequis
- Un compte développeur Apple (99$/an) - **PAS GRATUIT**
- L'application doit être archivée et uploadée sur App Store Connect

### Étapes (si vous avez un compte développeur)

1. **Archiver l'application**
   - Dans Xcode : **Product → Archive**
   - Attendez la fin de l'archivage

2. **Distribuer via TestFlight**
   - Dans la fenêtre Organizer, cliquez sur **"Distribute App"**
   - Sélectionnez **"App Store Connect"**
   - Suivez les étapes pour uploader

3. **Configurer sur App Store Connect**
   - Allez sur https://appstoreconnect.apple.com
   - Créez une version de test
   - Ajoutez des testeurs

4. **Installer TestFlight sur iPhone**
   - Téléchargez TestFlight depuis l'App Store
   - Acceptez l'invitation de test
   - Installez l'application depuis TestFlight

---

## ⚠️ Limitations importantes

### Avec un compte Apple ID gratuit :
- ✅ Vous pouvez installer sur votre propre iPhone
- ✅ L'application fonctionne pendant 7 jours
- ⚠️ Après 7 jours, vous devez reconnecter votre iPhone et réinstaller
- ❌ Vous ne pouvez pas distribuer à d'autres personnes
- ❌ L'application expire après 7 jours

### Avec un compte développeur payant (99$/an) :
- ✅ Installation illimitée
- ✅ Distribution via TestFlight
- ✅ Publication sur l'App Store
- ✅ Pas d'expiration

---

## 🔧 Dépannage

### "No devices found"
- Vérifiez que votre iPhone est déverrouillé
- Vérifiez que vous avez fait confiance à l'ordinateur
- Essayez de débrancher et rebrancher le câble

### "Signing error"
- Vérifiez que "Automatically manage signing" est coché
- Vérifiez que votre Team est sélectionnée
- Essayez de nettoyer le projet : **Product → Clean Build Folder** (⇧⌘K)

### "Unable to install"
- Vérifiez que votre iPhone a iOS 17.0 ou supérieur
- Vérifiez que vous avez fait confiance au développeur dans Réglages
- Réessayez après avoir redémarré Xcode

### L'application ne s'ouvre pas
- Allez dans Réglages → Général → Gestion des appareils
- Vérifiez que vous avez fait confiance au développeur
- Supprimez et réinstallez l'application

---

## 📝 Notes importantes

1. **Première installation** : L'application doit être signée avec votre Apple ID
2. **Expiration** : Avec un compte gratuit, l'application expire après 7 jours
3. **Renouvellement** : Reconnectez votre iPhone et réinstallez pour renouveler
4. **Données** : Les données de l'application sont sauvegardées localement sur votre iPhone

---

## 🎉 C'est prêt !

Une fois installée, vous pouvez utiliser JusteTemps sur votre iPhone comme n'importe quelle autre application !

