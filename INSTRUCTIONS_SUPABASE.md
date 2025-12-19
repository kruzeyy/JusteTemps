# 📋 Instructions pour corriger les erreurs Supabase

## 🔴 Erreur : "Database error saving new user"

Cette erreur se produit car le trigger SQL échoue lors de la création d'un nouvel utilisateur dans `public.users`.

## ✅ Solution : Exécuter les scripts SQL dans le bon ordre

### Étape 1 : Corriger le schéma de la table

1. Allez dans **Supabase Dashboard → SQL Editor**
2. Exécutez cette commande pour corriger la table (si elle existe déjà) :

```sql
-- Supprimer la table si elle existe déjà (ATTENTION : cela supprimera les données)
DROP TABLE IF EXISTS public.users CASCADE;

-- Recréer la table avec le bon schéma
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE,
    name TEXT NOT NULL,
    auth_provider TEXT NOT NULL CHECK (auth_provider IN ('email', 'google', 'apple')),
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Recréer les index
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_auth_provider ON public.users(auth_provider);
```

### Étape 2 : Appliquer les politiques RLS

```sql
-- Activer Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes politiques si elles existent
DROP POLICY IF EXISTS "Users can read own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;

-- Recréer les politiques RLS
CREATE POLICY "Users can read own profile"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);
```

### Étape 3 : Créer les triggers

Exécutez le contenu complet de `supabase_sync_trigger.sql` dans le SQL Editor.

## 🔍 Vérification

Après avoir exécuté ces scripts :

1. Déconnectez-vous de l'application
2. Reconnectez-vous avec Google
3. Allez dans **Supabase Dashboard → Table Editor → users**
4. Vous devriez voir votre utilisateur dans la table `public.users`

## ⚠️ Notes importantes

- **La table `id` doit référencer `auth.users(id)`**, pas avoir `DEFAULT gen_random_uuid()`
- Le trigger utilise `SECURITY DEFINER` pour contourner RLS lors de l'insertion
- Les utilisateurs existants dans `auth.users` ne seront pas automatiquement ajoutés à `public.users` (seulement les nouveaux)

