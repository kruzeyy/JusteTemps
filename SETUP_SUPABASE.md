# 🔧 Configuration Supabase pour JusteTemps

## 📋 Prérequis

1. Un compte Supabase (gratuit) : https://supabase.com
2. Un projet Supabase créé

## 🚀 Étapes de configuration

### 1. Créer un projet Supabase

1. Allez sur https://supabase.com
2. Créez un compte ou connectez-vous
3. Cliquez sur **"New Project"**
4. Remplissez les informations :
   - **Name** : JusteTemps (ou votre choix)
   - **Database Password** : Choisissez un mot de passe fort
   - **Region** : Choisissez la région la plus proche
5. Cliquez sur **"Create new project"**
6. Attendez que le projet soit créé (2-3 minutes)

### 2. Récupérer les clés API

1. Dans votre projet Supabase, allez dans **Settings → API**
2. Vous verrez :
   - **Project URL** : Copiez cette URL
   - **anon public key** : Copiez cette clé

### 3. Configurer l'authentification dans Supabase

#### Activer les providers d'authentification

1. Allez dans **Authentication → Providers**
2. Activez les providers suivants :

#### Email/Password
- ✅ Cochez **"Enable Email provider"**
- ✅ Cochez **"Confirm email"** (optionnel, pour la sécurité)
- Cliquez sur **"Save"**

#### Google OAuth
1. Cliquez sur **"Google"**
2. Activez le provider
3. Vous devez créer des identifiants OAuth dans Google Cloud Console :
   - Allez sur https://console.cloud.google.com
   - Créez un projet ou sélectionnez-en un
   - Activez l'API "Google+ API"
   - Créez des identifiants OAuth 2.0 :
     - Type : **Web application**
     - Authorized redirect URIs : 
       ```
       https://VOTRE_PROJECT_REF.supabase.co/auth/v1/callback
       ```
       (Remplacez VOTRE_PROJECT_REF par votre référence de projet Supabase)
   - Copiez le **Client ID** et **Client Secret**
4. Dans Supabase, collez le **Client ID** et **Client Secret**
5. Cliquez sur **"Save"**

#### Apple OAuth
1. Cliquez sur **"Apple"**
2. Activez le provider
3. Vous devez créer un Service ID dans Apple Developer :
   - Allez sur https://developer.apple.com/account
   - Créez un **Service ID**
   - Configurez les **Return URLs** :
     ```
     https://VOTRE_PROJECT_REF.supabase.co/auth/v1/callback
     ```
   - Créez une **Key** pour l'authentification
   - Téléchargez la clé et notez le **Key ID**
4. Dans Supabase, remplissez :
   - **Services ID**
   - **Secret Key** (contenu du fichier .p8)
   - **Key ID**
   - **Team ID** (trouvable dans votre compte Apple Developer)
5. Cliquez sur **"Save"**

### 4. Configurer l'URL de redirection

1. Allez dans **Authentication → URL Configuration**
2. Dans **Redirect URLs**, ajoutez :
   ```
   com.justetemps.app://auth-callback
   ```
3. Cliquez sur **"Save"**

### 5. Configurer l'application iOS

1. Ouvrez `JusteTemps/Info.plist` dans Xcode
2. Remplacez les valeurs suivantes :
   ```xml
   <key>SUPABASE_URL</key>
   <string>https://VOTRE_PROJECT_REF.supabase.co</string>
   <key>SUPABASE_ANON_KEY</key>
   <string>VOTRE_ANON_KEY_ICI</string>
   ```
3. Remplacez :
   - `VOTRE_PROJECT_REF` par votre référence de projet Supabase
   - `VOTRE_ANON_KEY_ICI` par votre clé anon publique

### 6. Ajouter le package Supabase à Xcode

1. Dans Xcode, allez dans **File → Add Package Dependencies...**
2. Entrez l'URL : `https://github.com/supabase/supabase-swift`
3. Sélectionnez la version la plus récente
4. Ajoutez le package à votre target "JusteTemps"

### 7. Vérifier la configuration

1. Compilez et lancez l'application
2. Testez la connexion avec email
3. Testez la connexion avec Google
4. Testez la connexion avec Apple

## 🔍 Vérification dans Supabase

Après une connexion réussie, vous pouvez voir l'utilisateur dans :
- **Authentication → Users**

## 📝 Notes importantes

### Sécurité
- Ne commitez **JAMAIS** vos clés Supabase dans Git
- Utilisez des variables d'environnement pour la production
- La clé `anon` est publique mais sécurisée par les Row Level Security (RLS)

### Base de données
- Supabase crée automatiquement une table `auth.users` pour les utilisateurs
- Vous pouvez créer vos propres tables pour stocker des données supplémentaires
- Utilisez les **Row Level Security (RLS)** pour sécuriser vos données

### Email de confirmation
- Si vous activez "Confirm email", les utilisateurs devront vérifier leur email
- Vous pouvez désactiver cette option pour les tests

## 🐛 Dépannage

### "Supabase n'est pas configuré"
- Vérifiez que `SUPABASE_URL` et `SUPABASE_ANON_KEY` sont dans `Info.plist`
- Vérifiez que les valeurs sont correctes (sans espaces)

### "Erreur de connexion"
- Vérifiez que le provider est activé dans Supabase
- Vérifiez que l'URL de redirection est correctement configurée
- Vérifiez les logs dans Supabase Dashboard → Logs

### "Callback OAuth failed"
- Vérifiez que l'URL scheme `com.justetemps.app` est dans `Info.plist`
- Vérifiez que l'URL de redirection est ajoutée dans Supabase

## 📚 Ressources

- Documentation Supabase : https://supabase.com/docs
- Documentation Supabase Swift : https://github.com/supabase/supabase-swift
- Guide d'authentification : https://supabase.com/docs/guides/auth

