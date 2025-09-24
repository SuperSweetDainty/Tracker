import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    func createCategory(title: String) -> TrackerCategory
    func fetchCategories() -> [TrackerCategory]
    func updateCategoryTitle(_ category: TrackerCategory, newTitle: String)
    func deleteCategory(_ category: TrackerCategory)
    func getCategory(by title: String) -> TrackerCategory?
    func startObservingChanges(onUpdate: @escaping ([TrackerCategory]) -> Void)
    func stopObservingChanges()
}

class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
    private let coreDataManager = CoreDataManager.shared
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    private var onUpdateCallback: (([TrackerCategory]) -> Void)?
    
    func createCategory(title: String) -> TrackerCategory {
        let coreDataCategory = coreDataManager.getOrCreateCategory(title: title)
        return coreDataCategory.toTrackerCategory()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let coreDataCategories = coreDataManager.fetchCategories()
        return coreDataCategories.map { $0.toTrackerCategory() }
    }
    
    func updateCategoryTitle(_ category: TrackerCategory, newTitle: String) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let coreDataCategories = try coreDataManager.context.fetch(request)
            if let coreDataCategory = coreDataCategories.first {
                coreDataCategory.title = newTitle
                coreDataManager.saveContext()
            }
        } catch {
            print("Error finding category to update: \(error)")
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let coreDataCategories = try coreDataManager.context.fetch(request)
            if let coreDataCategory = coreDataCategories.first {
                coreDataManager.context.delete(coreDataCategory)
                coreDataManager.saveContext()
            }
        } catch {
            print("Error finding category to delete: \(error)")
        }
    }
    
    func getCategory(by title: String) -> TrackerCategory? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let coreDataCategories = try coreDataManager.context.fetch(request)
            return coreDataCategories.first?.toTrackerCategory()
        } catch {
            print("Error finding category: \(error)")
            return nil
        }
    }
    
    func startObservingChanges(onUpdate: @escaping ([TrackerCategory]) -> Void) {
        self.onUpdateCallback = onUpdate
        
        CoreDataManager.shared.ensureStoreLoaded { [weak self] in
            guard let self = self else { return }
            
            let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            self.fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: CoreDataManager.shared.context,
                sectionNameKeyPath: nil,
                cacheName: "TrackerCategoryStore"
            )
            
            self.fetchedResultsController?.delegate = self
            
            do {
                try self.fetchedResultsController?.performFetch()
                self.notifyUpdate()
            } catch {
                print("Error performing fetch: \(error)")
            }
        }
    }
    
    func stopObservingChanges() {
        fetchedResultsController?.delegate = nil
        fetchedResultsController = nil
        onUpdateCallback = nil
    }
    
    private func notifyUpdate() {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else { return }
        let categories = fetchedObjects.map { $0.toTrackerCategory() }
        onUpdateCallback?(categories)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyUpdate()
    }
}
