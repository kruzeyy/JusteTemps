import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private var client: SupabaseClient?
    
    private init() {
        setupSupabase()
    }
    
    private func setupSupabase() {
        // Remplacez ces valeurs par vos propres clés Supabase
        guard let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            print("⚠️ Configuration Supabase manquante. Ajoutez SUPABASE_URL et SUPABASE_ANON_KEY dans Info.plist")
            return
        }
        
        client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabaseKey)
    }
    
    func getClient() -> SupabaseClient? {
        return client
    }
    
    // Vérifier si Supabase est configuré
    var isConfigured: Bool {
        return client != nil
    }
}

