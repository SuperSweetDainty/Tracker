import UIKit

protocol CategoryViewModelProtocol {
    var categories: [TrackerCategory] { get }
    var selectedCategory: TrackerCategory? { get }

    var onCategoriesUpdate: (() -> Void)? { get set }
    var onCategorySelected: ((TrackerCategory) -> Void)? { get set }
    var onCategoryCreated: ((TrackerCategory) -> Void)? { get set }

    func loadCategories()
    func selectCategory(_ category: TrackerCategory)
    func createCategory(title: String)
    func deleteCategory(_ category: TrackerCategory)
    func updateCategoryTitle(_ category: TrackerCategory, newTitle: String)
}

final class CategoryViewModel: CategoryViewModelProtocol {

    // MARK: - Properties
    private let store: TrackerCategoryStore

    private(set) var categories: [TrackerCategory] = [] {
        didSet { DispatchQueue.main.async { [weak self] in self?.onCategoriesUpdate?() } }
    }
    private(set) var selectedCategory: TrackerCategory?

    var onCategoriesUpdate: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var onCategoryCreated: ((TrackerCategory) -> Void)?

    // MARK: - Init
    init(store: TrackerCategoryStore = TrackerCategoryStore()) {
        self.store = store
        self.store.delegate = self
        // load initial data synchronously from store
        loadCategories()
    }

    // MARK: - Public Methods
    func loadCategories() {
        // Load from store (synchronous). fetchAll() should return current DB state.
        let loaded = store.fetchAll()
        // keep stable order (store already sorts, but ensure)
        self.categories = loaded.sorted { $0.title.lowercased() < $1.title.lowercased() }
    }

    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        DispatchQueue.main.async { [weak self] in
            self?.onCategorySelected?(category)
        }
    }

    func createCategory(title: String) {
        // create on the same thread (Core Data main context assumed). wrap errors.
        do {
            // create in store (this persists)
            let categoryCD = try store.create(title: title)

            // Option A: reload from store to be 100% consistent
            loadCategories()

            // Map created CoreData object -> domain model (read trackers too)
            let trackers = (categoryCD.trackers as? Set<TrackerCoreData>)?.compactMap {
                TrackerStore.mapToTracker($0)
            } ?? []
            let newCategory = TrackerCategory(title: categoryCD.title ?? title, trackers: trackers)

            // Inform UI on main thread that a category was created
            DispatchQueue.main.async { [weak self] in
                self?.onCategoryCreated?(newCategory)
            }

        } catch {
            print("CategoryViewModel.createCategory error: \(error)")
            // можно вернуть ошибку через отдельный callback если нужно
        }
    }

    func deleteCategory(_ category: TrackerCategory) {
        do {
            try store.delete(by: category.title)
            // after delete reload
            loadCategories()
        } catch {
            print("CategoryViewModel.deleteCategory error: \(error)")
        }
    }

    func updateCategoryTitle(_ category: TrackerCategory, newTitle: String) {
        do {
            // Prefer store to expose an update method; if not, use fetch(by:) -> mutate -> save
            if let categoryCD = try store.fetch(by: category.title) {
                categoryCD.title = newTitle
                try store.context.save() // лучше: store.updateTitle(...)
                // refresh local list
                loadCategories()
            }
        } catch {
            print("CategoryViewModel.updateCategoryTitle error: \(error)")
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        // FRC reported changes in CoreData: reload local snapshot
        loadCategories()
    }
}
