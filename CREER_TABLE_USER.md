# 📊 Créer la table user dans Supabase

## 🎯 Objectif

Créer une table `users` dans votre base de données Supabase pour stocker les informations des utilisateurs de l'application JusteTemps.

## 📋 Étapes pour créer la table

### 1. Accéder à l'éditeur SQL de Supabase

1. Allez sur votre dashboard Supabase : https://wlgrhzbpzdclexucwydp.supabase.co
2. Connectez-vous avec vos identifiants
3. Dans le menu de gauche, cliquez sur **"SQL Editor"** (ou "Éditeur SQL")

### 2. Exécuter le script SQL

1. Cliquez sur **"New query"** (Nouvelle requête)
2. Copiez-collez le contenu du fichier `supabase_schema.sql`
3. Cliquez sur **"Run"** (Exécuter) ou appuyez sur `⌘Enter`

### 3. Vérifier la création

1. Dans le menu de gauche, allez dans **"Table Editor"**
2. Vous devriez voir la table **"users"** dans la liste
3. Cliquez dessus pour voir sa structure

## 📊 Structure de la table

La table `users` contient les colonnes suivantes :

- **id** (UUID) : Identifiant unique (généré automatiquement)
- **email** (TEXT) : Email de l'utilisateur (unique, peut être null)
- **name** (TEXT) : Nom d'affichage (obligatoire)
- **auth_provider** (TEXT) : Provider d'authentification ('email', 'google', 'apple')
- **profile_image_url** (TEXT) : URL de l'image de profil (optionnel)
- **created_at** (TIMESTAMP) : Date de création (automatique)
- **updated_at** (TIMESTAMP) : Date de mise à jour (automatique)

## 🔒 Sécurité (Row Level Security)

La table utilise **Row Level Security (RLS)** pour sécuriser les données :

- ✅ Les utilisateurs peuvent **lire** leur propre profil
- ✅ Les utilisateurs peuvent **mettre à jour** leur propre profil
- ✅ Les utilisateurs peuvent **créer** leur propre profil
- ❌ Les utilisateurs **ne peuvent pas** voir ou modifier les profils des autres

## 🔄 Synchronisation avec auth.users

**Note importante** : Supabase a déjà une table `auth.users` pour l'authentification. La table `public.users` que nous créons est pour stocker des données supplémentaires.

### Option 1 : Utiliser uniquement auth.users (Recommandé pour commencer)

Supabase stocke déjà les utilisateurs dans `auth.users`. Vous pouvez utiliser cette table directement sans créer une table supplémentaire.

### Option 2 : Synchroniser avec auth.users (Si vous avez besoin de données supplémentaires)

Si vous voulez synchroniser automatiquement, vous pouvez créer un trigger :

```sql
-- Fonction pour synchroniser auth.users avec public.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name, auth_provider)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', NEW.email),
        COALESCE(NEW.app_metadata->>'provider', 'email')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer automatiquement un profil dans public.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
```

## 📝 Utilisation dans l'application

Une fois la table créée, vous pouvez l'utiliser dans votre code Swift :

```swift
// Exemple : Récupérer les données utilisateur depuis la table
let response = try await client
    .from("users")
    .select()
    .eq("id", value: userId)
    .execute()
```

## ✅ Vérification

Pour vérifier que tout fonctionne :

1. Créez un compte dans l'application
2. Allez dans Supabase → Table Editor → users
3. Vous devriez voir votre utilisateur dans la table

## 🐛 Dépannage

### "relation already exists"
- La table existe déjà, c'est normal
- Vous pouvez la supprimer et la recréer si nécessaire

### "permission denied"
- Vérifiez que vous êtes connecté avec un compte administrateur
- Vérifiez les politiques RLS

### "column does not exist"
- Vérifiez que vous avez exécuté tout le script
- Vérifiez l'orthographe des noms de colonnes

