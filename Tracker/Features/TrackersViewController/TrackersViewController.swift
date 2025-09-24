import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let searchContainerView = UIView()
    private let searchTextField = UITextField()
    private let searchIconView = UIImageView()
    private let datePicker = UIDatePicker()
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let categoryHeaderLabel = UILabel()
    private let filtersButton = UIButton(type: .system)
    
    // MARK: - Data
    private var completedTrackerIds: Set<UUID> = []
    var currentDate: Date = Date()
    
    private var viewModel: TrackerViewModelProtocol
    private let recordStore = TrackerRecordStore()
    private var currentFilter: TrackerFilter = .all
    private var searchText: String = ""
    private var visibleCategories: [TrackerCategory] = []
    private var currentTrackerToDelete: Tracker?
    
    
    // MARK: - Initialization
    init(viewModel: TrackerViewModelProtocol = TrackerViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    private var visibleTrackers: [Tracker] {
        var allTrackers: [Tracker] = []
        for category in viewModel.categories {
            allTrackers.append(contentsOf: category.trackers)
        }
        return allTrackers.filter { $0.isScheduled(for: currentDate) }
    }
    
    private func getCompletedCount(for tracker: Tracker) -> Int {
        return recordStore.getCompletedCount(for: tracker.id)
    }
    
    private func isTrackerCompleted(for tracker: Tracker) -> Bool {
        return recordStore.isTrackerCompleted(trackerId: tracker.id, date: currentDate)
    }
    
    private func hasTrackersForDate(_ date: Date) -> Bool {
        return viewModel.categories.contains { category in
            category.trackers.contains { $0.isScheduled(for: date) }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        setupNotificationObservers()
        viewModel.loadData()
        applyFiltersAndSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AnalyticsManager.shared.trackScreenOpen(screen: "Main")
        
        #if DEBUG
       
        AnalyticsManager.shared.checkAnalyticsStatus()
        AnalyticsManager.shared.testAnalytics()
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsManager.shared.trackScreenClose(screen: "Main")
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YPWhite")
        setupNavigationBar()
        setupAddButton()
        setupTitle()
        setupSearchBar()
        setupDatePicker()
        setupCategoryHeader()
        setupCollectionView()
        setupFiltersButton()
        setupEmptyState()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("trackers.title", comment: "Заголовок экрана трекеров")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textColor = UIColor(named: "YPBlack")
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 254),
            titleLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    private func setupAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(named: "Plus"), for: .normal)
        addButton.tintColor = UIColor(named: "YPBlack")
        addButton.backgroundColor = UIColor.clear
        addButton.alpha = 1.0
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.date = currentDate
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 49),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            datePicker.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setupCategoryHeader() {
        categoryHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryHeaderLabel.text = ""
        categoryHeaderLabel.font = UIFont.boldSystemFont(ofSize: 19)
        categoryHeaderLabel.textColor = UIColor(named: "YPBlack")
        categoryHeaderLabel.isHidden = true
        view.addSubview(categoryHeaderLabel)
        
        NSLayoutConstraint.activate([
            categoryHeaderLabel.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 1),
            categoryHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            categoryHeaderLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupSearchBar() {
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.backgroundColor = UIColor(named: "YPLight Gray")
        searchContainerView.layer.cornerRadius = 10
        searchContainerView.clipsToBounds = true
        view.addSubview(searchContainerView)
        
        searchIconView.translatesAutoresizingMaskIntoConstraints = false
        searchIconView.image = UIImage(systemName: "magnifyingglass")
        searchIconView.tintColor = UIColor(named: "YPGray")
        searchContainerView.addSubview(searchIconView)
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = NSLocalizedString("search.placeholder", comment: "Поиск")
        searchTextField.backgroundColor = .clear
        searchTextField.borderStyle = .none
        searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchTextField.textColor = UIColor(named: "YPGray")
        searchTextField.autocorrectionType = .no
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        searchContainerView.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            searchIconView.topAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: 10),
            searchIconView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 8),
            searchIconView.widthAnchor.constraint(equalToConstant: 15.63),
            searchIconView.heightAnchor.constraint(equalToConstant: 15.78),
            
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 30),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -8),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: -7)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.image = UIImage(named: "StarImage")
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateImageView.alpha = 1.0
        view.addSubview(emptyStateImageView)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = NSLocalizedString("empty.trackers", comment: "Пустое состояние трекеров")
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textColor = UIColor(named: "YPBlack")
        emptyStateLabel.textAlignment = .center
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        AnalyticsManager.shared.trackButtonClick(screen: "Main", item: "add_track")
        
        let createHabitViewController = CreateHabitViewController()
        createHabitViewController.delegate = self
        createHabitViewController.modalPresentationStyle = .pageSheet
        present(createHabitViewController, animated: true)
    }

    @objc private func filtersButtonTapped() {
        AnalyticsManager.shared.trackButtonClick(screen: "Main", item: "filter")
        
        let filtersVC = FiltersViewController()
        filtersVC.modalPresentationStyle = .pageSheet
        filtersVC.selectedFilter = currentFilter
        filtersVC.onFilterSelected = { [weak self] filter in
            guard let self = self else { return }
            self.currentFilter = filter
            if filter == .today {
                let today = Date()
                self.currentDate = today
                self.datePicker.setDate(today, animated: true)
            }
            self.applyFiltersAndSearch()
            self.dismiss(animated: true)
        }
        present(filtersVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        applyFiltersAndSearch()
    }
    
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeader.identifier)
   
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: categoryHeaderLabel.bottomAnchor, constant: 6),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])
    }

    private func setupFiltersButton() {
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        filtersButton.setTitle(NSLocalizedString("filters.title", comment: "Фильтры"), for: .normal)
        filtersButton.setTitleColor(UIColor.white, for: .normal)
        filtersButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        filtersButton.backgroundColor = UIColor(named: "YPBlue")
        filtersButton.layer.cornerRadius = 16
        
        filtersButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        view.addSubview(filtersButton)
        view.bringSubviewToFront(filtersButton)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.widthAnchor.constraint(equalToConstant: 200),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        filtersButton.layer.shadowOpacity = 0
        filtersButton.layer.shadowRadius = 0
        filtersButton.layer.shadowOffset = CGSize.zero
        filtersButton.isUserInteractionEnabled = true
        filtersButton.isHidden = false
        filtersButton.layer.borderWidth = 0
    }
    
    // MARK: - Data Management
    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.applyFiltersAndSearch()
            }
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerEditRequested(_:)),
            name: NSNotification.Name("TrackerEditRequested"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackerDeleteRequested(_:)),
            name: NSNotification.Name("TrackerDeleteRequested"),
            object: nil
        )
    }
    
    @objc private func handleTrackerEditRequested(_ notification: Notification) {
        guard let tracker = notification.object as? Tracker else { return }
        editTracker(tracker)
    }
    
    @objc private func handleTrackerDeleteRequested(_ notification: Notification) {
        guard let tracker = notification.object as? Tracker else { return }
        deleteTracker(tracker)
    }
    
    private func addTracker(_ tracker: Tracker, category: TrackerCategory) {
        viewModel.createTracker(tracker, category: category)
    }
    
    private func updateTracker(_ tracker: Tracker, newName: String, newEmoji: String, newColor: String, newSchedule: [Int], newCategory: TrackerCategory? = nil) {
        viewModel.updateTracker(tracker, newName: newName, newEmoji: newEmoji, newColor: newColor, newSchedule: newSchedule, newCategory: newCategory)
    }
    
        private func updateCategoryHeader() {
        if let firstCategory = visibleCategories.first {
            categoryHeaderLabel.text = firstCategory.title
        }
    }
    
    func updateUI() {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        
        let isEmpty = visibleCategories.isEmpty
        let hasTrackersForCurrentDate = hasTrackersForDate(currentDate)
        filtersButton.isHidden = isEmpty
        
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        if isEmpty {
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                emptyStateImageView.image = UIImage(named: "searchnone")
                emptyStateLabel.text = NSLocalizedString("search.empty", comment: "Ничего не найдено")
            } else if currentFilter != .all {
                emptyStateImageView.image = UIImage(named: "searchnone")
                emptyStateLabel.text = NSLocalizedString("filters.empty", comment: "Ничего не найдено")
            } else {
                emptyStateImageView.image = UIImage(named: "StarImage")
                emptyStateLabel.text = NSLocalizedString("empty.trackers", comment: "Пустое состояние трекеров")
            }
        }
        collectionView.isHidden = isEmpty
        categoryHeaderLabel.isHidden = true
    }
    
    // MARK: - Tracker Management
    private func toggleTrackerCompletion(for tracker: Tracker) {
        let wasCompleted = isTrackerCompleted(for: tracker)
        recordStore.toggleTrackerCompletion(trackerId: tracker.id, date: currentDate)
        
        if wasCompleted {
            AnalyticsManager.shared.trackTrackerUncompleted(trackerId: tracker.id, trackerName: tracker.name)
        } else {
            AnalyticsManager.shared.trackTrackerCompleted(trackerId: tracker.id, trackerName: tracker.name)
        }
        
        updateUI()
    }
    
    
    private func editTracker(_ tracker: Tracker) {
        AnalyticsManager.shared.trackButtonClick(screen: "Main", item: "edit")
        
        let editTrackerVC = EditTrackerViewController(tracker: tracker)
        editTrackerVC.delegate = self
        editTrackerVC.modalPresentationStyle = .pageSheet
        present(editTrackerVC, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        AnalyticsManager.shared.trackButtonClick(screen: "Main", item: "delete")
        currentTrackerToDelete = tracker
        let alert = UIAlertController(
            title: "Уверены что хотите удалить трекер?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let tracker = self?.currentTrackerToDelete else { return }
            self?.performDeleteTracker(tracker)
            self?.currentTrackerToDelete = nil
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { [weak self] _ in
            self?.currentTrackerToDelete = nil
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func performDeleteTracker(_ tracker: Tracker) {
        viewModel.deleteTracker(tracker)
    }
    
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = visibleCategories[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as! TrackerCollectionViewCell
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        let completedCount = getCompletedCount(for: tracker)
        let isCompleted = isTrackerCompleted(for: tracker)
        
        cell.onCompletionToggled = { [weak self] tracker in
            self?.toggleTrackerCompletion(for: tracker)
        }
        
        cell.configure(with: tracker, selectedDate: currentDate, isCompleted: isCompleted, completedCount: completedCount)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CategoryHeader", for: indexPath) as! CategoryHeader
            let category = visibleCategories[indexPath.section]
            headerView.configure(with: category.title)
            return headerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        let collectionViewWidth = collectionView.bounds.width
        
        if collectionViewWidth == 0 {
          
            let screenWidth = UIScreen.main.bounds.width
            let availableWidth = screenWidth - 32
            let spacing: CGFloat = 9
            let cellWidth = (availableWidth - spacing) / 2
            
            return CGSize(width: cellWidth, height: 148)
        } else {
            let availableWidth = collectionViewWidth - 32
            let spacing: CGFloat = 9
            let cellWidth = (availableWidth - spacing) / 2
            
            return CGSize(width: cellWidth, height: 148)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
}

// MARK: - CreateHabitViewControllerDelegate
extension TrackersViewController: CreateHabitViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, category: TrackerCategory) {
        AnalyticsManager.shared.trackTrackerCreated(
            name: tracker.name,
            category: category.title,
            schedule: tracker.schedule
        )
        addTracker(tracker, category: category)
    }
}


// MARK: - EditTrackerViewControllerDelegate
extension TrackersViewController: EditTrackerViewControllerDelegate {
    func didUpdateTracker(_ tracker: Tracker, newName: String, newEmoji: String, newColor: String, newSchedule: [Int], newCategory: TrackerCategory?) {
        AnalyticsManager.shared.trackTrackerEdited(trackerId: tracker.id, trackerName: newName)
        updateTracker(tracker, newName: newName, newEmoji: newEmoji, newColor: newColor, newSchedule: newSchedule, newCategory: newCategory)
    }
}

// MARK: - Search & Filter Logic
extension TrackersViewController {
    @objc private func searchTextChanged() {
        searchText = searchTextField.text ?? ""
        applyFiltersAndSearch()
    }
    
    private func applyFiltersAndSearch() {

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var categories: [TrackerCategory]
        if query.isEmpty {
            categories = viewModel.categories.map { category in
                let trackers = category.trackers.filter { $0.isScheduled(for: currentDate) }
                return TrackerCategory(title: category.title, trackers: trackers)
            }.filter { !$0.trackers.isEmpty }
        } else {
            categories = viewModel.categories
        }
        
        if !query.isEmpty {
            categories = categories.compactMap { category in
                let filtered = category.trackers.filter { $0.name.lowercased().contains(query) }
                return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
            }
        }
        
        switch currentFilter {
        case .all:
            break
        case .today:
            categories = categories.map { category in
                let trackers = category.trackers.filter { $0.isScheduled(for: currentDate) }
                return TrackerCategory(title: category.title, trackers: trackers)
            }.filter { !$0.trackers.isEmpty }
        case .completed:
            categories = categories.map { category in
                let trackers = category.trackers.filter { recordStore.isTrackerCompleted(trackerId: $0.id, date: currentDate) }
                return TrackerCategory(title: category.title, trackers: trackers)
            }.filter { !$0.trackers.isEmpty }
        case .incomplete:
            categories = categories.map { category in
                let trackers = category.trackers.filter {
                    $0.isScheduled(for: currentDate) && !recordStore.isTrackerCompleted(trackerId: $0.id, date: currentDate)
                }
                return TrackerCategory(title: category.title, trackers: trackers)
            }.filter { !$0.trackers.isEmpty }
        }
        
        visibleCategories = categories
        updateUI()
    }
}
