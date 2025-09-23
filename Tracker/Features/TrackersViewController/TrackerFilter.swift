import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case incomplete
    
    var title: String {
        switch self {
        case .all: return NSLocalizedString("filters.all", comment: "Все трекеры")
        case .today: return NSLocalizedString("filters.today", comment: "Трекеры на сегодня")
        case .completed: return NSLocalizedString("filters.completed", comment: "Завершенные")
        case .incomplete: return NSLocalizedString("filters.uncompleted", comment: "Не завершенные")
        }
    }
}
