import Foundation
import SwiftUI
import AuthenticationServices
import Supabase
import UIKit
// import GoogleSignIn  // Décommentez après avoir ajouté le package GoogleSignIn

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared
    private let userDefaults = UserDefaults.standard
    private let authKey = "isAuthenticated"
    private let userKey = "currentUser"
    
    init() {
        checkAuthenticationStatus()
        setupAuthListener()
    }
    
    // Écouter les changements d'authentification Supabase
    private func setupAuthListener() {
        guard let client = supabase.getClient() else { return }
        
        Task {
            for await (event, _) in await client.auth.authStateChanges {
                switch event {
                case .initialSession, .signedIn:
                    await loadUserFromSupabase()
                case .signedOut:
                    await MainActor.run {
                        self.signOut()
                    }
                case .tokenRefreshed:
                    await loadUserFromSupabase()
                case .userUpdated:
                    await loadUserFromSupabase()
                case .passwordRecovery:
                    break
                case .userDeleted:
                    await MainActor.run {
                        self.signOut()
                    }
                case .mfaChallengeVerified:
                    await loadUserFromSupabase()
                @unknown default:
                    break
                }
            }
        }
    }
    
    // Charger l'utilisateur depuis Supabase
    @MainActor
    private func loadUserFromSupabase() async {
        guard let client = supabase.getClient() else { return }
        
        do {
            let session = try await client.auth.session
            let supabaseUser = session.user
            
            let userEmail = supabaseUser.email ?? {
                if let emailValue = supabaseUser.userMetadata["email"] {
                    if case .string(let str) = emailValue {
                        return str
                    }
                }
                return nil
            }()
            
            let userName: String = {
                if let fullNameValue = supabaseUser.userMetadata["full_name"],
                   case .string(let str) = fullNameValue {
                    return str
                }
                if let nameValue = supabaseUser.userMetadata["name"],
                   case .string(let str) = nameValue {
                    return str
                }
                return userEmail?.components(separatedBy: "@").first ?? "Utilisateur"
            }()
            
            let provider = determineProvider(from: supabaseUser)
            
            let profileImageURL: String? = {
                if let avatarValue = supabaseUser.userMetadata["avatar_url"],
                   case .string(let str) = avatarValue {
                    return str
                }
                return nil
            }()
            
            self.currentUser = User(
                id: supabaseUser.id.uuidString,
                email: userEmail,
                name: userName,
                authProvider: provider,
                profileImageURL: profileImageURL
            )
            
            // Important : Forcer la mise à jour de l'état d'authentification
            // pour déclencher la mise à jour de l'UI
            self.isAuthenticated = true
            
            // Sauvegarder localement
            self.userDefaults.set(true, forKey: self.authKey)
            if let encoded = try? JSONEncoder().encode(self.currentUser!) {
                self.userDefaults.set(encoded, forKey: self.userKey)
            }
        } catch {
            print("Erreur lors du chargement de l'utilisateur: \(error)")
            // Si la session n'existe pas encore, garder l'état local actuel
            // (on a déjà créé l'utilisateur localement dans le callback)
        }
    }
    
    // Déterminer le provider depuis les métadonnées Supabase
    private func determineProvider(from supabaseUser: Supabase.User) -> AuthProvider {
        if let providerValue = supabaseUser.appMetadata["provider"],
           case .string(let provider) = providerValue {
            switch provider {
            case "google":
                return .google
            case "apple":
                return .apple
            default:
                return .email
            }
        }
        return .email
    }
    
    // Vérifier le statut d'authentification
    func checkAuthenticationStatus() {
        isAuthenticated = userDefaults.bool(forKey: authKey)
        if let data = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }
    
    // Connexion avec email
    func signInWithEmail(email: String, password: String) async throws {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard let client = supabase.getClient() else {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Supabase n'est pas configuré. Vérifiez votre configuration."
            }
            throw AuthError.networkError
        }
        
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            
            // Utiliser directement la session retournée pour créer l'utilisateur
            let supabaseUser = session.user
            let userEmail = supabaseUser.email ?? {
                if let emailValue = supabaseUser.userMetadata["email"],
                   case .string(let str) = emailValue {
                    return str
                }
                return nil
            }()
            
            let userName: String = {
                if let fullNameValue = supabaseUser.userMetadata["full_name"],
                   case .string(let str) = fullNameValue {
                    return str
                }
                if let nameValue = supabaseUser.userMetadata["name"],
                   case .string(let str) = nameValue {
                    return str
                }
                return userEmail?.components(separatedBy: "@").first ?? "Utilisateur"
            }()
            
            let provider = determineProvider(from: supabaseUser)
            
            let profileImageURL: String? = {
                if let avatarValue = supabaseUser.userMetadata["avatar_url"],
                   case .string(let str) = avatarValue {
                    return str
                }
                return nil
            }()
            
            await MainActor.run {
                self.currentUser = User(
                    id: supabaseUser.id.uuidString,
                    email: userEmail,
                    name: userName,
                    authProvider: provider,
                    profileImageURL: profileImageURL
                )
                
                self.isAuthenticated = true
                
                // Sauvegarder localement
                self.userDefaults.set(true, forKey: self.authKey)
                if let encoded = try? JSONEncoder().encode(self.currentUser!) {
                    self.userDefaults.set(encoded, forKey: self.userKey)
                }
                
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Erreur de connexion: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // Inscription avec email
    func signUpWithEmail(email: String, password: String, name: String) async throws {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard let client = supabase.getClient() else {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Supabase n'est pas configuré. Vérifiez votre configuration."
            }
            throw AuthError.networkError
        }
        
        do {
            let session = try await client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "full_name": .string(name),
                    "name": .string(name)
                ]
            )
            
            // Utiliser directement la session retournée
            // Note: Si l'email nécessite une confirmation, session.user sera vide mais la session sera créée
            let supabaseUser = session.user
            let userEmail = supabaseUser.email ?? {
                if let emailValue = supabaseUser.userMetadata["email"],
                   case .string(let str) = emailValue {
                    return str
                }
                return nil
            }()
            
            // Si l'email est vide, cela signifie qu'un email de confirmation a été envoyé
            if userEmail == nil || userEmail?.isEmpty == true {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Un email de confirmation a été envoyé. Vérifiez votre boîte mail."
                }
            } else {
                let userName: String = {
                    if let fullNameValue = supabaseUser.userMetadata["full_name"],
                       case .string(let str) = fullNameValue {
                        return str
                    }
                    if let nameValue = supabaseUser.userMetadata["name"],
                       case .string(let str) = nameValue {
                        return str
                    }
                    return name
                }()
                
                let provider = determineProvider(from: supabaseUser)
                
                let profileImageURL: String? = {
                    if let avatarValue = supabaseUser.userMetadata["avatar_url"],
                       case .string(let str) = avatarValue {
                        return str
                    }
                    return nil
                }()
                
                await MainActor.run {
                    self.currentUser = User(
                        id: supabaseUser.id.uuidString,
                        email: userEmail,
                        name: userName,
                        authProvider: provider,
                        profileImageURL: profileImageURL
                    )
                    
                    self.isAuthenticated = true
                    
                    // Sauvegarder localement
                    self.userDefaults.set(true, forKey: self.authKey)
                    if let encoded = try? JSONEncoder().encode(self.currentUser!) {
                        self.userDefaults.set(encoded, forKey: self.userKey)
                    }
                    
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Erreur d'inscription: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // Connexion avec Google via Supabase
    func signInWithGoogle() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard supabase.getClient() != nil else {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Supabase n'est pas configuré. Vérifiez votre configuration."
            }
            return
        }
        
        let redirectURL = "com.justetemps.app://auth-callback"
        let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        
        // Encoder correctement l'URL de redirection
        guard let encodedRedirectURL = redirectURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Impossible d'encoder l'URL de redirection"
            }
            return
        }
        
        // Construire l'URL OAuth - Supabase gère le PKCE automatiquement
        // Important : Le redirect_to doit pointer vers notre app, mais Supabase doit recevoir le callback d'abord
        let authURLString = "\(supabaseURL)/auth/v1/authorize?provider=google&redirect_to=\(encodedRedirectURL)"
        
        guard let authURL = URL(string: authURLString),
              let callbackURL = URL(string: redirectURL) else {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Impossible de créer l'URL d'authentification"
            }
            return
        }
        
        // Utiliser ASWebAuthenticationSession pour gérer correctement le flux OAuth
        await MainActor.run {
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURL.scheme) { [weak self] callbackURL, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    if let error = error {
                        // Si l'utilisateur a annulé, ne pas afficher d'erreur
                        if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                            self.isLoading = false
                            return
                        }
                        self.isLoading = false
                        self.errorMessage = "Erreur lors de l'authentification: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let callbackURL = callbackURL else {
                        self.isLoading = false
                        self.errorMessage = "Aucune URL de callback reçue"
                        return
                    }
                    
                    print("🔗 Callback reçu: \(callbackURL.absoluteString)")
                    
                    // Traiter le callback - Supabase devrait avoir déjà créé la session
                    Task {
                        await self.handleOAuthCallback(url: callbackURL)
                    }
                }
            }
            
            // Configurer la session
            session.presentationContextProvider = WebAuthContextProvider.shared
            session.prefersEphemeralWebBrowserSession = false
            
            // Démarrer la session
            session.start()
        }
    }
    
    // Connexion avec Apple via Supabase
    func signInWithApple(authorization: ASAuthorization) async {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            await MainActor.run {
                self.errorMessage = "Erreur lors de la récupération des informations Apple"
            }
            return
        }
        
        guard let client = supabase.getClient() else {
            await MainActor.run {
                self.errorMessage = "Supabase n'est pas configuré. Vérifiez votre configuration."
            }
            return
        }
        
        guard let identityToken = appleIDCredential.identityToken,
              let idTokenString = String(data: identityToken, encoding: .utf8) else {
            await MainActor.run {
                self.errorMessage = "Impossible de récupérer le token Apple"
            }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Récupérer le nom complet depuis les credentials Apple (disponible seulement lors de la première connexion/inscription)
            var fullName: String? = nil
            if let fullNameData = appleIDCredential.fullName {
                let givenName = fullNameData.givenName ?? ""
                let familyName = fullNameData.familyName ?? ""
                if !givenName.isEmpty || !familyName.isEmpty {
                    fullName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
                }
            }
            
            // Récupérer l'email depuis les credentials Apple (disponible seulement lors de la première connexion)
            // Note: L'email est déjà inclus dans le token Apple, donc on n'a pas besoin de le stocker séparément
            _ = appleIDCredential.email
            
            // Connexion/Inscription avec Supabase via Apple
            // Si l'utilisateur n'existe pas, Supabase le créera automatiquement
            // Le nom complet et l'email seront récupérés depuis le token si disponibles
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idTokenString
                )
            )
            
            // Si on a récupéré le nom complet lors de la première connexion, mettre à jour les métadonnées
            if let fullName = fullName, !fullName.isEmpty {
                // Vérifier si le nom n'est pas déjà dans les métadonnées
                let currentName: String? = {
                    if let nameValue = session.user.userMetadata["full_name"],
                       case .string(let str) = nameValue {
                        return str
                    }
                    return nil
                }()
                
                // Si le nom n'existe pas encore, essayer de le mettre à jour
                if currentName == nil || currentName?.isEmpty == true {
                    do {
                        try await client.auth.update(user: UserAttributes(
                            data: [
                                "full_name": .string(fullName),
                                "name": .string(fullName)
                            ]
                        ))
                    } catch {
                        print("⚠️ Impossible de mettre à jour le nom utilisateur: \(error)")
                        // Continuer quand même, ce n'est pas critique
                    }
                }
            }
            
            await loadUserFromSupabase()
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Erreur lors de la connexion Apple: \(error.localizedDescription)"
            }
        }
    }
    
    // Déconnexion
    func signOut() {
        Task {
            if let client = supabase.getClient() {
                try? await client.auth.signOut()
            }
            
            await MainActor.run {
                // Réinitialiser complètement l'état d'authentification
                self.currentUser = nil
                self.isAuthenticated = false
                self.errorMessage = nil
                self.isLoading = false
                
                // Nettoyer UserDefaults
                self.userDefaults.removeObject(forKey: self.authKey)
                self.userDefaults.removeObject(forKey: self.userKey)
                
                // Synchroniser pour s'assurer que les changements sont persistés
                self.userDefaults.synchronize()
            }
        }
    }
    
    // Gérer le callback OAuth (pour Google)
    func handleOAuthCallback(url: URL) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard supabase.getClient() != nil else { 
            await MainActor.run {
                self.errorMessage = "Supabase n'est pas configuré"
                self.isLoading = false
            }
            return 
        }
        
        print("📱 Traitement du callback: \(url.absoluteString)")
        
        // Si l'URL est notre URL scheme, Supabase a déjà traité le callback
        // et nous a redirigé. La session devrait être créée.
        if url.scheme == "com.justetemps.app" {
            // Extraire les paramètres de l'URL
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "URL de callback invalide"
                }
                return
            }
            
            // Vérifier s'il y a une erreur dans l'URL
            if let queryItems = components.queryItems,
               let error = queryItems.first(where: { $0.name == "error" })?.value {
                await MainActor.run {
                    self.isLoading = false
                    if let errorDescription = queryItems.first(where: { $0.name == "error_description" })?.value {
                        self.errorMessage = "Erreur d'authentification: \(errorDescription.replacingOccurrences(of: "+", with: " "))"
                    } else {
                        self.errorMessage = "Erreur d'authentification: \(error)"
                    }
                }
                print("❌ Erreur dans le callback: \(error)")
                return
            }
            
            // Vérifier si on a un code ou des tokens dans l'URL
            var hasCode = false
            var hasTokens = false
            
            if let queryItems = components.queryItems {
                hasCode = queryItems.contains(where: { $0.name == "code" })
            }
            
            if let fragment = components.fragment {
                hasTokens = fragment.contains("access_token") || fragment.contains("refresh_token")
            }
            
            print("🔍 Code: \(hasCode), Tokens: \(hasTokens)")
            
            // Si on a des tokens dans le fragment, les extraire et créer la session manuellement
            // Le problème PKCE vient du fait que Supabase ne peut pas valider le flux avec le fragment
            // Il faut donc extraire les tokens et décoder le JWT pour créer la session manuellement
            if hasTokens, let fragment = components.fragment {
                print("📦 Extraction des tokens depuis le fragment")
                
                // Parser le fragment pour extraire les tokens
                let fragmentParams = fragment.components(separatedBy: "&")
                var accessToken: String?
                var refreshToken: String?
                
                for param in fragmentParams {
                    let parts = param.components(separatedBy: "=")
                    if parts.count == 2 {
                        let key = parts[0]
                        let value = parts[1]
                        
                        switch key {
                        case "access_token":
                            accessToken = value
                        case "refresh_token":
                            refreshToken = value
                        default:
                            break
                        }
                    }
                }
                
                if let accessToken = accessToken, let _ = refreshToken {
                    print("✅ Tokens extraits, décodage du JWT pour obtenir les infos utilisateur")
                    
                    // Décoder le JWT pour obtenir les informations utilisateur
                    let jwtParts = accessToken.components(separatedBy: ".")
                    if jwtParts.count == 3 {
                        // Décoder le payload (partie 2 du JWT)
                        var base64String = jwtParts[1]
                        // Ajouter le padding si nécessaire
                        let remainder = base64String.count % 4
                        if remainder > 0 {
                            base64String = base64String.padding(toLength: base64String.count + 4 - remainder, withPad: "=", startingAt: 0)
                        }
                        
                        if let base64Data = Data(base64Encoded: base64String),
                           let jsonData = try? JSONSerialization.jsonObject(with: base64Data) as? [String: Any] {
                            
                            // Extraire les informations utilisateur du JWT
                            let userId = jsonData["sub"] as? String ?? ""
                            let email = jsonData["email"] as? String
                            let userMetadata = jsonData["user_metadata"] as? [String: Any] ?? [:]
                            let appMetadata = jsonData["app_metadata"] as? [String: Any] ?? [:]
                            
                            print("👤 Utilisateur trouvé: \(userId), Email: \(email ?? "N/A")")
                            
                            // Créer manuellement un objet User à partir du JWT
                            // Note: Nous devons créer une session Supabase, mais l'API ne le permet peut-être pas directement
                            // Solution alternative: Utiliser les tokens pour faire une requête et obtenir les infos utilisateur
                            // Puis créer l'objet User localement
                            
                            let provider = (appMetadata["provider"] as? String) ?? "google"
                            let name = (userMetadata["full_name"] as? String) ?? (userMetadata["name"] as? String) ?? email?.components(separatedBy: "@").first ?? "Utilisateur"
                            let avatarURL = userMetadata["avatar_url"] as? String ?? userMetadata["picture"] as? String
                            
                            // Créer l'objet User
                            let user = User(
                                id: userId,
                                email: email,
                                name: name,
                                authProvider: provider == "google" ? .google : .email,
                                profileImageURL: avatarURL
                            )
                            
                            // Stocker les tokens et l'utilisateur
                            // Note: Nous ne pouvons pas créer une vraie session Supabase sans le code_verifier PKCE
                            // Mais nous pouvons stocker les tokens et simuler une session
                            // Cependant, pour que Supabase fonctionne correctement, il faudrait une vraie session
                            
                            // Solution: Stocker les tokens dans UserDefaults et marquer comme authentifié
                            // Mais cela signifie que les requêtes Supabase ne fonctionneront pas
                            // Il faut donc créer une vraie session
                            
                            // Stocker l'utilisateur localement (sans essayer de sauvegarder dans Supabase)
                            // car nous n'avons pas de vraie session Supabase (problème PKCE)
                            // Mais essayons quand même de récupérer la session Supabase après un court délai
                            
                            // Stocker l'utilisateur localement pour permettre la navigation immédiate
                            await MainActor.run {
                                self.currentUser = user
                                // Forcer la mise à jour de l'état d'authentification
                                self.isAuthenticated = true
                                
                                // Sauvegarder localement dans UserDefaults uniquement
                                self.userDefaults.set(true, forKey: self.authKey)
                                if let encoded = try? JSONEncoder().encode(user) {
                                    self.userDefaults.set(encoded, forKey: self.userKey)
                                }
                                
                                self.isLoading = false
                            }
                            
                            print("✅ Utilisateur créé et authentifié (session locale)")
                            
                            // Essayer de récupérer la session Supabase après un court délai
                            // pour permettre à Supabase de finaliser la création de l'utilisateur
                            // Cela permettra d'avoir une vraie session pour les requêtes futures
                            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 secondes
                            
                            // Essayer de charger l'utilisateur depuis Supabase pour avoir une vraie session
                            // Si ça échoue, on garde l'utilisateur local (déjà défini)
                            await loadUserFromSupabase()
                            
                            // Note importante :
                            // - L'utilisateur existe déjà dans auth.users (créé automatiquement par Supabase lors de l'OAuth)
                            // - Le trigger SQL devrait créer automatiquement l'entrée dans public.users
                            // - Nous ne pouvons pas sauvegarder manuellement car RLS bloque sans vraie session Supabase
                            // - Pour que le trigger fonctionne, exécutez supabase_sync_trigger.sql dans Supabase
                            
                            return
                        }
                    }
                }
            }
            
            // Si on arrive ici, on n'a pas réussi à créer la session
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Impossible de créer la session avec les tokens reçus"
            }
            print("❌ Impossible de créer la session")
        } else {
            // URL non reconnue
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "URL de callback non reconnue: \(url.absoluteString)"
            }
        }
    }
    
    // Sauvegarder l'utilisateur
    private func saveUser(_ user: User) {
        // Sauvegarder localement
        userDefaults.set(true, forKey: authKey)
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
        
        // Sauvegarder dans Supabase
        Task {
            let repository = UserRepository()
            try? await repository.saveUser(user)
        }
    }
}

enum AuthProvider: String, Codable {
    case email
    case google
    case apple
}

struct User: Codable, Identifiable {
    let id: String
    let email: String?
    let name: String
    let authProvider: AuthProvider
    var profileImageURL: String?
    
    init(id: String, email: String?, name: String, authProvider: AuthProvider, profileImageURL: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.authProvider = authProvider
        self.profileImageURL = profileImageURL
    }
}

enum AuthError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case invalidGoogleResponse
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Email invalide"
        case .invalidPassword:
            return "Mot de passe invalide"
        case .invalidGoogleResponse:
            return "Réponse Google invalide"
        case .networkError:
            return "Erreur réseau"
        }
    }
}

// Helper pour ASWebAuthenticationSession
class WebAuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = WebAuthContextProvider()
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}



