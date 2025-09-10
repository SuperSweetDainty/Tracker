import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    weak var delegate: TrackerStoreDelegate?

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

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
            print("Ошибка fetch: \(error)")
        }
    }

    func fetchAll() -> [Tracker] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap { TrackerStore.mapToTracker($0) }
    }
    
    func create(_ tracker: Tracker, in category: TrackerCategoryCoreData) throws {
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.identifier = tracker.id
        trackerCD.name = tracker.name
        trackerCD.color = tracker.color
        trackerCD.emoji = tracker.emoji
        trackerCD.schedule = tracker.schedule.map { $0.rawValue } as NSObject
        trackerCD.category = category

        try context.save()
    }
    
    func delete(by id: UUID) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", id as CVarArg)
        if let tracker = try context.fetch(request).first {
            context.delete(tracker)
            try context.save()
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}

extension TrackerStore {
    static func mapToTracker(_ trackerCD: TrackerCoreData) -> Tracker? {
        guard
            let id = trackerCD.identifier,
            let name = trackerCD.name,
            let color = trackerCD.color,
            let emoji = trackerCD.emoji,
            let scheduleRaw = trackerCD.schedule as? [Int]
        else {
            return nil
        }

        let schedule = scheduleRaw.compactMap { Weekday(rawValue: $0) }

        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
}
