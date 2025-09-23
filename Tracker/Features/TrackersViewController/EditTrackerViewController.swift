import UIKit

protocol EditTrackerViewControllerDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker,
                          newName: String,
                          newEmoji: String,
                          newColor: String,
                          newSchedule: [Int],
                          newCategory: TrackerCategory?)
}

final class EditTrackerViewController: UIViewController {

    // MARK: - Delegate
    weak var delegate: EditTrackerViewControllerDelegate?

    // MARK: - Constants
    private enum Constants {
        static let textLimit = 38
        static let trackerTitle = NSLocalizedString("habit.edit.title", comment: "Редактирование привычки")
        static let placeholder = NSLocalizedString("habit.field.name.placeholder", comment: "Введите название трекера")
        static let limitText = NSLocalizedString("limit.characters.38", comment: "Ограничение 38 символов")
        static let cancelText = NSLocalizedString("button.common.cancel", comment: "Отменить")
        static let saveText = NSLocalizedString("button.common.save", comment: "Сохранить")
    }

    // MARK: - State
    private var trackerToEdit: Tracker
    private var trackerName: String
    private var trackerEmoji: String
    private var trackerColor: String
    private var weekDaysForTracker: [Weekday]
    private var category: TrackerCategory?

    private var selectedEmoji: String
    private var selectedColor: String

    private var cells: [(title: String, subtitle: String?)] = [
        (NSLocalizedString("category.screen.title", comment: "Категория"), nil),
        (NSLocalizedString("schedule.screen.title", comment: "Расписание"), nil)
    ]

    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    private let colors: [String] = (1...18).map { "CollectionColor\($0)" }

    // MARK: - Scroll Containers
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - UI Elements
    private lazy var trackerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.trackerTitle
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlack)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.limitText
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(resource: .ypRed)
        label.isHidden = true
        return label
    }()

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = Constants.placeholder
        field.text = trackerName
        field.backgroundColor = UIColor(resource: .ypBackground)
        field.font = .systemFont(ofSize: 17)
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.delegate = self
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        field.heightAnchor.constraint(equalToConstant: 75).isActive = true
        return field
    }()

    private lazy var stackTextFieldView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField, limitLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private lazy var cancelButton: UIButton = makeButton(title: Constants.cancelText,
                                                         titleColor: UIColor(resource: .ypRed),
                                                         backgroundColor: .clear,
                                                         borderColor: UIColor(resource: .ypRed)) {
        self.dismiss(animated: true)
    }

    private lazy var saveButton: UIButton = makeButton(title: Constants.saveText,
                                                       titleColor: UIColor(resource: .ypWhite),
                                                       backgroundColor: UIColor(resource: .ypGray),
                                                       borderColor: nil) {
        self.saveTracker()
    }

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        table.layer.cornerRadius = 16
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return table
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("section.emoji.title", comment: "Emoji")
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.heightAnchor.constraint(equalToConstant: 204).isActive = true
        return collectionView
    }()

    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("section.color.title", comment: "Цвет")
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.heightAnchor.constraint(equalToConstant: 204).isActive = true
        return collectionView
    }()

    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()

    // MARK: - Init
    init(tracker: Tracker, category: TrackerCategory?) {
        self.trackerToEdit = tracker
        self.trackerName = tracker.name
        self.trackerEmoji = tracker.emoji
        self.trackerColor = tracker.color
        self.weekDaysForTracker = tracker.schedule
        self.selectedEmoji = tracker.emoji
        self.selectedColor = tracker.color
        self.category = category

        super.init(nibName: nil, bundle: nil)

        self.cells[0].subtitle = category?.title
        let allDays = Weekday.allCases
        if weekDaysForTracker.count == allDays.count {
            cells[1].subtitle = NSLocalizedString("schedule.option.everyday", comment: "Каждый день")
        } else {
            cells[1].subtitle = weekDaysForTracker.sorted { $0.rawValue < $1.rawValue }
                .map { $0.shortTitle }
                .joined(separator: ", ")
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypWhite)
        setupHierarchy()
        setupConstraints()
        updateSaveButton()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: - Save Action
    private func saveTracker() {
        delegate?.didUpdateTracker(
            trackerToEdit,
            newName: trackerName,
            newEmoji: trackerEmoji,
            newColor: trackerColor,
            newSchedule: weekDaysForTracker.map { $0.rawValue },
            newCategory: category
        )
        dismiss(animated: true)
    }

    // MARK: - Helpers
    private func updateSaveButton() {
        let hasName = !trackerName.trimmingCharacters(in: .whitespaces).isEmpty
        let hasSchedule = !weekDaysForTracker.isEmpty
        let hasEmoji = !trackerEmoji.isEmpty
        let hasColor = !trackerColor.isEmpty
        saveButton.isEnabled = hasName && hasSchedule && hasEmoji && hasColor
        saveButton.backgroundColor = saveButton.isEnabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }

    private func makeButton(title: String, titleColor: UIColor?, backgroundColor: UIColor?, borderColor: UIColor?, action: @escaping () -> Void) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 16
        button.layer.borderWidth = borderColor != nil ? 1 : 0
        button.layer.borderColor = borderColor?.cgColor
        button.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
        return button
    }

    // MARK: - UI Setup
    private func setupHierarchy() {
        contentStack.axis = .vertical
        contentStack.spacing = 24
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        view.addSubview(bottomContainerView)
        [trackerTitleLabel, stackTextFieldView, tableView, emojiLabel, emojiCollectionView, colorLabel, colorCollectionView].forEach {
            contentStack.addArrangedSubview($0)
        }
        bottomContainerView.addSubview(cancelButton)
        bottomContainerView.addSubview(saveButton)
    }

    private func setupConstraints() {
        [scrollView, contentStack, bottomContainerView, cancelButton, saveButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 110),

            cancelButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            saveButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            saveButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension EditTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        limitLabel.isHidden = updatedText.count <= Constants.textLimit
        return updatedText.count <= Constants.textLimit
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        trackerName = textField.text ?? ""
        updateSaveButton()
    }
}

