import Foundation
import CoreData

protocol TrackerStoreProtocol {
    func createTracker(name: String, color: String, emoji: String, schedule: [Int], categoryTitle: String) -> Tracker
    func fetchTrackers() -> [Tracker]
    func fetchCategories() -> [TrackerCategory]
    func startObservingChanges(onUpdate: @escaping ([Tracker]) -> Void)
    func stopObservingChanges()
    func deleteTracker(_ tracker: Tracker)
    func updateTracker(_ tracker: Tracker, newName: String, newEmoji: String, newColor: String, newSchedule: [Int], newCategoryTitle: String?)
    func getOrCreateCategory(title: String) -> TrackerCategory
}

class TrackerStore: NSObject, TrackerStoreProtocol {
    private let coreDataManager = CoreDataManager.shared
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    private var onUpdateCallback: (([Tracker]) -> Void)?
    
    func createTracker(name: String, color: String, emoji: String, schedule: [Int], categoryTitle: String) -> Tracker {
        let coreDataTracker = coreDataManager.createTracker(
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            categoryTitle: categoryTitle
        )
        return coreDataTracker.toTracker()
    }
    
    func fetchTrackers() -> [Tracker] {
        let coreDataTrackers = coreDataManager.fetchTrackers()
        return coreDataTrackers.map { $0.toTracker() }
    }
    
    func updateTracker(_ tracker: Tracker, newName: String, newEmoji: String, newColor: String, newSchedule: [Int], newCategoryTitle: String?) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            let coreDataTrackers = try coreDataManager.context.fetch(request)
            if let coreDataTracker = coreDataTrackers.first {
                coreDataTracker.schedule = newSchedule as NSArray
                coreDataTracker.name = newName
                coreDataTracker.emoji = newEmoji
                coreDataTracker.color = newColor
                if let newCategoryTitle = newCategoryTitle, !newCategoryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let category = coreDataManager.getOrCreateCategory(title: newCategoryTitle)
                    coreDataTracker.category = category
                }
                coreDataManager.saveContext()
            }
        } catch {
            print("Error finding tracker to update: \(error)")
        }
    }
    
    func deleteTracker(_ tracker: Tracker) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            let coreDataTrackers = try coreDataManager.context.fetch(request)
            if let coreDataTracker = coreDataTrackers.first {
                coreDataManager.deleteTracker(coreDataTracker)
            }
        } catch {
            print("Error finding tracker to delete: \(error)")
        }
    }
    
    func getOrCreateCategory(title: String) -> TrackerCategory {
        let coreDataCategory = coreDataManager.getOrCreateCategory(title: title)
        return coreDataCategory.toTrackerCategory()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let coreDataCategories = coreDataManager.fetchCategories()
        return coreDataCategories.map { $0.toTrackerCategory() }
    }
    
    func startObservingChanges(onUpdate: @escaping ([Tracker]) -> Void) {
        self.onUpdateCallback = onUpdate
        
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataManager.context,
            sectionNameKeyPath: nil,
            cacheName: "TrackerStore"
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            notifyUpdate()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
    
    func stopObservingChanges() {
        fetchedResultsController?.delegate = nil
        fetchedResultsController = nil
        onUpdateCallback = nil
    }
    
    private func notifyUpdate() {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else { return }
        let trackers = fetchedObjects.map { $0.toTracker() }
        onUpdateCallback?(trackers)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyUpdate()
    }
}
