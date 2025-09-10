import UIKit

final class TrackersViewController: UIViewController, TrackerStoreDelegate {
    
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private var visibleCategories: [TrackerCategory] = []
    
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
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .add), for: .normal)
        button.tintColor = UIColor(resource: .ypBlack)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
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
    
    private lazy var searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypDarkGray)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var searchIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(resource: .search))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var searchLabel: UILabel = {
        let label = UILabel()
        label.text = "Поиск"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(resource: .ypGray)
        return label
    }()
    
    private lazy var emptyIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(resource: .star))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
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
        categories = TrackerCategoryStore().fetchAll()
        recordStore.delegate = self
        completedTrackers = Set(recordStore.fetchAll())
        filterTrackers(for: currentDate)
        collectionView.reloadData()
        setupUI()
        setupConstraints()
    }
    
    func didUpdateTrackers() {
        collectionView.reloadData()
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
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(datePicker)
        view.addSubview(addButton)
        view.addSubview(titleLabel)
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchIcon)
        searchContainer.addSubview(searchLabel)
        view.addSubview(emptyIcon)
        view.addSubview(emptyLabel)
    }
    
    private func setupConstraints() {
        [addButton, datePicker, titleLabel, searchContainer, searchIcon, searchLabel, emptyIcon, emptyLabel, collectionView].forEach {
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
            
            searchContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 36),
            
            searchIcon.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 8),
            searchIcon.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            
            searchLabel.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            searchLabel.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            
            emptyIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 80),
            emptyIcon.heightAnchor.constraint(equalToConstant: 80),
            emptyLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
