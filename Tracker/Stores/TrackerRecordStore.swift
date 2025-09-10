import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    weak var delegate: TrackerRecordStoreDelegate?
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Fetch
    func fetchAll() -> [TrackerRecord] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.compactMap {
            guard let trackerId = $0.trackerID, let date = $0.date else { return nil }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    // MARK: - Add / Delete
    func addRecord(_ record: TrackerRecord) throws {
        let newRecord = TrackerRecordCoreData(context: context)
        newRecord.trackerID = record.trackerId
        newRecord.date = record.date
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        guard
            let objects = fetchedResultsController.fetchedObjects
        else { return }
        
        if let objectToDelete = objects.first(where: {
            $0.trackerID == record.trackerId &&
            Calendar.current.isDate($0.date ?? Date(), inSameDayAs: record.date)
        }) {
            context.delete(objectToDelete)
            try context.save()
        }
    }
    
    // MARK: - Setup
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
            print("Ошибка fetch records: \(error)")
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}
