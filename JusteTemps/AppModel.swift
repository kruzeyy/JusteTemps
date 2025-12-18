import Foundation

struct AppInfo: Identifiable, Codable {
    let id: String
    let name: String
    let bundleId: String
    var isBlocked: Bool
    var dailyLimit: TimeInterval // en secondes
    var timeSpent: TimeInterval // en secondes
    
    init(id: String = UUID().uuidString, name: String, bundleId: String, isBlocked: Bool = false, dailyLimit: TimeInterval = 0, timeSpent: TimeInterval = 0) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.isBlocked = isBlocked
        self.dailyLimit = dailyLimit
        self.timeSpent = timeSpent
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

