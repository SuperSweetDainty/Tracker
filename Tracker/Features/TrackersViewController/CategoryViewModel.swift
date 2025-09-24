import Foundation

protocol CategoryViewModelProtocol {
    var categories: [TrackerCategory] { get }
    var selectedCategory: TrackerCategory? { get }
    var onCategoriesUpdate: (() -> Void)? { get set }
    var onCategorySelected: ((TrackerCategory) -> Void)? { get set }
    var onCategoryCreated: ((TrackerCategory) -> Void)? { get set }
    
    func loadCategories()
    func selectCategory(_ category: TrackerCategory)
    func createCategory(title: String)
    func updateCategoryTitle(_ category: TrackerCategory, newTitle: String)
    func deleteCategory(_ category: TrackerCategory)
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    // MARK: - Bindings
    var onCategoriesUpdate: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var onCategoryCreated: ((TrackerCategory) -> Void)?
    
    // MARK: - Properties
    private let categoryStore: TrackerCategoryStoreProtocol
    private(set) var categories: [TrackerCategory] = []
    private(set) var selectedCategory: TrackerCategory?
    
    // MARK: - Private Methods
    private func setupObservers() {
        categoryStore.startObservingChanges { [weak self] categories in
            self?.categories = categories
            self?.onCategoriesUpdate?()
        }
    }
    
    // MARK: - Initialization
    init(categoryStore: TrackerCategoryStoreProtocol = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
        setupObservers()
    }
    
    deinit {
        categoryStore.stopObservingChanges()
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = categoryStore.fetchCategories()
        onCategoriesUpdate?()
    }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        onCategorySelected?(category)
    }
    
    func createCategory(title: String) {
        let newCategory = categoryStore.createCategory(title: title)
        AnalyticsManager.shared.trackCategoryCreated(categoryName: title)
        onCategoryCreated?(newCategory)
    }
    
    func updateCategoryTitle(_ category: TrackerCategory, newTitle: String) {
        categoryStore.updateCategoryTitle(category, newTitle: newTitle)
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        categoryStore.deleteCategory(category)
    }
}
