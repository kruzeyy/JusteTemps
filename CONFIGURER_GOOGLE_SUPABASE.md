# 🔧 Configuration Google OAuth dans Supabase

## 📍 Étape 1 : Aller dans la bonne section

Dans votre dashboard Supabase :
1. Cliquez sur **Authentication** dans le menu de gauche (icône bouclier)
2. Dans la section **CONFIGURATION**, cliquez sur **"Sign In / Providers"** (pas "OAuth Server")
3. Vous verrez la liste de tous les providers disponibles

## 🔑 Étape 2 : Configurer Google Cloud Console

Avant d'activer Google dans Supabase, vous devez créer des identifiants OAuth dans Google Cloud Console :

### 2.1 Créer un projet Google Cloud

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Donnez-lui un nom (ex: "JusteTemps")

### 2.2 Activer l'API Google+

1. Dans Google Cloud Console, allez dans **APIs & Services → Library**
2. Recherchez "Google+ API" ou "Google Identity"
3. Cliquez sur **Enable**

### 2.3 Créer des identifiants OAuth 2.0

1. Allez dans **APIs & Services → Credentials**
2. Cliquez sur **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
3. Si c'est la première fois, configurez l'écran de consentement OAuth :
   - **User Type** : External (ou Internal si vous avez un compte Google Workspace)
   - Remplissez les informations requises
   - Cliquez sur **Save and Continue**
4. Créez l'OAuth client ID :
   - **Application type** : **Web application**
   - **Name** : JusteTemps (ou votre choix)
   - **Authorized redirect URIs** : Ajoutez cette URL :
     ```
     https://wlgrhzbpzdclexucwydp.supabase.co/auth/v1/callback
     ```
     (Remplacez `wlgrhzbpzdclexucwydp` par votre Project Reference si différent)
5. Cliquez sur **Create**
6. **Copiez le Client ID et le Client Secret** (vous en aurez besoin)

## ⚙️ Étape 3 : Activer Google dans Supabase

1. Dans Supabase, allez dans **Authentication → Sign In / Providers**
2. Trouvez **"Google"** dans la liste
3. Cliquez sur **"Google"** pour ouvrir les paramètres
4. Activez le toggle **"Enable Google provider"**
5. Remplissez les champs :
   - **Client ID (for OAuth)** : Collez le Client ID de Google Cloud Console
   - **Client Secret (for OAuth)** : Collez le Client Secret de Google Cloud Console
6. Cliquez sur **"Save"**

## 🔗 Étape 4 : Configurer l'URL de redirection

1. Dans Supabase, allez dans **Authentication → URL Configuration**
2. Dans la section **"Redirect URLs"**, ajoutez :
   ```
   com.justetemps.app://auth-callback
   ```
3. Cliquez sur **"Save"**

## ✅ Étape 5 : Vérifier la configuration

Vérifiez que tout est correct :
- ✅ Google est activé dans **Sign In / Providers**
- ✅ Client ID et Client Secret sont remplis
- ✅ L'URL de redirection est ajoutée dans **URL Configuration**
- ✅ L'URL de callback dans Google Cloud Console correspond à votre projet Supabase

## 🧪 Test

1. Lancez votre application iOS
2. Cliquez sur **"Continuer avec Google"**
3. Vous devriez être redirigé vers Safari pour vous connecter avec Google
4. Après connexion, vous serez redirigé vers l'application

## 🐛 Dépannage

### "Invalid client" ou "Invalid redirect URI"
- Vérifiez que l'URL de redirection dans Google Cloud Console correspond exactement à :
  ```
  https://wlgrhzbpzdclexucwydp.supabase.co/auth/v1/callback
  ```
- Vérifiez que le Client ID et Client Secret sont corrects dans Supabase

### "Redirect URI mismatch"
- Assurez-vous que l'URL de redirection dans Google Cloud Console correspond à votre projet Supabase
- Vérifiez qu'il n'y a pas d'espaces ou de caractères supplémentaires

### Le callback ne fonctionne pas
- Vérifiez que `com.justetemps.app://auth-callback` est bien dans **URL Configuration** de Supabase
- Vérifiez que le Bundle Identifier de votre app correspond à `com.justetemps.app`

## 📝 Notes importantes

- Le **Client Secret** doit rester secret - ne le partagez jamais publiquement
- L'URL de callback dans Google Cloud Console doit correspondre exactement à votre URL Supabase
- Vous pouvez avoir plusieurs redirect URIs dans Google Cloud Console si nécessaire

