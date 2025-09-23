import Foundation
import UIKit

enum Weekday: Int, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

extension Weekday: Comparable {
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct Tracker {
    let id: UUID
    var name: String
    var color: String
    var emoji: String
    var schedule: [Weekday]
    var categoryId: UUID?
    
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
        case .monday:
            return NSLocalizedString("schedule.weekday.monday", comment: "Понедельник")
        case .tuesday:
            return NSLocalizedString("schedule.weekday.tuesday", comment: "Вторник")
        case .wednesday:
            return NSLocalizedString("schedule.weekday.wednesday", comment: "Среда")
        case .thursday:
            return NSLocalizedString("schedule.weekday.thursday", comment: "Четверг")
        case .friday:
            return NSLocalizedString("schedule.weekday.friday", comment: "Пятница")
        case .saturday:
            return NSLocalizedString("schedule.weekday.saturday", comment: "Суббота")
        case .sunday:
            return NSLocalizedString("schedule.weekday.sunday", comment: "Воскресенье")
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday:
            return NSLocalizedString("schedule.weekday.short.mon", comment: "Пн")
        case .tuesday:
            return NSLocalizedString("schedule.weekday.short.tue", comment: "Вт")
        case .wednesday:
            return NSLocalizedString("schedule.weekday.short.wed", comment: "Ср")
        case .thursday:
            return NSLocalizedString("schedule.weekday.short.thu", comment: "Чт")
        case .friday:
            return NSLocalizedString("schedule.weekday.short.fri", comment: "Пт")
        case .saturday:
            return NSLocalizedString("schedule.weekday.short.sat", comment: "Сб")
        case .sunday:
            return NSLocalizedString("schedule.weekday.short.sun", comment: "Вс")
        }
    }
}
