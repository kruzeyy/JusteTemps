-- Script optionnel : Synchroniser automatiquement auth.users avec public.users
-- Exécutez ce script APRÈS avoir créé la table users

-- Fonction pour synchroniser auth.users avec public.users lors de la création
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
    
    -- Déterminer le provider
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
        -- En cas d'erreur, logger et continuer (ne pas bloquer la création de l'utilisateur dans auth.users)
        RAISE WARNING 'Erreur lors de la création du profil utilisateur: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

-- Trigger pour créer automatiquement un profil dans public.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Fonction pour mettre à jour public.users quand auth.users est mis à jour
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

-- Trigger pour mettre à jour automatiquement public.users
DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
CREATE TRIGGER on_auth_user_updated
    AFTER UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_user_update();

