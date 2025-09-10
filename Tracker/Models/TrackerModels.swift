import Foundation
import UIKit

enum Weekday: Int, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [Weekday]
    
    var uiColor: UIColor {
          UIColor(named: color) ?? .ypBackground
      }
}

struct TrackerCategory {
    let title: String
    var trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date

    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        lhs.trackerId == rhs.trackerId &&
        Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        let startOfDay = Calendar.current.startOfDay(for: date)
        hasher.combine(startOfDay.timeIntervalSince1970)
    }
}

extension Weekday {
    var title: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
