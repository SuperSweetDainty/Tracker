import CoreData
import Foundation

extension TrackerCategoryCoreData {
    func toTrackerCategory() -> TrackerCategory {
        let trackers = (self.trackers?.allObjects as? [TrackerCoreData])?.map { $0.toTracker() } ?? []
        return TrackerCategory(title: self.title ?? "", trackers: trackers)
    }
    
    static func fromTrackerCategory(_ category: TrackerCategory, context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let coreDataCategory = TrackerCategoryCoreData(context: context)
        coreDataCategory.title = category.title
        let coreDataTrackers = category.trackers.map { TrackerCoreData.fromTracker($0, context: context) }
        coreDataCategory.trackers = NSSet(array: coreDataTrackers)
        return coreDataCategory
    }
}

extension TrackerCoreData {
    func toTracker() -> Tracker {
        let scheduleArray: [Int]
        if let ints = self.schedule as? [Int] {
            scheduleArray = ints
        } else if let nums = self.schedule as? [NSNumber] {
            scheduleArray = nums.map { $0.intValue }
        } else if let nsArray = self.schedule as? NSArray {
            scheduleArray = nsArray.compactMap { ($0 as? NSNumber)?.intValue }
        } else {
            scheduleArray = []
        }
        
        return Tracker(
            id: self.id ?? UUID(),
            name: self.name ?? "",
            color: self.color ?? "DefaultColor",
            emoji: self.emoji ?? "😀",
            schedule: scheduleArray
        )
    }
    
    static func fromTracker(_ tracker: Tracker, context: NSManagedObjectContext) -> TrackerCoreData {
        let coreDataTracker = TrackerCoreData(context: context)
        coreDataTracker.id = tracker.id
        coreDataTracker.name = tracker.name
        coreDataTracker.color = tracker.color
        coreDataTracker.emoji = tracker.emoji
        coreDataTracker.schedule = tracker.schedule as NSArray
        return coreDataTracker
    }
    
    func isScheduled(for date: Date) -> Bool {
        let scheduleArray: [Int]
        if let ints = self.schedule as? [Int] {
            scheduleArray = ints
        } else if let nums = self.schedule as? [NSNumber] {
            scheduleArray = nums.map { $0.intValue }
        } else if let nsArray = self.schedule as? NSArray {
            scheduleArray = nsArray.compactMap { ($0 as? NSNumber)?.intValue }
        } else {
            scheduleArray = []
        }
        
        let weekday = Calendar.current.component(.weekday, from: date)
        let adjustedWeekday = (weekday + 5) % 7
        return scheduleArray.contains(adjustedWeekday)
    }
}

extension TrackerRecordCoreData {
    func toTrackerRecord() -> TrackerRecord {
        TrackerRecord(
            trackerId: self.trackerId ?? UUID(),
            date: self.date ?? Date()
        )
    }
    
    static func fromTrackerRecord(_ record: TrackerRecord, context: NSManagedObjectContext) -> TrackerRecordCoreData {
        let coreDataRecord = TrackerRecordCoreData(context: context)
        coreDataRecord.trackerId = record.trackerId
        coreDataRecord.date = record.date
        return coreDataRecord
    }
}
