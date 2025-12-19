# ✅ Vérifier la configuration Supabase pour éviter localhost

## 🔍 Problème : "localhost is currently unreachable"

Si vous voyez cette erreur après avoir choisi votre compte Google, c'est que Supabase essaie de rediriger vers localhost au lieu de votre application iOS.

## 📋 Vérifications à faire dans Supabase

### 1. Vérifier le Site URL

1. Dans Supabase Dashboard, allez dans **Authentication → URL Configuration**
2. Vérifiez le champ **"Site URL"** :
   - ❌ **NE DOIT PAS être** : `http://localhost:3000` ou similaire
   - ✅ **DOIT être** : Votre domaine de production OU l'URL de votre projet Supabase
   - Exemple : `https://wlgrhzbpzdclexucwydp.supabase.co`
   
3. Si c'est localhost, changez-le et cliquez sur **"Save"**

### 2. Vérifier les Redirect URLs

1. Toujours dans **Authentication → URL Configuration**
2. Dans la section **"Redirect URLs"**, vous devez avoir :
   ```
   com.justetemps.app://auth-callback
   ```
3. Si elle n'y est pas, ajoutez-la et cliquez sur **"Save"**

### 3. Vérifier la configuration Google

1. Allez dans **Authentication → Sign In / Providers → Google**
2. Vérifiez que :
   - ✅ Le toggle "Enable Sign in with Google" est activé
   - ✅ Le Client ID est rempli (celui de votre client Web)
   - ✅ Le Client Secret est rempli
3. Le "Callback URL" affiché doit être :
   ```
   https://wlgrhzbpzdclexucwydp.supabase.co/auth/v1/callback
   ```

## 🔧 Solution recommandée pour le Site URL

Pour une application iOS, vous pouvez mettre :
- Option 1 : L'URL de votre projet Supabase
  ```
  https://wlgrhzbpzdclexucwydp.supabase.co
  ```
- Option 2 : Une URL de votre domaine (si vous en avez une)

**Important** : Ne laissez pas `http://localhost:3000` car cela causera des problèmes de redirection sur mobile.

## ✅ Après avoir modifié

1. Attendez 1-2 minutes pour que les changements soient pris en compte
2. Réessayez la connexion Google dans votre application
3. L'erreur "localhost is currently unreachable" devrait disparaître

