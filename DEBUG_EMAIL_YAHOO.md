# Debug : Problème avec email Yahoo

## Problème confirmé
L'email `maxime.pontus@yahoo.com` est rejeté par Supabase avec l'erreur :
```
api(Auth.AuthError.APIError(msg: Optional("Email address \"maxime.pontus@yahoo.com\" is invalid"), code: Optional(400), ...))
```

C'est une erreur 400 de l'API Supabase qui indique que Supabase rejette explicitement cet email comme invalide.

## Cause probable
Supabase utilise une validation d'email stricte qui peut rejeter certains formats ou domaines. C'est un problème connu avec Supabase (voir https://github.com/supabase/auth/issues/2252).

## Solutions

### Solution 1 : Utiliser un autre fournisseur d'email (RECOMMANDÉ)
Testez avec un email Gmail ou Outlook pour confirmer que l'inscription fonctionne :
- `maxime.pontus@gmail.com`
- `maxime.pontus@outlook.com`

### Solution 2 : Vérifier les paramètres Supabase

Dans le dashboard Supabase :

1. **Authentication** → **Settings** → **Email Auth**
   - Vérifiez si "Enable email signup" est activé
   - Vérifiez les paramètres de validation d'email
   - Cherchez des options de "validation étendue" ou "blocklist de domaines"

2. **Authentication** → **Settings** → **URL Configuration**
   - Vérifiez que les URLs sont correctement configurées

3. **Logs** → **Auth Logs**
   - Recherchez les tentatives d'inscription avec l'email Yahoo
   - Regardez les détails de l'erreur

### Solution 3 : Contacter le support Supabase
Si vous devez absolument utiliser un email Yahoo, contactez le support Supabase :
- Forum : https://github.com/supabase/supabase/discussions
- Discord : https://discord.supabase.com

### Solution 4 : Utiliser un alias Yahoo
Essayez avec un format différent d'email Yahoo :
- `maximepontus@yahoo.com` (sans point - mais cela créera un compte différent)
- `maxime_pontus@yahoo.com` (avec underscore)

## Code modifié

J'ai ajouté :
1. ✅ Une validation d'email basique côté client avant d'envoyer à Supabase
2. ✅ Un meilleur logging pour voir l'erreur exacte
3. ✅ Des messages d'erreur plus clairs qui indiquent que Supabase rejette l'email

## Recommandation
Pour l'instant, utilisez un email Gmail ou Outlook pour tester l'application. Le problème vient de la validation de Supabase, pas de votre code.

