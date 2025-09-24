import Foundation

struct Tracker: Codable {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: [Int]
    
    init(id: UUID, name: String, color: String, emoji: String, schedule: [Int]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
    
    init(name: String, color: String, emoji: String, schedule: [Int]) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
    
    func isScheduled(for date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let adjustedWeekday = (weekday + 5) % 7
        return schedule.contains(adjustedWeekday)
    }
}

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}

struct TrackerRecord: Codable {
    let trackerId: UUID
    let date: Date
    
    init(trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        self.date = date
    }
}
