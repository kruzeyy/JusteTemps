import Foundation
import Supabase

class UserRepository {
    private let supabase = SupabaseManager.shared
    
    // Sauvegarder ou mettre à jour un utilisateur dans la table users
    func saveUser(_ user: User) async throws {
        guard let client = supabase.getClient() else {
            throw AuthError.networkError
        }
        
        do {
            // Vérifier si l'utilisateur existe déjà
            let response: [UserData] = try await client.database
                .from("users")
                .select()
                .eq("id", value: user.id)
                .execute()
                .value
            
            // Si l'utilisateur existe, le mettre à jour
            if !response.isEmpty {
                var updateData: [String: AnyJSON] = [
                    "name": .string(user.name),
                    "auth_provider": .string(user.authProvider.rawValue)
                ]
                
                if let email = user.email {
                    updateData["email"] = .string(email)
                } else {
                    updateData["email"] = .null
                }
                
                if let profileImageURL = user.profileImageURL {
                    updateData["profile_image_url"] = .string(profileImageURL)
                } else {
                    updateData["profile_image_url"] = .null
                }
                
                try await client.database
                    .from("users")
                    .update(updateData)
                    .eq("id", value: user.id)
                    .execute()
            } else {
                // Sinon, créer un nouvel utilisateur
                var insertData: [String: AnyJSON] = [
                    "id": .string(user.id),
                    "name": .string(user.name),
                    "auth_provider": .string(user.authProvider.rawValue)
                ]
                
                if let email = user.email {
                    insertData["email"] = .string(email)
                } else {
                    insertData["email"] = .null
                }
                
                if let profileImageURL = user.profileImageURL {
                    insertData["profile_image_url"] = .string(profileImageURL)
                } else {
                    insertData["profile_image_url"] = .null
                }
                
                try await client.database
                    .from("users")
                    .insert(insertData)
                    .execute()
            }
        } catch {
            print("Erreur lors de la sauvegarde de l'utilisateur: \(error)")
            throw error
        }
    }
    
    // Récupérer un utilisateur par son ID
    func getUser(by id: String) async throws -> User? {
        guard let client = supabase.getClient() else {
            throw AuthError.networkError
        }
        
        do {
            let response: [UserData] = try await client.database
                .from("users")
                .select()
                .eq("id", value: id)
                .execute()
                .value
            
            guard let userData = response.first else {
                return nil
            }
            
            return User(
                id: userData.id,
                email: userData.email,
                name: userData.name,
                authProvider: AuthProvider(rawValue: userData.auth_provider) ?? .email,
                profileImageURL: userData.profile_image_url
            )
        } catch {
            print("Erreur lors de la récupération de l'utilisateur: \(error)")
            throw error
        }
    }
    
    // Mettre à jour le nom d'un utilisateur
    func updateUserName(_ userId: String, name: String) async throws {
        guard let client = supabase.getClient() else {
            throw AuthError.networkError
        }
        
        try await client.database
            .from("users")
            .update(["name": name])
            .eq("id", value: userId)
            .execute()
    }
    
    // Mettre à jour l'URL de l'image de profil
    func updateProfileImage(_ userId: String, imageURL: String) async throws {
        guard let client = supabase.getClient() else {
            throw AuthError.networkError
        }
        
        try await client.database
            .from("users")
            .update(["profile_image_url": imageURL])
            .eq("id", value: userId)
            .execute()
    }
}

// Structure pour décoder les données de la table users
struct UserData: Codable {
    let id: String
    let email: String?
    let name: String
    let auth_provider: String
    let profile_image_url: String?
    let created_at: String?
    let updated_at: String?
}

