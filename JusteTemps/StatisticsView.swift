import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // En-tête
                    VStack(spacing: 8) {
                        Text("Statistiques")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Analysez votre utilisation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)
                    
                    // Graphique hebdomadaire - Temps d'écran par jour
                    WeeklyChartView()
                        .environmentObject(screenTimeManager)
                    
                    // Graphique par application - Temps passé par app
                    AppsChartView()
                        .environmentObject(screenTimeManager)
                    
                    // Graphique en camembert - Répartition par application
                    AppsPieChartView()
                        .environmentObject(screenTimeManager)
                    
                    // Statistiques résumées
                    SummaryStatsView()
                        .environmentObject(screenTimeManager)
                    
                    // Graphique de tendance
                    TrendChartView()
                        .environmentObject(screenTimeManager)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WeeklyChartView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var weeklyData: [(day: String, hours: Double)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(String, Double)] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                let dayStart = calendar.startOfDay(for: date)
                
                if let stats = screenTimeManager.dailyStats.first(where: { 
                    calendar.isDate($0.date, inSameDayAs: dayStart) 
                }) {
                    data.append((dayName, stats.totalScreenTime / 3600))
                } else {
                    data.append((dayName, 0))
                }
            }
        }
        
        return data.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Temps d'écran cette semaine")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, data in
                    BarMark(
                        x: .value("Jour", data.day),
                        y: .value("Heures", data.hours)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(8)
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct AppsChartView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var topApps: [(name: String, hours: Double)] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let todayStats = screenTimeManager.dailyStats.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) 
        }) else {
            return []
        }
        
        var appData: [(String, Double)] = []
        for (bundleId, time) in todayStats.appUsage {
            if let app = screenTimeManager.apps.first(where: { $0.bundleId == bundleId }) {
                appData.append((app.name, time / 3600))
            }
        }
        
        return appData.sorted(by: { (first: (String, Double), second: (String, Double)) -> Bool in
            return first.1 > second.1
        }).prefix(5).map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Top 5 applications aujourd'hui")
                .font(.headline)
                .padding(.horizontal)
            
            if topApps.isEmpty {
                Text("Aucune donnée disponible")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(Array(topApps.enumerated()), id: \.offset) { index, app in
                        BarMark(
                            x: .value("Temps", app.hours),
                            y: .value("Application", app.name)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(String(format: "%.1f", hours))h")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct AppsPieChartView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var appUsageData: [(name: String, hours: Double, color: Color)] {
        let today = Calendar.current.startOfDay(for: Date())
        guard let todayStats = screenTimeManager.dailyStats.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) 
        }) else {
            return []
        }
        
        let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .cyan]
        var appData: [(String, Double, Color)] = []
        var colorIndex = 0
        
        for (bundleId, time) in todayStats.appUsage {
            if let app = screenTimeManager.apps.first(where: { $0.bundleId == bundleId }) {
                let hours = time / 3600
                if hours > 0 {
                    appData.append((app.name, hours, colors[colorIndex % colors.count]))
                    colorIndex += 1
                }
            }
        }
        
        return appData.sorted(by: { (first: (String, Double, Color), second: (String, Double, Color)) -> Bool in
            return first.1 > second.1
        })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Répartition par application")
                .font(.headline)
                .padding(.horizontal)
            
            if appUsageData.isEmpty {
                Text("Aucune donnée disponible")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                HStack(spacing: 30) {
                    Chart {
                        ForEach(Array(appUsageData.enumerated()), id: \.offset) { index, data in
                            SectorMark(
                                angle: .value("Temps", data.hours),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(data.color)
                            .annotation(position: .overlay) {
                                if data.hours > 0.5 {
                                    Text("\(String(format: "%.1f", data.hours))h")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .frame(width: 200, height: 200)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(appUsageData.enumerated()), id: \.offset) { index, data in
                            HStack {
                                Circle()
                                    .fill(data.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(data.name)
                                    .font(.caption)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.1f", data.hours))h")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding(.leading, 10)
                }
                .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct SummaryStatsView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var weeklyAverage: Double {
        let last7Days = screenTimeManager.dailyStats.suffix(7)
        guard !last7Days.isEmpty else { return 0 }
        let total = last7Days.reduce(0) { $0 + $1.totalScreenTime }
        return (total / Double(last7Days.count)) / 3600
    }
    
    var weeklyTotal: Double {
        let last7Days = screenTimeManager.dailyStats.suffix(7)
        return (last7Days.reduce(0) { $0 + $1.totalScreenTime }) / 3600
    }
    
    var mostUsedApp: String {
        let today = Calendar.current.startOfDay(for: Date())
        guard let todayStats = screenTimeManager.dailyStats.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) 
        }) else {
            return "Aucune"
        }
        
        let maxUsage = todayStats.appUsage.max { $0.value < $1.value }
        if let bundleId = maxUsage?.key,
           let app = screenTimeManager.apps.first(where: { $0.bundleId == bundleId }) {
            return app.name
        }
        return "Aucune"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Résumé")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    title: "Moyenne hebdo",
                    value: String(format: "%.1f", weeklyAverage),
                    unit: "h/jour",
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Total semaine",
                    value: String(format: "%.1f", weeklyTotal),
                    unit: "heures",
                    icon: "clock.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "App la plus utilisée",
                    value: mostUsedApp,
                    unit: "aujourd'hui",
                    icon: "star.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Limite quotidienne",
                    value: screenTimeManager.formatTime(screenTimeManager.dailyLimit),
                    unit: "par jour",
                    icon: "target",
                    color: .green
                )
            }
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TrendChartView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var trendData: [(date: Date, hours: Double)] {
        let last14Days = screenTimeManager.dailyStats.suffix(14).sorted { $0.date < $1.date }
        return last14Days.map { (date: $0.date, hours: $0.totalScreenTime / 3600) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Tendance (14 derniers jours)")
                .font(.headline)
                .padding(.horizontal)
            
            if trendData.isEmpty {
                Text("Aucune donnée disponible")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(Array(trendData.enumerated()), id: \.offset) { index, data in
                        LineMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("Heures", data.hours)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("Heures", data.hours)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 2)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(String(format: "%.1f", hours))h")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    StatisticsView()
        .environmentObject(ScreenTimeManager())
}

