import CoreData
import Foundation

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    private var isStoreLoaded = false
    private var onStoreLoaded: [() -> Void] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private func storeDidLoad() {
        isStoreLoaded = true
        onStoreLoaded.forEach { $0() }
        onStoreLoaded.removeAll()
    }
    
    func ensureStoreLoaded(completion: @escaping () -> Void) {
        if isStoreLoaded {
            completion()
        } else {
            onStoreLoaded.append(completion)
        }
    }
    
    private func deletePersistentStore() {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else { return }
        do {
            try FileManager.default.removeItem(at: storeURL)
        } catch {
            print("Error deleting persistent store: \(error)")
        }
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do { try context.save() }
            catch {
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createTracker(name: String, color: String, emoji: String, schedule: [Int], categoryTitle: String) -> TrackerCoreData {
        let tracker = TrackerCoreData(context: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.color = color
        tracker.emoji = emoji
        tracker.schedule = schedule as NSArray
        
        tracker.category = getOrCreateCategory(title: categoryTitle)
        saveContext()
        return tracker
    }
    
    func fetchTrackers() -> [TrackerCoreData] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do { return try context.fetch(request) }
        catch {
            print("Error fetching trackers: \(error)")
            return []
        }
    }
    
    func deleteTracker(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        saveContext()
    }
    
    func getOrCreateCategory(title: String) -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let category = try? context.fetch(request).first {
            return category
        }
        
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        saveContext()
        return category
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do { return try context.fetch(request) }
        catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func createRecord(trackerId: UUID, date: Date) -> TrackerRecordCoreData {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date
        
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        if let tracker = try? context.fetch(request).first {
            record.tracker = tracker
        }
        
        saveContext()
        return record
    }
    
    func fetchRecords(for trackerId: UUID? = nil) -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        if let trackerId = trackerId {
            request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        }
        do { return try context.fetch(request) }
        catch {
            print("Error fetching records: \(error)")
            return []
        }
    }
    
    func deleteRecord(_ record: TrackerRecordCoreData) {
        context.delete(record)
        saveContext()
    }
    
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.startOfDay(for: date.addingTimeInterval(86400))
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@", trackerId as CVarArg, start as CVarArg, end as CVarArg)
        if let records = try? context.fetch(request) {
            return !records.isEmpty
        }
        return false
    }
    
    func toggleTrackerCompletion(trackerId: UUID, date: Date) {
        if isTrackerCompleted(trackerId: trackerId, date: date) {
            let start = Calendar.current.startOfDay(for: date)
            let end = Calendar.current.startOfDay(for: date.addingTimeInterval(86400))
            let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@", trackerId as CVarArg, start as CVarArg, end as CVarArg)
            if let records = try? context.fetch(request) {
                records.forEach { context.delete($0) }
            }
        } else {
            _ = createRecord(trackerId: trackerId, date: date)
        }
        saveContext()
    }
}
