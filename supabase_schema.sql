-- Script SQL pour créer la table user dans Supabase
-- Exécutez ce script dans l'éditeur SQL de votre dashboard Supabase

-- Créer la table user (si elle n'existe pas déjà)
-- IMPORTANT : id doit référencer auth.users.id, pas avoir DEFAULT gen_random_uuid()
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    name TEXT NOT NULL DEFAULT 'Utilisateur',
    auth_provider TEXT NOT NULL DEFAULT 'email' CHECK (auth_provider IN ('email', 'google', 'apple')),
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT users_email_unique UNIQUE NULLS NOT DISTINCT (email)
);

-- Créer un index sur l'email pour les recherches rapides
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Créer un index sur auth_provider
CREATE INDEX IF NOT EXISTS idx_users_auth_provider ON public.users(auth_provider);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour mettre à jour updated_at automatiquement
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Activer Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Politique RLS : Les utilisateurs peuvent lire leur propre profil
CREATE POLICY "Users can read own profile"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- Politique RLS : Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

-- Politique RLS : Les utilisateurs peuvent insérer leur propre profil
CREATE POLICY "Users can insert own profile"
    ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Commentaires pour la documentation
COMMENT ON TABLE public.users IS 'Table des utilisateurs de l''application JusteTemps';
COMMENT ON COLUMN public.users.id IS 'Identifiant unique de l''utilisateur (UUID)';
COMMENT ON COLUMN public.users.email IS 'Email de l''utilisateur (peut être null pour Apple)';
COMMENT ON COLUMN public.users.name IS 'Nom d''affichage de l''utilisateur';
COMMENT ON COLUMN public.users.auth_provider IS 'Provider d''authentification (email, google, apple)';
COMMENT ON COLUMN public.users.profile_image_url IS 'URL de l''image de profil';
COMMENT ON COLUMN public.users.created_at IS 'Date de création du compte';
COMMENT ON COLUMN public.users.updated_at IS 'Date de dernière mise à jour';