// MARK: - CategoryViewControllerDelegate
extension EditTrackerViewController: CategoryViewControllerDelegate {
    func categoryViewController(_ controller: CategoryViewController, didSelectCategory category: TrackerCategory) {
        self.category = category
        cells[0].subtitle = category.title
        tableView.reloadData()
        updateSaveButton()
    }
}

// MARK: - ScheduleViewControllerDelegate
extension EditTrackerViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Weekday]) {
        weekDaysForTracker = days
        let allDays = Weekday.allCases
        let subtitle: String
        if days.count == allDays.count {
            subtitle = NSLocalizedString("schedule.option.everyday", comment: "Каждый день")
        } else {
            subtitle = days.sorted { $0.rawValue < $1.rawValue }
                .map { $0.shortTitle }
                .joined(separator: ", ")
        }
        cells[1].subtitle = subtitle.isEmpty ? nil : subtitle
        tableView.reloadData()
        updateSaveButton()
    }
}

// MARK: - UITableView
extension EditTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { cells.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        let data = cells[indexPath.row]
        cell.configure(title: data.title, subtitle: data.subtitle)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(resource: .ypBackground)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellTitle = cells[indexPath.row].title
        if cellTitle == NSLocalizedString("schedule.screen.title", comment: "Расписание") {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.modalPresentationStyle = .automatic
            present(scheduleVC, animated: true)
        } else if cellTitle == NSLocalizedString("category.screen.title", comment: "Категория") {
            let categoryVC = CategoryViewController()
            categoryVC.delegate = self
            categoryVC.modalPresentationStyle = .automatic
            present(categoryVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = indexPath.row == cells.count - 1
            ? UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
}

// MARK: - UICollectionView
extension EditTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? emojis.count : colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            let isSelected = emoji == selectedEmoji
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let colorName = colors[indexPath.item]
            let isSelected = colorName == selectedColor
            cell.configure(with: colorName, isSelected: isSelected)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            trackerEmoji = selectedEmoji
            emojiCollectionView.reloadData()
        } else if collectionView == colorCollectionView {
            selectedColor = colors[indexPath.item]
            trackerColor = selectedColor
            colorCollectionView.reloadData()
        }
        updateSaveButton()
    }
}

extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsInRow: CGFloat = 6
        let spacing: CGFloat = 12
        let totalWidth = collectionView.bounds.width
        let width = (totalWidth - (itemsInRow - 1) * spacing) / itemsInRow
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

