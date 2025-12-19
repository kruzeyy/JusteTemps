import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            // Fond dégradé
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo et titre
                    VStack(spacing: 10) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("JusteTemps")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(isSignUp ? "Créez votre compte" : "Connectez-vous")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.bottom, 20)
                    
                    // Formulaire
                    VStack(spacing: 20) {
                        if isSignUp {
                            // Champ nom (seulement pour l'inscription)
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)
                                
                                TextField("Nom", text: $name)
                                    .textContentType(.name)
                                    .autocapitalization(.words)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Champ email
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Champ mot de passe
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            
                            if showPassword {
                                TextField("Mot de passe", text: $password)
                                    .textContentType(isSignUp ? .newPassword : .password)
                                    .foregroundColor(.black)
                            } else {
                                SecureField("Mot de passe", text: $password)
                                    .textContentType(isSignUp ? .newPassword : .password)
                                    .foregroundColor(.black)
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // Message d'erreur
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Bouton de connexion/inscription
                        Button(action: {
                            Task {
                                if isSignUp {
                                    try? await authManager.signUpWithEmail(
                                        email: email,
                                        password: password,
                                        name: name
                                    )
                                } else {
                                    try? await authManager.signInWithEmail(
                                        email: email,
                                        password: password
                                    )
                                }
                            }
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isSignUp ? "S'inscrire" : "Se connecter")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(authManager.isLoading ? Color.gray : Color.white)
                            .foregroundColor(authManager.isLoading ? .white : .blue)
                            .cornerRadius(12)
                        }
                        .disabled(authManager.isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty))
                        
                        // Séparateur
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("OU")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 10)
                        
                        // Bouton Google
                        Button(action: {
                            Task {
                                await authManager.signInWithGoogle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.title3)
                                
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Continuer avec Google")
                                        .fontWeight(.medium)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(authManager.isLoading ? Color.gray.opacity(0.3) : Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                        .disabled(authManager.isLoading)
                        
                        // Bouton Apple (fonctionne pour connexion et inscription)
                        SignInWithAppleButton(
                            onRequest: { request in
                                // Demander le nom complet et l'email (important pour l'inscription)
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                switch result {
                                case .success(let authorization):
                                    Task {
                                        await authManager.signInWithApple(authorization: authorization)
                                    }
                                case .failure(let error):
                                    Task { @MainActor in
                                        authManager.errorMessage = "Erreur Apple: \(error.localizedDescription)"
                                    }
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .disabled(authManager.isLoading)
                    }
                    .padding(.horizontal, 30)
                    
                    // Basculer entre connexion et inscription
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                            authManager.errorMessage = nil
                        }
                    }) {
                        HStack {
                            Text(isSignUp ? "Déjà un compte ?" : "Pas encore de compte ?")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(isSignUp ? "Se connecter" : "S'inscrire")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.vertical, 40)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

