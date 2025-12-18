import Foundation
import SwiftUI
import AuthenticationServices
// import GoogleSignIn  // Décommentez après avoir ajouté le package GoogleSignIn

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let authKey = "isAuthenticated"
    private let userKey = "currentUser"
    
    init() {
        checkAuthenticationStatus()
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
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Simulation d'authentification (à remplacer par un vrai backend)
        // En production, utilisez Firebase Auth ou votre propre backend
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde de simulation
        
        // Ici, vous devriez appeler votre API backend
        // Pour l'instant, on simule une connexion réussie
        let user = User(
            id: UUID().uuidString,
            email: email,
            name: email.components(separatedBy: "@").first ?? "Utilisateur",
            authProvider: .email
        )
        
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.saveUser(user)
        }
    }
    
    // Inscription avec email
    func signUpWithEmail(email: String, password: String, name: String) async throws {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Simulation d'inscription
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let user = User(
            id: UUID().uuidString,
            email: email,
            name: name,
            authProvider: .email
        )
        
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.saveUser(user)
        }
    }
    
    // Connexion avec Google
    func signInWithGoogle() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // TODO: Ajoutez le package GoogleSignIn via Swift Package Manager
        // URL: https://github.com/google/GoogleSignIn-iOS
        // Puis décommentez le code ci-dessous et l'import en haut du fichier
        
        /*
        guard let presentingViewController = await UIApplication.shared.windows.first?.rootViewController else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Impossible de trouver la vue de présentation"
            }
            return
        }
        
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CLIENT_ID") as? String else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Configuration Google manquante. Ajoutez GOOGLE_CLIENT_ID dans Info.plist"
            }
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            
            guard let email = result.user.profile?.email,
                  let name = result.user.profile?.name else {
                throw AuthError.invalidGoogleResponse
            }
            
            let user = User(
                id: result.user.userID ?? UUID().uuidString,
                email: email,
                name: name,
                authProvider: .google,
                profileImageURL: result.user.profile?.imageURL(withDimension: 200)?.absoluteString
            )
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
                self.saveUser(user)
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Erreur lors de la connexion Google: \(error.localizedDescription)"
            }
        }
        */
        
        // Simulation temporaire
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let user = User(
                id: UUID().uuidString,
                email: "user@gmail.com",
                name: "Utilisateur Google",
                authProvider: .google
            )
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.saveUser(user)
        }
    }
    
    // Connexion avec Apple
    func signInWithApple(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Erreur lors de la récupération des informations Apple"
            return
        }
        
        let userIdentifier = appleIDCredential.user
        let email = appleIDCredential.email ?? ""
        let fullName = appleIDCredential.fullName
        let name = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let displayName = name.isEmpty ? (email.isEmpty ? "Utilisateur Apple" : email) : name
        
        let user = User(
            id: userIdentifier,
            email: email.isEmpty ? nil : email,
            name: displayName,
            authProvider: .apple
        )
        
        currentUser = user
        isAuthenticated = true
        saveUser(user)
    }
    
    // Déconnexion
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: authKey)
        userDefaults.removeObject(forKey: userKey)
        
        // Déconnexion Google si nécessaire
        // GIDSignIn.sharedInstance.signOut()  // Décommentez après avoir ajouté GoogleSignIn
    }
    
    // Sauvegarder l'utilisateur
    private func saveUser(_ user: User) {
        userDefaults.set(true, forKey: authKey)
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
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

