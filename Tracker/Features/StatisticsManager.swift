import Foundation
import CoreData

struct StatisticsData {
    let bestPeriod: Int
    let idealDays: Int
    let completedTrackers: Int
    let averageValue: Double
}

protocol StatisticsManagerProtocol {
    func calculateStatistics() -> StatisticsData
    func getBestPeriod() -> Int
    func getIdealDays() -> Int
    func getCompletedTrackers() -> Int
    func getAverageValue() -> Double
}

final class StatisticsManager: StatisticsManagerProtocol {
    
    private let coreDataManager = CoreDataManager.shared
    
    func calculateStatistics() -> StatisticsData {
        let bestPeriod = getBestPeriod()
        let idealDays = getIdealDays()
        let completedTrackers = getCompletedTrackers()
        let averageValue = getAverageValue()
        
        return StatisticsData(
            bestPeriod: bestPeriod,
            idealDays: idealDays,
            completedTrackers: completedTrackers,
            averageValue: averageValue
        )
    }
    
    func getBestPeriod() -> Int {
        let records = coreDataManager.fetchRecords()
        let recordsByDate = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date ?? Date())
        }
        
        var maxConsecutiveDays = 0
        var currentConsecutiveDays = 0
        var previousDate: Date?
        
        let sortedDates = recordsByDate.keys.sorted()
        
        for date in sortedDates {
            if let prevDate = previousDate {
                let daysDifference = Calendar.current.dateComponents([.day], from: prevDate, to: date).day ?? 0
                
                if daysDifference == 1 {
                    currentConsecutiveDays += 1
                } else {
                    maxConsecutiveDays = max(maxConsecutiveDays, currentConsecutiveDays)
                    currentConsecutiveDays = 1
                }
            } else {
                currentConsecutiveDays = 1
            }
            
            previousDate = date
        }
        
        maxConsecutiveDays = max(maxConsecutiveDays, currentConsecutiveDays)
        return maxConsecutiveDays
    }
    
    func getIdealDays() -> Int {
        let trackers = coreDataManager.fetchTrackers()
        let records = coreDataManager.fetchRecords()
        
        guard !trackers.isEmpty else { return 0 }
        
        let recordsByDate = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date ?? Date())
        }
        
        var idealDaysCount = 0
        
        for (date, dayRecords) in recordsByDate {
            let completedTrackerIds = Set(dayRecords.map { $0.trackerId })
            let activeTrackersForDay = trackers.filter { tracker in
                tracker.isScheduled(for: date)
            }
            
            let activeTrackerIds = Set(activeTrackersForDay.map { $0.id })
            
            if activeTrackerIds.isSubset(of: completedTrackerIds) && !activeTrackerIds.isEmpty {
                idealDaysCount += 1
            }
        }
        
        return idealDaysCount
    }
    
    func getCompletedTrackers() -> Int {
        let records = coreDataManager.fetchRecords()
        return records.count
    }
    
    func getAverageValue() -> Double {
        let trackers = coreDataManager.fetchTrackers()
        let records = coreDataManager.fetchRecords()
        
        guard !trackers.isEmpty else { return 0 }
        
        let recordsByDate = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date ?? Date())
        }
        
        var totalCompletedTrackers = 0
        var daysWithActivity = 0
        
        for (date, dayRecords) in recordsByDate {
            let activeTrackersForDay = trackers.filter { tracker in
                tracker.isScheduled(for: date)
            }
            
            if !activeTrackersForDay.isEmpty {
                totalCompletedTrackers += dayRecords.count
                daysWithActivity += 1
            }
        }
        
        return daysWithActivity > 0 ? Double(totalCompletedTrackers) / Double(daysWithActivity) : 0
    }
}
