# Configuration Apple Client ID et Secret Key pour Supabase

## Pour iOS avec Supabase

### Option 1 : Configuration minimale (Peut fonctionner sans credentials)

Pour les applications iOS natives, Supabase peut parfois fonctionner sans credentials supplémentaires. **Essayez d'abord de laisser les champs vides** et testez si cela fonctionne.

Si cela ne fonctionne pas, suivez l'Option 2.

### Option 2 : Configuration complète avec credentials

#### Étape 1 : Obtenir le Client ID (App ID)

1. **Allez sur https://developer.apple.com/account/**
   - Connectez-vous avec votre compte Apple Developer

2. **Accédez aux Identifiers**
   - Cliquez sur **"Certificates, Identifiers & Profiles"**
   - Cliquez sur **"Identifiers"** dans le menu de gauche

3. **Trouvez votre App ID**
   - Recherchez `com.justetemps.app`
   - Cliquez dessus pour voir les détails

4. **Copiez l'App ID**
   - Votre **Client ID** est : `com.justetemps.app`
   - C'est exactement votre Bundle Identifier

#### Étape 2 : Créer une Key pour générer la Secret Key

1. **Allez dans la section "Keys"**
   - Dans le menu de gauche, cliquez sur **"Keys"**
   - Cliquez sur le bouton **"+"** en haut à gauche pour créer une nouvelle clé

2. **Configurez la clé**
   - **Key Name** : Entrez un nom, par exemple "Supabase Apple Sign In"
   - **Enable "Sign in with Apple"** : Cochez cette case
   - Cliquez sur **"Continue"**
   - Cliquez sur **"Register"**

3. **Téléchargez la clé**
   - **⚠️ IMPORTANT** : Téléchargez le fichier `.p8` immédiatement
   - Vous ne pourrez plus le télécharger après avoir fermé cette page
   - **Notez le Key ID** affiché (par exemple : `ABC123DEF4`)

4. **Notez votre Team ID**
   - En haut à droite du Developer Portal, vous verrez votre **Team ID**
   - C'est une chaîne de 10 caractères (par exemple : `ABCD123456`)

#### Étape 3 : Générer la Secret Key (JWT)

1. **Allez sur l'outil de génération**
   - Ouvrez : https://applekeygen.expo.app/

2. **Remplissez le formulaire**
   - **Team ID** : Entrez votre Team ID (10 caractères)
   - **Key ID** : Entrez le Key ID noté précédemment
   - **Client ID** : Entrez `com.justetemps.app` (votre App ID)
   - **Private Key (.p8)** : Ouvrez le fichier `.p8` téléchargé et copiez son contenu complet dans ce champ

3. **Générez la clé secrète**
   - Cliquez sur **"Generate Secret"**
   - La Secret Key (JWT) sera générée

4. **Copiez la Secret Key**
   - C'est une longue chaîne commençant par `eyJ...`
   - **Copiez-la entièrement**

#### Étape 4 : Configurer dans Supabase

1. **Retournez dans le dashboard Supabase**
   - Allez sur https://supabase.com/dashboard
   - Sélectionnez votre projet
   - Allez dans **"Authentication"** → **"Providers"** → **"Apple"**

2. **Remplissez les champs**
   - **Client ID (for OAuth)** : `com.justetemps.app`
   - **Secret Key (for OAuth)** : Collez la Secret Key (JWT) générée à l'étape 3

3. **Sauvegardez**
   - Cliquez sur **"Save"**

#### Étape 5 : Tester

1. **Recompilez votre application**
2. **Réessayez de vous connecter avec Apple**
3. Cela devrait maintenant fonctionner

## Notes importantes

- ⚠️ **La Secret Key expire après 6 mois** : Vous devrez la régénérer avant expiration
- ⚠️ **Gardez le fichier .p8 en sécurité** : Vous en aurez besoin pour régénérer la clé secrète
- ⚠️ **Pour iOS**, le Client ID est votre **App ID** (Bundle Identifier), pas un Service ID
- ⚠️ Le Service ID n'est nécessaire que pour les applications web

## Alternative : Essayer sans credentials d'abord

Pour iOS, Supabase peut parfois fonctionner sans credentials supplémentaires car l'authentification se fait directement sur l'appareil. **Essayez d'abord de laisser les champs vides** dans Supabase et testez si la connexion fonctionne. Si vous obtenez toujours l'erreur "provider issuer is not enabled", alors configurez les credentials comme décrit ci-dessus.

