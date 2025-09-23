import UIKit

final class TrackersViewController: UIViewController, TrackerStoreDelegate {
    
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private var visibleCategories: [TrackerCategory] = []
    private var currentFilter: TrackerFilter = .today
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseId)
        cv.register(CategoryHeader.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "Header")
        return cv
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters.title", comment: "Фильтры"), for: .normal)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypBlue)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        return button
    }()

    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .plus), for: .normal)
        button.tintColor = UIColor(resource: .ypBlack)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("main.trackers.title", comment: "Трекеры")
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = UIColor(resource: .ypBlack)
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.clipsToBounds = true
        picker.calendar.firstWeekday = 2
        let localID = Locale.preferredLanguages.first
        picker.locale = Locale(identifier: localID ?? "ru_RU")
        return picker
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(resource: .ypDarkGray)
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textColor = UIColor(resource: .ypBlack)
        textField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("main.search.placeholder", comment: "Поиск"),
            attributes: [
                .foregroundColor: UIColor(resource: .ypGray),
                .font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )

        let iconView = UIImageView(image: UIImage(resource: .search))
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 6, y: 0, width: 18, height: 18)

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 36))
        paddingView.addSubview(iconView)
        iconView.center.y = paddingView.center.y

        textField.leftView = paddingView
        textField.leftViewMode = .always

        return textField
    }()

    private lazy var emptyIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(resource: .star))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("main.empty.trackers", comment: "Что будем отслеживать?")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerStore.delegate = self
        view.backgroundColor = .white
        tabBarController?.tabBar.backgroundColor = .white
        addButton.addTarget(self, action: #selector(addTrackerTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        categories = categoryStore.fetchAll()
        recordStore.delegate = self
        completedTrackers = Set(recordStore.fetchAll())
        filterTrackers(for: currentDate)
        setupUI()
        setupConstraints()
    }
    
    func didUpdateTrackers() {
        filterTrackers(for: currentDate)
    }
    
    @objc private func addTrackerTapped() {
        let createVC = TrackerCreateViewController()
        createVC.delegate = self
        present(createVC, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        filterTrackers(for: currentDate)
    }
    
    @objc private func filtersButtonTapped() {
        let filtersVC = FiltersViewController()
        filtersVC.modalPresentationStyle = .pageSheet
        filtersVC.selectedFilter = currentFilter
        filtersVC.onFilterSelected = { [weak self] filter in
            self?.currentFilter = filter

        }
        present(filtersVC, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(datePicker)
        view.addSubview(addButton)
        view.addSubview(titleLabel)
        view.addSubview(emptyIcon)
        view.addSubview(emptyLabel)
        view.addSubview(filtersButton)
        view.addSubview(searchTextField)
    }
    
    private func setupConstraints() {
        [addButton, datePicker, titleLabel, searchTextField, emptyIcon, emptyLabel, collectionView, filtersButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 42),
            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 77),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 1),
            
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            emptyIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 80),
            emptyIcon.heightAnchor.constraint(equalToConstant: 80),
            emptyLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Trackers Filtering and Completion
extension TrackersViewController {
    
    func completeTracker(_ tracker: Tracker, on date: Date) {
        let record = TrackerRecord(trackerId: tracker.id, date: date)
        completedTrackers.insert(record)
        try? recordStore.addRecord(record)
    }
    
    func uncompleteTracker(_ tracker: Tracker, on date: Date) {
        let record = TrackerRecord(trackerId: tracker.id, date: date)
        completedTrackers.remove(record)
        try? recordStore.deleteRecord(record)
    }
    
    func isCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let record = TrackerRecord(trackerId: tracker.id, date: date)
        return completedTrackers.contains(record)
    }
    
    func completedDaysCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerId == tracker.id }.count
    }
    
    private func filterTrackers(for date: Date) {
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let weekday = Weekday.allCases[(weekdayIndex + 5) % 7]
        visibleCategories = categories.compactMap { category in
            let trackersForDay = category.trackers.filter { $0.schedule.contains(weekday) }
            return trackersForDay.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackersForDay)
        }
        let hasTrackers = !visibleCategories.isEmpty
        emptyIcon.isHidden = hasTrackers
        emptyLabel.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
        collectionView.reloadData()
    }
}

// MARK: - TrackerCreateViewControllerDelegate & TrackerRecordStoreDelegate
extension TrackersViewController: TrackerCreateViewControllerDelegate {
    func trackerCreateViewController(_ controller: TrackerCreateViewController, didCreate tracker: Tracker, inCategory category: String) {
        do {
            try categoryStore.addTracker(tracker, toCategory: category)
        } catch {
            print("Ошибка сохранения трекера в Core Data: \(error)")
        }
        categories = categoryStore.fetchAll()
        filterTrackers(for: currentDate)
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        completedTrackers = Set(recordStore.fetchAll())
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseId,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let completed = completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        let counter = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.configure(with: tracker, completed: completed, counter: counter) { [weak self] in
            guard let self = self else { return }
            let today = Calendar.current.startOfDay(for: Date())
            let selectedDay = Calendar.current.startOfDay(for: self.currentDate)
            guard selectedDay <= today else { return }
            if completed { self.uncompleteTracker(tracker, on: self.currentDate) }
            else { self.completeTracker(tracker, on: self.currentDate) }
            collectionView.reloadItems(at: [indexPath])
        }
        
        cell.onLongPress = { [weak self] tracker in
            guard let self = self else { return }
            let alert = UIAlertController(title: tracker.name, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Редактировать", style: .default) { _ in
                self.editTracker(tracker)
            })
            
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
                self.deleteTracker(tracker)
            })
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            
            self.present(alert, animated: true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 8) / 2
        let height: CGFloat = 148
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "Header",
                for: indexPath) as? CategoryHeader else {
            return UICollectionReusableView()
        }
        header.configure(title: visibleCategories[indexPath.section].title)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 30)
    }
}

// MARK: - Actions for Context Menu
extension TrackersViewController {
    
    private func editTracker(_ tracker: Tracker) {
        let category = categories.first { $0.trackers.contains { $0.id == tracker.id } }
        let editVC = EditTrackerViewController(tracker: tracker, category: category)
        editVC.delegate = self
        present(editVC, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        guard let categoryIndex = categories.firstIndex(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }),
              let trackerIndex = categories[categoryIndex].trackers.firstIndex(where: { $0.id == tracker.id }) else {
            return
        }
        
        do {
            try categoryStore.deleteTracker(categories[categoryIndex].trackers[trackerIndex], fromCategory: categories[categoryIndex].title)
        } catch {
            print("Ошибка удаления трекера: \(error)")
        }
        
        categories = categoryStore.fetchAll()
        filterTrackers(for: currentDate)
    }
}

// MARK: - EditTrackerViewControllerDelegate
extension TrackersViewController: EditTrackerViewControllerDelegate {
    func didUpdateTracker(_ tracker: Tracker,
                          newName: String,
                          newEmoji: String,
                          newColor: String,
                          newSchedule: [Int],
                          newCategory: TrackerCategory?) {
        
        var updatedTracker = tracker
        updatedTracker.name = newName
        updatedTracker.emoji = newEmoji
        updatedTracker.color = newColor
        updatedTracker.schedule = newSchedule.map { Weekday(rawValue: $0) ?? .monday }
        
        for index in categories.indices {
            categories[index].trackers.removeAll { $0.id == tracker.id }
        }
        
        if let category = newCategory,
           let categoryIndex = categories.firstIndex(where: { $0.title == category.title }) {
            categories[categoryIndex].trackers.append(updatedTracker)
        }
        
        filterTrackers(for: currentDate)
    }
}
