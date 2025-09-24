import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func createRecord(trackerId: UUID, date: Date) -> TrackerRecord
    func fetchRecords(for trackerId: UUID?) -> [TrackerRecord]
    func deleteRecord(_ record: TrackerRecord)
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool
    func toggleTrackerCompletion(trackerId: UUID, date: Date)
    func getCompletedCount(for trackerId: UUID) -> Int
    func startObservingChanges(for trackerId: UUID?, onUpdate: @escaping ([TrackerRecord]) -> Void)
    func stopObservingChanges()
}

class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
    private let coreDataManager = CoreDataManager.shared
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    private var onUpdateCallback: (([TrackerRecord]) -> Void)?
    
    func deleteRecord(_ record: TrackerRecord) {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@ AND date == %@",
                                      record.trackerId as CVarArg,
                                      record.date as CVarArg)
        
        do {
            let coreDataRecords = try coreDataManager.context.fetch(request)
            if let coreDataRecord = coreDataRecords.first {
                coreDataManager.deleteRecord(coreDataRecord)
            }
        } catch {
            print("Error finding record to delete: \(error)")
        }
    }
    
    func createRecord(trackerId: UUID, date: Date) -> TrackerRecord {
        let coreDataRecord = coreDataManager.createRecord(trackerId: trackerId, date: date)
        return coreDataRecord.toTrackerRecord()
    }
    
    func toggleTrackerCompletion(trackerId: UUID, date: Date) {
        coreDataManager.toggleTrackerCompletion(trackerId: trackerId, date: date)
    }
    
    func getCompletedCount(for trackerId: UUID) -> Int {
        return coreDataManager.fetchRecords(for: trackerId).count
    }
    
    func fetchRecords(for trackerId: UUID?) -> [TrackerRecord] {
        let coreDataRecords = coreDataManager.fetchRecords(for: trackerId)
        return coreDataRecords.map { $0.toTrackerRecord() }
    }
    
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        return coreDataManager.isTrackerCompleted(trackerId: trackerId, date: date)
    }
    
    func startObservingChanges(for trackerId: UUID?, onUpdate: @escaping ([TrackerRecord]) -> Void) {
        self.onUpdateCallback = onUpdate
        
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        if let trackerId = trackerId {
            request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        }
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataManager.context,
            sectionNameKeyPath: nil,
            cacheName: "TrackerRecordStore"
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
        let records = fetchedObjects.map { $0.toTrackerRecord() }
        onUpdateCallback?(records)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyUpdate()
    }
}
