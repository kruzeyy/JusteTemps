# 🔧 Solution pour l'erreur "not a valid pkce flow url"

## 🔍 Le problème

L'erreur "not a valid pkce flow url" indique que Supabase ne peut pas valider le flux PKCE. Cela se produit généralement parce que :

1. Le callback passe directement vers l'app sans passer par Supabase
2. Les paramètres PKCE ne sont pas correctement stockés/gérés
3. Le flux OAuth n'est pas complété correctement

## ✅ Solution recommandée

Le flux correct devrait être :
1. App ouvre `/auth/v1/authorize?provider=google&redirect_to=com.justetemps.app://auth-callback`
2. Supabase génère les paramètres PKCE et redirige vers Google
3. Google authentifie l'utilisateur et redirige vers `/auth/v1/callback` (Supabase)
4. Supabase échange le code, crée la session, et redirige vers `com.justetemps.app://auth-callback?code=...`
5. L'app reçoit le callback et vérifie la session

## 🔧 Vérifications à faire

### 1. Dans Supabase Dashboard

Vérifiez que :
- ✅ **Authentication → URL Configuration → Redirect URLs** contient : `com.justetemps.app://auth-callback`
- ✅ **Authentication → URL Configuration → Site URL** n'est PAS `localhost`
- ✅ **Authentication → Sign In / Providers → Google** est activé avec Client ID et Secret

### 2. Test alternatif

Si l'erreur persiste, essayez de :
1. Utiliser l'URL de callback Supabase comme redirect_to temporairement pour tester
2. Vérifier les logs Supabase Dashboard → Logs pour voir les erreurs détaillées

### 3. Alternative : Utiliser directement l'API Supabase

Si le problème persiste, il faudra peut-être utiliser une méthode différente qui génère l'URL OAuth via l'API Supabase plutôt que de la construire manuellement.

