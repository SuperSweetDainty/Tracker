import UIKit

protocol TrackerCreateViewControllerDelegate: AnyObject {
    func trackerCreateViewController(_ controller: TrackerCreateViewController, didCreate tracker: Tracker, inCategory category: String)
}

final class TrackerCreateViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: TrackerCreateViewControllerDelegate?
    
    // MARK: - Constants
    private enum Constants {
        static let textLimit = 38
        static let trackerTitle = "Новая привычка"
        static let placeholder = "Введите название трекера"
        static let limitText = "Ограничение 38 символов"
        static let cancelText = "Отменить"
        static let createText = "Создать"
    }
    
    // MARK: - State
    private var categoryTitle: String = "Важное"
    private var trackerName: String = ""
    private var trackerColor: String?
    private var trackerEmoji: String = ""
    private var weekDaysForTracker: [Weekday] = []
    private var selectedEmoji: String?
    private var selectedColor: String?
    
    private var cells: [(title: String, subtitle: String?)] = [
        ("Категория", nil),
        ("Расписание", nil)
    ]
    
    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    private let colors: [String] = [
        "CollectionColor1",
        "CollectionColor2",
        "CollectionColor3",
        "CollectionColor4",
        "CollectionColor5",
        "CollectionColor6",
        "CollectionColor7",
        "CollectionColor8",
        "CollectionColor9",
        "CollectionColor10",
        "CollectionColor11",
        "CollectionColor12",
        "CollectionColor13",
        "CollectionColor14",
        "CollectionColor15",
        "CollectionColor16",
        "CollectionColor17",
        "CollectionColor18"
    ]
    
    // MARK: - Scroll Containers
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    // MARK: - UI Elements
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
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
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(resource: .ypRed)
        label.isHidden = true
        return label
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = Constants.placeholder
        field.backgroundColor = UIColor(resource: .ypBackground)
        field.font = .systemFont(ofSize: 17, weight: .regular)
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
    
    private lazy var cancelButton: UIButton = makeButton(title: Constants.cancelText, titleColor: UIColor(resource: .ypRed), backgroundColor: .clear, borderColor: UIColor(resource: .ypRed)) {
        self.dismiss(animated: true)
    }
    
    private lazy var createButton: UIButton = makeButton(title: Constants.createText, titleColor: UIColor(resource: .ypWhite), backgroundColor: UIColor(resource: .ypGray), borderColor: nil) {
        self.createTracker()
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
        label.text = "Emoji"
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
        label.text = "Цвет"
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        setupHierarchy()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    // MARK: - Button Actions
    private func createTracker() {
        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: trackerColor ?? ".gray",
            emoji: trackerEmoji,
            schedule: weekDaysForTracker
        )
        delegate?.trackerCreateViewController(self, didCreate: tracker, inCategory: categoryTitle)
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    private func updateCreateButton() {
        let hasName = !trackerName.trimmingCharacters(in: .whitespaces).isEmpty
        let hasSchedule = !weekDaysForTracker.isEmpty
        let hasEmoji = !trackerEmoji.isEmpty
        let hasColor = trackerColor != nil
        createButton.isEnabled = hasName && hasSchedule && hasEmoji && hasColor
        createButton.backgroundColor = createButton.isEnabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }
    
    private func makeButton(title: String, titleColor: UIColor?, backgroundColor: UIColor?, borderColor: UIColor?, action: @escaping () -> Void) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 16
        button.layer.borderWidth = borderColor != nil ? 1 : 0
        button.layer.borderColor = borderColor?.cgColor
        button.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
        return button
    }
    
    // MARK: - Setup UI
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
        bottomContainerView.addSubview(createButton)
    }
    
    private func setupConstraints() {
        [scrollView, contentStack, bottomContainerView, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
            
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -20),
            createButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension TrackerCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        limitLabel.isHidden = updatedText.count <= Constants.textLimit
        return updatedText.count <= Constants.textLimit
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        trackerName = textField.text ?? ""
        updateCreateButton()
    }
}

// MARK: - CategoryViewControllerDelegate
extension TrackerCreateViewController: CategoryViewControllerDelegate {
    func categoryViewController(_ controller: CategoryViewController, didSelectCategory category: String) {
        categoryTitle = category
        cells[0].subtitle = category
        tableView.reloadData()
        updateCreateButton()
    }
}

// MARK: - ScheduleViewControllerDelegate
extension TrackerCreateViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Weekday]) {
        weekDaysForTracker = days
        let allDays = Weekday.allCases
        let subtitle: String
        if days.count == allDays.count {
            subtitle = "Каждый день"
        } else {
            subtitle = days.sorted { $0.rawValue < $1.rawValue }
                .map { $0.shortTitle }
                .joined(separator: ", ")
        }
        cells[1].subtitle = subtitle.isEmpty ? nil : subtitle
        tableView.reloadData()
        updateCreateButton()
    }
}

// MARK: - UITableView
extension TrackerCreateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { cells.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        let data = cells[indexPath.row]
        cell.configure(title: data.title, subtitle: data.subtitle)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(resource: .ypBackground)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellTitle = cells[indexPath.row].title
        
        if cellTitle == "Расписание" {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.modalPresentationStyle = .automatic
            present(scheduleVC, animated: true)
        } else if cellTitle == "Категория" {
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
extension TrackerCreateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            let emoji = emojis[indexPath.item]
            let isSelected = emoji == selectedEmoji
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            let colorName = colors[indexPath.item]
            let isSelected = colorName == selectedColor
            cell.configure(with: colorName, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            trackerEmoji = selectedEmoji ?? ""
            emojiCollectionView.reloadData()
        } else if collectionView == colorCollectionView {
            selectedColor = colors[indexPath.item]
            trackerColor = selectedColor
            colorCollectionView.reloadData()
        }
        updateCreateButton()
    }
}

extension TrackerCreateViewController: UICollectionViewDelegateFlowLayout {
    
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
        12
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
}
