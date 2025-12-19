-- Script SQL complet pour corriger les erreurs Supabase
-- Exécutez ce script dans Supabase Dashboard → SQL Editor

-- ÉTAPE 1 : Supprimer la table existante (ATTENTION : supprime les données)
DROP TABLE IF EXISTS public.users CASCADE;

-- ÉTAPE 2 : Créer la table avec le bon schéma
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    name TEXT NOT NULL DEFAULT 'Utilisateur',
    auth_provider TEXT NOT NULL DEFAULT 'email' CHECK (auth_provider IN ('email', 'google', 'apple')),
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT users_email_unique UNIQUE NULLS NOT DISTINCT (email)
);

-- ÉTAPE 3 : Créer les index
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_auth_provider ON public.users(auth_provider);

-- ÉTAPE 4 : Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ÉTAPE 5 : Trigger pour updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ÉTAPE 6 : Activer RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- ÉTAPE 7 : Supprimer les anciennes politiques
DROP POLICY IF EXISTS "Users can read own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;

-- ÉTAPE 8 : Recréer les politiques RLS
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

-- ÉTAPE 9 : Fonction pour créer automatiquement un profil lors de la création d'un utilisateur
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_name TEXT;
    user_provider TEXT;
BEGIN
    -- Déterminer le nom de l'utilisateur
    user_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        CASE 
            WHEN NEW.email IS NOT NULL THEN SPLIT_PART(NEW.email, '@', 1)
            ELSE 'Utilisateur'
        END,
        'Utilisateur'
    );
    
    -- Déterminer le provider depuis app_metadata ou identities
    user_provider := COALESCE(
        NEW.app_metadata->>'provider',
        (SELECT provider FROM auth.identities WHERE user_id = NEW.id LIMIT 1),
        'email'
    );
    
    -- S'assurer que le provider est valide
    IF user_provider NOT IN ('email', 'google', 'apple') THEN
        user_provider := 'email';
    END IF;
    
    -- Insérer dans public.users
    INSERT INTO public.users (id, email, name, auth_provider, profile_image_url)
    VALUES (
        NEW.id,
        NEW.email,
        user_name,
        user_provider,
        COALESCE(
            NEW.raw_user_meta_data->>'avatar_url',
            NEW.raw_user_meta_data->>'picture'
        )
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        name = EXCLUDED.name,
        auth_provider = EXCLUDED.auth_provider,
        profile_image_url = COALESCE(EXCLUDED.profile_image_url, public.users.profile_image_url),
        updated_at = now();
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- En cas d'erreur, logger et continuer
        RAISE WARNING 'Erreur lors de la création du profil utilisateur: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- ÉTAPE 10 : Trigger pour créer automatiquement le profil
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ÉTAPE 11 : Fonction pour mettre à jour le profil lors de la mise à jour de l'utilisateur
CREATE OR REPLACE FUNCTION public.handle_user_update()
RETURNS TRIGGER AS $$
DECLARE
    user_name TEXT;
BEGIN
    -- Déterminer le nom de l'utilisateur
    user_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        (SELECT name FROM public.users WHERE id = NEW.id)
    );
    
    -- Mettre à jour dans public.users
    UPDATE public.users
    SET
        email = NEW.email,
        name = COALESCE(user_name, users.name),
        profile_image_url = COALESCE(
            NEW.raw_user_meta_data->>'avatar_url',
            NEW.raw_user_meta_data->>'picture',
            users.profile_image_url
        ),
        updated_at = now()
    WHERE id = NEW.id;
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Erreur lors de la mise à jour du profil utilisateur: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- ÉTAPE 12 : Trigger pour mettre à jour automatiquement le profil
DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
CREATE TRIGGER on_auth_user_updated
    AFTER UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_user_update();

-- Vérification : Afficher un message de succès
DO $$
BEGIN
    RAISE NOTICE 'Script exécuté avec succès! Les triggers sont maintenant actifs.';
END $$;

