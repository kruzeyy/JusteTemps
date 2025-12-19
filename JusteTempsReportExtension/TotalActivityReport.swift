//
//  TotalActivityReport.swift
//  JusteTempsReportExtension
//
//  Created by Maxime on 19/12/2025.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    // Note: Utilisez "totalActivity" pour correspondre à l'application principale
    static let totalActivity = Self("totalActivity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    let content: (String) -> TotalActivityView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
        
        // Sauvegarder les vraies données dans UserDefaults partagé
        if let sharedDefaults = UserDefaults(suiteName: "group.com.justetemps.app") {
            sharedDefaults.set(totalActivityDuration, forKey: "realScreenTimeToday")
            sharedDefaults.synchronize()
            print("✅ Données Screen Time sauvegardées: \(totalActivityDuration) secondes")
        }
        
        return formatter.string(from: totalActivityDuration) ?? "No activity data"
    }
}
