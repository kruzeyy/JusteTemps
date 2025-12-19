# Activer Sign in with Apple dans Supabase

## Erreur rencontrée
```
Erreur lors de la connexion Apple: provider issuer https://appleid.apple.com is not enabled
```

Cette erreur signifie que le provider Apple n'est pas activé dans votre projet Supabase.

## Solution : Activer Apple dans Supabase

### Étape 1 : Accéder à la configuration d'authentification

1. **Allez sur votre dashboard Supabase**
   - Ouvrez https://supabase.com/dashboard
   - Connectez-vous avec votre compte

2. **Sélectionnez votre projet**
   - Cliquez sur le projet "JusteTemps" (ou votre projet avec l'URL `wlgrhzbpzdclexucwydp.supabase.co`)

3. **Accédez à Authentication**
   - Dans le menu de gauche, cliquez sur **"Authentication"**
   - Cliquez sur **"Providers"** dans le sous-menu

### Étape 2 : Activer Apple

1. **Trouvez "Apple" dans la liste des providers**
   - Faites défiler jusqu'à trouver **"Apple"** dans la liste
   - Ou utilisez la barre de recherche en haut

2. **Activez le provider**
   - **Basculez l'interrupteur** à côté de "Apple" pour l'activer (il doit passer de gris à vert/bleu)

3. **Configurez Apple (si nécessaire)**
   - Supabase devrait automatiquement détecter les paramètres nécessaires
   - Si des champs sont requis, laissez les valeurs par défaut pour l'instant

4. **Sauvegardez**
   - Cliquez sur **"Save"** en bas de la page

### Étape 3 : Vérifier la configuration

Assurez-vous que :
- ✅ Apple est **activé** (interrupteur vert/bleu)
- ✅ Le provider est **enregistré** (message de confirmation)

### Étape 4 : Tester à nouveau

1. **Recompilez votre application** (si nécessaire)
2. **Réessayez de vous connecter avec Apple**
3. L'erreur devrait disparaître

## Note importante

Supabase utilise automatiquement les credentials Apple pour l'authentification. Vous n'avez généralement pas besoin de configurer de clés supplémentaires pour Sign in with Apple avec Supabase - il suffit d'activer le provider.

## Si l'erreur persiste

Si vous avez toujours l'erreur après avoir activé Apple dans Supabase :

1. **Attendez quelques secondes** après l'activation (la configuration peut prendre un moment à se propager)

2. **Vérifiez que vous êtes bien connecté au bon projet Supabase**
   - L'URL dans votre code devrait correspondre à votre projet
   - Vérifiez dans `SupabaseManager.swift` ou `Info.plist`

3. **Vérifiez les logs Supabase**
   - Dans le dashboard Supabase, allez dans **"Logs"** → **"Auth"**
   - Vérifiez s'il y a d'autres erreurs liées à Apple

