# Configuration de l'authentification

## ✅ Sign in with Apple

Sign in with Apple est déjà configuré et fonctionne nativement sur iOS. Aucune configuration supplémentaire n'est nécessaire.

## 🔧 Configuration Google Sign-In

Pour activer la connexion Google, suivez ces étapes :

### 1. Ajouter le package GoogleSignIn

1. Dans Xcode, allez dans **File → Add Package Dependencies...**
2. Entrez l'URL : `https://github.com/google/GoogleSignIn-iOS`
3. Sélectionnez la version la plus récente
4. Ajoutez le package à votre target "JusteTemps"

### 2. Configurer Google Cloud Console

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez l'API "Google Sign-In"
4. Créez des identifiants OAuth 2.0 :
   - Type : iOS
   - Bundle ID : `com.justetemps.app`
   - Téléchargez le fichier `GoogleService-Info.plist`

### 3. Configurer l'application

1. Ajoutez le `GoogleService-Info.plist` à votre projet Xcode
2. Dans `Info.plist`, remplacez `VOTRE_CLIENT_ID_GOOGLE` par votre Client ID Google
3. Dans `AuthManager.swift`, décommentez :
   - L'import `import GoogleSignIn`
   - Le code dans la fonction `signInWithGoogle()`
   - Le code dans la fonction `signOut()`

### 4. Configurer l'URL Scheme

L'URL scheme est déjà configuré dans `Info.plist`. Assurez-vous que le Bundle Identifier correspond à votre configuration Google.

## 📧 Authentification par Email

L'authentification par email est actuellement simulée. Pour une vraie authentification :

### Option 1 : Firebase Authentication

1. Créez un projet Firebase
2. Activez Authentication → Email/Password
3. Ajoutez le SDK Firebase à votre projet
4. Remplacez les fonctions `signInWithEmail` et `signUpWithEmail` dans `AuthManager.swift`

### Option 2 : Backend personnalisé

1. Créez votre propre API backend
2. Implémentez les endpoints d'authentification
3. Remplacez les fonctions dans `AuthManager.swift` pour appeler votre API

## 🚀 Test rapide

Pour tester sans configuration Google :

1. Utilisez **Sign in with Apple** (fonctionne immédiatement)
2. Utilisez **Email** (simulation - accepte n'importe quel email/mot de passe)
3. Le bouton **Google** fonctionnera en mode simulation jusqu'à ce que vous ajoutiez le package

## 📝 Notes

- Sign in with Apple fonctionne immédiatement sans configuration
- L'authentification email est simulée pour la démonstration
- Google Sign-In nécessite la configuration ci-dessus

