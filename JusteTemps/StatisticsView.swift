import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fond dégradé (même style que LoginView)
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // En-tête avec logo (même style que ScreenTimeView)
                        VStack(spacing: 10) {
                            // Logo personnalisé
                            if UIImage(named: "AppLogo") != nil {
                                Image("AppLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(16)
                                    .padding(.bottom, 5)
                            }
                            
                            Text("Statistiques")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Analysez votre utilisation")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
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
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
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
                .foregroundColor(.white)
                .padding(.horizontal)
            
            Chart {
                ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, data in
                    BarMark(
                        x: .value("Jour", data.day),
                        y: .value("Heures", data.hours)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
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
                        .foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.5, green: 0.4, blue: 0.9),   // Violet clair
                    Color(red: 0.4, green: 0.5, blue: 1.0)    // Bleu-violet
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(25)
        .shadow(color: Color.purple.opacity(0.4), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
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
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if topApps.isEmpty {
                Text("Aucune donnée disponible")
                    .foregroundColor(.white.opacity(0.8))
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
                                colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
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
                            .foregroundStyle(.white.opacity(0.3))
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(String(format: "%.1f", hours))h")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.3))
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.2),   // Orange vif
                    Color(red: 1.0, green: 0.4, blue: 0.6)    // Rose-orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(25)
        .shadow(color: Color.orange.opacity(0.4), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
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
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if appUsageData.isEmpty {
                Text("Aucune donnée disponible")
                    .foregroundColor(.white.opacity(0.8))
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
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.1f", data.hours))h")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.leading, 10)
                }
                .padding()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.4, blue: 0.9),   // Violet-rose
                    Color(red: 0.7, green: 0.5, blue: 0.85)  // Rose-violet clair
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(25)
        .shadow(color: Color.purple.opacity(0.4), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
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
                .foregroundColor(.white)
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
                    color: .white
                )
                
                StatCard(
                    title: "Total semaine",
                    value: String(format: "%.1f", weeklyTotal),
                    unit: "heures",
                    icon: "clock.fill",
                    color: .white
                )
                
                StatCard(
                    title: "App la plus utilisée",
                    value: mostUsedApp,
                    unit: "aujourd'hui",
                    icon: "star.fill",
                    color: .white
                )
                
                StatCard(
                    title: "Limite quotidienne",
                    value: screenTimeManager.formatTime(screenTimeManager.dailyLimit),
                    unit: "par jour",
                    icon: "target",
                    color: .white
                )
            }
            .padding()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.8, blue: 0.4),   // Vert vif
                    Color(red: 0.3, green: 0.9, blue: 0.5)    // Vert clair
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(25)
        .shadow(color: Color.green.opacity(0.4), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
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
                    .foregroundColor(.white)
                    .font(.title3)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.white.opacity(0.2)
        )
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
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if trendData.isEmpty {
                Text("Aucune donnée disponible")
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(Array(trendData.enumerated()), id: \.offset) { index, data in
                        LineMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("Heures", data.hours)
                        )
                        .foregroundStyle(.white)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("Heures", data.hours)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
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
                            .foregroundStyle(.white.opacity(0.3))
                        AxisValueLabel(format: .dateTime.month().day())
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.3))
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(String(format: "%.1f", hours))h")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.45, green: 0.55, blue: 0.95),  // Bleu moyen
                    Color(red: 0.5, green: 0.45, blue: 0.9)     // Violet-bleu
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(25)
        .shadow(color: Color.blue.opacity(0.4), radius: 15, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

#Preview {
    StatisticsView()
        .environmentObject(ScreenTimeManager())
}






