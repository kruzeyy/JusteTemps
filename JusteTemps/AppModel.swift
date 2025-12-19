import Foundation

struct AppInfo: Identifiable, Codable {
    let id: String
    let name: String
    let bundleId: String
    var isBlocked: Bool
    var dailyLimit: TimeInterval // en secondes
    var timeSpent: TimeInterval // en secondes
    var applicationTokenData: Data? // Token de l'application pour le blocage (codé en Data)
    
    // Propriétés calculées non-Codable
    enum CodingKeys: String, CodingKey {
        case id, name, bundleId, isBlocked, dailyLimit, timeSpent, applicationTokenData
    }
    
    init(id: String = UUID().uuidString, name: String, bundleId: String, isBlocked: Bool = false, dailyLimit: TimeInterval = 0, timeSpent: TimeInterval = 0, applicationTokenData: Data? = nil) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.isBlocked = isBlocked
        self.dailyLimit = dailyLimit
        self.timeSpent = timeSpent
        self.applicationTokenData = applicationTokenData
    }
}

struct DailyStats: Codable {
    var date: Date
    var totalScreenTime: TimeInterval // en secondes
    var appUsage: [String: TimeInterval] // bundleId -> temps en secondes
    
    init(date: Date = Date(), totalScreenTime: TimeInterval = 0, appUsage: [String: TimeInterval] = [:]) {
        self.date = date
        self.totalScreenTime = totalScreenTime
        self.appUsage = appUsage
    }
}

