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
        loadCategories()
    }

    // MARK: - Public Methods
    func loadCategories() {
        let loaded = store.fetchAll()
        self.categories = loaded.sorted { $0.title.lowercased() < $1.title.lowercased() }
    }

    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        DispatchQueue.main.async { [weak self] in
            self?.onCategorySelected?(category)
        }
    }

    func createCategory(title: String) {
        do {
            let categoryCD = try store.create(title: title)

            loadCategories()
            let trackers = (categoryCD.trackers as? Set<TrackerCoreData>)?.compactMap {
                TrackerStore.mapToTracker($0)
            } ?? []
            let newCategory = TrackerCategory(title: categoryCD.title ?? title, trackers: trackers)

            DispatchQueue.main.async { [weak self] in
                self?.onCategoryCreated?(newCategory)
            }

        } catch {
            print("CategoryViewModel.createCategory error: \(error)")
        }
    }

    func deleteCategory(_ category: TrackerCategory) {
        do {
            try store.delete(by: category.title)
            loadCategories()
        } catch {
            print("CategoryViewModel.deleteCategory error: \(error)")
        }
    }

    func updateCategoryTitle(_ category: TrackerCategory, newTitle: String) {
        do {
            if let categoryCD = try store.fetch(by: category.title) {
                categoryCD.title = newTitle
                try store.context.save()
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
        loadCategories()
    }
}
