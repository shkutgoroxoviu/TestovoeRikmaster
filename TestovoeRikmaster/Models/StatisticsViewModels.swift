import Foundation

// MARK: - View Models 

struct VisitorsInfoViewModel {
    let count: Int
    let description: String
    let isIncreasing: Bool
}

struct ObserversInfoViewModel {
    let newCount: Int
    let stoppedCount: Int
}

struct GenderDistributionViewModel {
    let maleCount: Int
    let femaleCount: Int
    let malePercentage: Int
    let femalePercentage: Int
    
    var hasData: Bool {
        return maleCount + femaleCount > 0
    }
}

struct AgeRangeViewModel {
    let rangeLabel: String
    let maleCount: Int
    let femaleCount: Int
    let malePercentage: Int
    let femalePercentage: Int
}

struct ChartDataViewModel {
    let entries: [(label: String, value: Int)]
    let maxValue: Int
}

enum PeriodFilter: Int {
    case daily = 0
    case weekly = 1
    case monthly = 2
    
    var title: String {
        switch self {
        case .daily: return "По дням"
        case .weekly: return "По неделям"
        case .monthly: return "По месяцам"
        }
    }
}

enum TimeRangeFilter: Int {
    case today = 0
    case week = 1
    case month = 2
    case allTime = 3
    
    var title: String {
        switch self {
        case .today: return "Сегодня"
        case .week: return "Неделя"
        case .month: return "Месяц"
        case .allTime: return "Все время"
        }
    }
}

struct TopVisitorViewModel {
    let name: String
    let age: Int
    let avatarURL: String?
}

