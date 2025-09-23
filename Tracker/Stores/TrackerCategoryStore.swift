import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    weak var delegate: TrackerCategoryStoreDelegate?
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка fetch categories: \(error)")
        }
    }
    
    func fetchAll() -> [TrackerCategory] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.map { categoryCD in
            let trackers = (categoryCD.trackers as? Set<TrackerCoreData>)?.compactMap {
                TrackerStore.mapToTracker($0)
            } ?? []
            return TrackerCategory(title: categoryCD.title ?? "", trackers: trackers)
        }
    }
    
    func create(title: String) throws -> TrackerCategoryCoreData {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        try context.save()
        return category
    }
    
    func delete(by title: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        if let category = try context.fetch(request).first {
            context.delete(category)
            try context.save()
        }
    }
    
    func fetch(by title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        let result = try context.fetch(request)
        return result.first
    }
    
    func addTracker(_ tracker: Tracker, toCategory title: String) throws {
        let categoryCD: TrackerCategoryCoreData
        if let existing = try fetch(by: title) {
            categoryCD = existing
        } else {
            categoryCD = try create(title: title)
        }
        
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.identifier = tracker.id
        trackerCD.name = tracker.name
        trackerCD.color = tracker.color
        trackerCD.emoji = tracker.emoji
        trackerCD.schedule = tracker.schedule.map { $0.rawValue } as NSArray
        
        categoryCD.addToTrackers(trackerCD)
        try context.save()
    }
    
    /// Удаление трекера из категории
    func deleteTracker(_ tracker: Tracker, fromCategory title: String) throws {
        guard let category = try fetch(by: title),
              let trackersSet = category.trackers as? Set<TrackerCoreData>,
              let trackerCD = trackersSet.first(where: { $0.identifier == tracker.id })
        else { return }
        
        category.removeFromTrackers(trackerCD)
        context.delete(trackerCD)
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
