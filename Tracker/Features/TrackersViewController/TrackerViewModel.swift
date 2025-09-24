import Foundation

protocol TrackerViewModelProtocol {
    var categories: [TrackerCategory] { get }
    var onCategoriesUpdate: (() -> Void)? { get set }
    
    func loadData()
    func deleteTracker(_ tracker: Tracker)
    func createTracker(_ tracker: Tracker, category: TrackerCategory)
    func updateTracker(_ tracker: Tracker, newName: String, newEmoji: String, newColor: String, newSchedule: [Int], newCategory: TrackerCategory?)
}

final class TrackerViewModel: TrackerViewModelProtocol {
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStoreProtocol
    private let trackerStore: TrackerStoreProtocol
    private(set) var categories: [TrackerCategory] = []
    
    // MARK: - Bindings
    var onCategoriesUpdate: (() -> Void)?
    
    // MARK: - Initialization
    init(trackerStore: TrackerStoreProtocol = TrackerStore(),
         categoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        setupObservers()
    }
    
    deinit {
        trackerStore.stopObservingChanges()
        categoryStore.stopObservingChanges()
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        categoryStore.startObservingChanges { [weak self] categories in
            DispatchQueue.main.async {
                self?.categories = categories
                self?.onCategoriesUpdate?()
            }
        }
        
        trackerStore.startObservingChanges { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadData()
            }
        }
    }
    
    // MARK: - Public Methods
    func loadData() {
        categories = categoryStore.fetchCategories()
        onCategoriesUpdate?()
    }
    
    func createTracker(_ tracker: Tracker, category: TrackerCategory) {
        _ = trackerStore.createTracker(
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            categoryTitle: category.title
        )
    }
    
    func updateTracker(_ tracker: Tracker,
                       newName: String,
                       newEmoji: String,
                       newColor: String,
                       newSchedule: [Int],
                       newCategory: TrackerCategory?) {
        trackerStore.updateTracker(
            tracker,
            newName: newName,
            newEmoji: newEmoji,
            newColor: newColor,
            newSchedule: newSchedule,
            newCategoryTitle: newCategory?.title
        )
    }
    
    func deleteTracker(_ tracker: Tracker) {
        trackerStore.deleteTracker(tracker)
    }
}
