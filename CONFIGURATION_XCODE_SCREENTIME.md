# Configuration Xcode pour Screen Time (Family Controls)

## Étapes de configuration

### 1. Activer la capability "Family Controls"

1. Ouvrez votre projet dans Xcode
2. Sélectionnez le target "JusteTemps" dans le navigateur de projet
3. Allez dans l'onglet **"Signing & Capabilities"**
4. Cliquez sur **"+ Capability"**
5. Recherchez et ajoutez **"Family Controls"**
6. Xcode ajoutera automatiquement l'entitlement `com.apple.developer.family-controls`

### 2. Vérifier les frameworks

Assurez-vous que les frameworks suivants sont liés dans votre projet :
- `FamilyControls.framework`
- `DeviceActivity.framework`
- `ManagedSettings.framework`

Ces frameworks sont déjà importés dans le code, mais vous devez vous assurer qu'ils sont bien liés au target.

### 3. Configuration requise

- **iOS 15.0+** : L'API FamilyControls nécessite iOS 15.0 ou supérieur
- **Configuration du bundle identifier** : Doit être configuré correctement

### 4. Test sur un appareil réel

⚠️ **Important** : L'API FamilyControls ne fonctionne pas dans le simulateur iOS. Vous devez tester sur un **appareil réel**.

### 5. Première exécution

Lors de la première exécution :
1. L'application demandera l'autorisation Screen Time
2. L'utilisateur devra accepter dans les paramètres iOS
3. Une fois autorisé, l'application pourra surveiller l'activité

## Notes importantes

- L'autorisation Screen Time est une autorisation système qui ne peut être accordée que par l'utilisateur dans les paramètres iOS
- Si l'utilisateur refuse l'autorisation, l'application utilisera des données simulées
- Les données réelles seront collectées progressivement après l'autorisation

