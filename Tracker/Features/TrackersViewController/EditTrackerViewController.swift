import UIKit

protocol EditTrackerViewControllerDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker, newName: String, newEmoji: String, newColor: String, newSchedule: [Int], newCategory: TrackerCategory?)
}

final class EditTrackerViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let categoryContainerView = UIView()
    private let categoryLabel = UILabel()
    private let categoryArrowImageView = UIImageView()
    private let categoryValueLabel = UILabel()
    private let scheduleLabel = UILabel()
    private let scheduleArrowImageView = UIImageView()
    private let scheduleValueLabel = UILabel()
    private let dividerView = UIView()
    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let characterLimitLabel = UILabel()
    private let categoryAreaView = UIView()
    private let scheduleAreaView = UIView()
    
    // MARK: - Emoji and Color Selection
    private let emojiLabel = UILabel()
    private let emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorLabel = UILabel()
    private let colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Scroll View
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Constraints for animation
    private var categoryLabelTopConstraint: NSLayoutConstraint?
    private var categoryValueLabelTopConstraint: NSLayoutConstraint?
    private var scheduleLabelTopConstraint: NSLayoutConstraint?
    private var scheduleValueLabelTopConstraint: NSLayoutConstraint?
    
    // MARK: - Properties
    private let maxCharacterCount = 38
    private var isFormValid = false {
        didSet {
            updateSaveButtonState()
        }
    }
    private var selectedDays: Set<Int> = []
    private var selectedEmoji: String = "😪"
    private var selectedColor: String = "Green"
    private var selectedCategory: TrackerCategory?
    private var isHeaderHidden = false
    
    // MARK: - Data
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    private let colors = [
        "CollectionColor1", "CollectionColor2", "CollectionColor3", "CollectionColor4", "CollectionColor5", "CollectionColor6",
        "CollectionColor7", "CollectionColor8", "CollectionColor9", "CollectionColor10", "CollectionColor11", "CollectionColor12",
        "CollectionColor13", "CollectionColor14", "CollectionColor15", "CollectionColor16", "CollectionColor17", "CollectionColor18"
    ]
    
    // MARK: - Delegate
    weak var delegate: EditTrackerViewControllerDelegate?
    private let tracker: Tracker
    
    // MARK: - Initialization
    init(tracker: Tracker) {
        self.tracker = tracker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialData()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
        updateUIWithInitialData()
    }
    
    private func setupInitialData() {
        nameTextField.text = tracker.name
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        selectedDays = Set(tracker.schedule)
        let categoryStore = TrackerCategoryStore()
        let categories = categoryStore.fetchCategories()
        selectedCategory = categories.first { category in
            category.trackers.contains { $0.id == tracker.id }
        }
        validateForm()
    }
    
    private func updateUIWithInitialData() {
        if let category = selectedCategory {
            categoryValueLabel.text = category.title
            categoryValueLabel.isHidden = false
        }
        if !selectedDays.isEmpty {
            scheduleValueLabel.text = getScheduleText()
            scheduleValueLabel.isHidden = false
        }
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YPWhite")
        
        setupScrollView()
        setupTitle()
        setupNameTextField()
        setupCategoryContainer()
        setupEmojiSection()
        setupColorSection()
        setupButtons()
        setupCharacterLimitLabel()
    }
    
    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("habit.edit.title", comment: "Редактирование привычки")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
    }
    
    private func setupNameTextField() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.placeholder = NSLocalizedString("habit.name.placeholder", comment: "Плейсхолдер имени трекера")
        nameTextField.font = UIFont.systemFont(ofSize: 17)
        nameTextField.textColor = UIColor(named: "YPBlack")
        nameTextField.backgroundColor = UIColor(named: "YPBackground")
        nameTextField.layer.cornerRadius = 16
        nameTextField.borderStyle = .none
        nameTextField.delegate = self
        nameTextField.isUserInteractionEnabled = true
        nameTextField.isEnabled = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.rightView = rightPaddingView
        nameTextField.rightViewMode = .always
        
        contentView.addSubview(nameTextField)
    }
    
    private func setupCategoryContainer() {
        categoryContainerView.translatesAutoresizingMaskIntoConstraints = false
        categoryContainerView.backgroundColor = UIColor(named: "YPBackground")
        categoryContainerView.layer.cornerRadius = 16
        categoryContainerView.alpha = 1.0
        contentView.addSubview(categoryContainerView)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.text = NSLocalizedString("category.title", comment: "Категория")
        categoryLabel.font = UIFont.systemFont(ofSize: 17)
        categoryLabel.textColor = UIColor(named: "YPBlack")
        categoryContainerView.addSubview(categoryLabel)
        
        categoryArrowImageView.translatesAutoresizingMaskIntoConstraints = false
//        categoryArrowImageView.image = UIImage(systemName: "chevron.right")
        categoryArrowImageView.tintColor = UIColor(named: "YPGray")
        categoryContainerView.addSubview(categoryArrowImageView)
        
        categoryValueLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryValueLabel.text = ""
        categoryValueLabel.font = UIFont.systemFont(ofSize: 17)
        categoryValueLabel.textColor = UIColor(named: "YPGray")
        categoryValueLabel.isHidden = true
        categoryContainerView.addSubview(categoryValueLabel)
        
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = UIColor(named: "YPGray")
        categoryContainerView.addSubview(dividerView)
        
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleLabel.text = NSLocalizedString("schedule.title", comment: "Расписание")
        scheduleLabel.font = UIFont.systemFont(ofSize: 17)
        scheduleLabel.textColor = UIColor(named: "YPBlack")
        categoryContainerView.addSubview(scheduleLabel)
        
        scheduleArrowImageView.translatesAutoresizingMaskIntoConstraints = false
//        scheduleArrowImageView.image = UIImage(systemName: "chevron.right")
        scheduleArrowImageView.tintColor = UIColor(named: "YPGray")
        categoryContainerView.addSubview(scheduleArrowImageView)
        
        scheduleValueLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleValueLabel.text = ""
        scheduleValueLabel.font = UIFont.systemFont(ofSize: 17)
        scheduleValueLabel.textColor = UIColor(named: "YPGray")
        scheduleValueLabel.isHidden = true
        categoryContainerView.addSubview(scheduleValueLabel)
        
        categoryAreaView.translatesAutoresizingMaskIntoConstraints = false
        categoryAreaView.backgroundColor = UIColor.clear
        categoryAreaView.isUserInteractionEnabled = true
        categoryContainerView.addSubview(categoryAreaView)
        
        let categoryAreaTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryAreaView.addGestureRecognizer(categoryAreaTap)
        
        scheduleAreaView.translatesAutoresizingMaskIntoConstraints = false
        scheduleAreaView.backgroundColor = UIColor.clear
        scheduleAreaView.isUserInteractionEnabled = true
        categoryContainerView.addSubview(scheduleAreaView)
        
        let scheduleAreaTap = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        scheduleAreaView.addGestureRecognizer(scheduleAreaTap)
        
        let scheduleTap = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        scheduleLabel.addGestureRecognizer(scheduleTap)
        scheduleLabel.isUserInteractionEnabled = true
    }
    
    private func setupButtons() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(NSLocalizedString("button.cancel", comment: "Отменить"), for: .normal)
        cancelButton.setTitleColor(UIColor(named: "YPRed"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = UIColor(named: "YPWhite")
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "YPRed")?.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle(NSLocalizedString("button.save", comment: "Сохранить"), for: .normal)
        saveButton.setTitleColor(UIColor(named: "YPWhite"), for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.backgroundColor = UIColor(named: "YPBlack")
        saveButton.layer.cornerRadius = 16
        saveButton.isEnabled = true
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.delaysContentTouches = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.isUserInteractionEnabled = true
        scrollView.addSubview(contentView)
    }
    
    private func setupCharacterLimitLabel() {
        characterLimitLabel.translatesAutoresizingMaskIntoConstraints = false
        characterLimitLabel.text = NSLocalizedString("limit.38", comment: "Ограничение длины")
        characterLimitLabel.font = UIFont.systemFont(ofSize: 17)
        characterLimitLabel.textColor = UIColor(named: "YPRed")
        characterLimitLabel.textAlignment = .center
        characterLimitLabel.isHidden = true
        contentView.addSubview(characterLimitLabel)
    }
    
    private func setupEmojiSection() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.text = "Emoji"
        emojiLabel.font = UIFont.boldSystemFont(ofSize: 19)
        emojiLabel.textColor = UIColor(named: "YPBlack")
        emojiLabel.textAlignment = .left
        contentView.addSubview(emojiLabel)
        
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.scrollDirection = .vertical
        emojiLayout.minimumInteritemSpacing = 0
        emojiLayout.minimumLineSpacing = 0
        emojiLayout.itemSize = CGSize(width: 52, height: 52)
        
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.backgroundColor = UIColor.clear
        emojiCollectionView.setCollectionViewLayout(emojiLayout, animated: false)
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.isScrollEnabled = false
        contentView.addSubview(emojiCollectionView)
    }
    
    private func setupColorSection() {
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.text = "Цвет"
        colorLabel.font = UIFont.boldSystemFont(ofSize: 19)
        colorLabel.textColor = UIColor(named: "YPBlack")
        colorLabel.textAlignment = .left
        contentView.addSubview(colorLabel)
        
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.scrollDirection = .vertical
        colorLayout.minimumInteritemSpacing = 0
        colorLayout.minimumLineSpacing = 0
        colorLayout.itemSize = CGSize(width: 52, height: 52)
        
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.backgroundColor = UIColor.clear
        colorCollectionView.setCollectionViewLayout(colorLayout, animated: false)
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.identifier)
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.isScrollEnabled = true
        colorCollectionView.showsVerticalScrollIndicator = false
        contentView.addSubview(colorCollectionView)
    }
    
    private func setupConstraints() {
        categoryLabelTopConstraint = categoryLabel.topAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: 30)
        categoryValueLabelTopConstraint = categoryValueLabel.topAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: 45)
        
        scheduleLabelTopConstraint = scheduleLabel.topAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: 91)
        scheduleValueLabelTopConstraint = scheduleValueLabel.topAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: 106)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -50),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            nameTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameTextField.widthAnchor.constraint(equalToConstant: 343),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            characterLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            characterLimitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            categoryContainerView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            categoryContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            categoryContainerView.widthAnchor.constraint(equalToConstant: 343),
            categoryContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: categoryContainerView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 31),
            emojiCollectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiCollectionView.widthAnchor.constraint(equalToConstant: 312),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 156),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 40),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 30),
            colorCollectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorCollectionView.widthAnchor.constraint(equalToConstant: 312),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 200),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            categoryLabelTopConstraint!,
            categoryLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            
            categoryAreaView.topAnchor.constraint(equalTo: categoryContainerView.topAnchor),
            categoryAreaView.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor),
            categoryAreaView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor),
            categoryAreaView.bottomAnchor.constraint(equalTo: dividerView.topAnchor),
            
            scheduleAreaView.topAnchor.constraint(equalTo: dividerView.bottomAnchor),
            scheduleAreaView.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor),
            scheduleAreaView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor),
            scheduleAreaView.bottomAnchor.constraint(equalTo: categoryContainerView.bottomAnchor),
            
            categoryArrowImageView.centerYAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: 37.5),
            categoryArrowImageView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            categoryArrowImageView.widthAnchor.constraint(equalToConstant: 24),
            categoryArrowImageView.heightAnchor.constraint(equalToConstant: 24),
            
            categoryValueLabelTopConstraint!,
            categoryValueLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            categoryValueLabel.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -40),
            
            dividerView.centerYAnchor.constraint(equalTo: categoryContainerView.centerYAnchor),
            dividerView.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            dividerView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            scheduleLabelTopConstraint!,
            scheduleLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            
            scheduleArrowImageView.centerYAnchor.constraint(equalTo: categoryContainerView.topAnchor, constant: 112.5),
            scheduleArrowImageView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -16),
            scheduleArrowImageView.widthAnchor.constraint(equalToConstant: 24),
            scheduleArrowImageView.heightAnchor.constraint(equalToConstant: 24),
            
            scheduleValueLabelTopConstraint!,
            scheduleValueLabel.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor, constant: 16),
            scheduleValueLabel.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor, constant: -40),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 161),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func updateSaveButtonState() {
        if isFormValid {
            saveButton.backgroundColor = UIColor(named: "YPBlack")
            saveButton.isEnabled = true
        } else {
            saveButton.backgroundColor = UIColor(named: "YPGray")
            saveButton.isEnabled = false
        }
    }
    
    private func validateForm() {
        let hasName = !(nameTextField.text?.isEmpty ?? true)
        let hasSchedule = !selectedDays.isEmpty
        let hasEmoji = !selectedEmoji.isEmpty
        let hasColor = !selectedColor.isEmpty
        let hasCategory = selectedCategory != nil
        isFormValid = hasName && hasSchedule && hasEmoji && hasColor && hasCategory
    }
    
    private func getScheduleText() -> String {
        if selectedDays.isEmpty {
            return ""
        }
        
        let daysOfWeek = [
            NSLocalizedString("weekday.short.1", comment: "Пн"),
            NSLocalizedString("weekday.short.2", comment: "Вт"),
            NSLocalizedString("weekday.short.3", comment: "Ср"),
            NSLocalizedString("weekday.short.4", comment: "Чт"),
            NSLocalizedString("weekday.short.5", comment: "Пт"),
            NSLocalizedString("weekday.short.6", comment: "Сб"),
            NSLocalizedString("weekday.short.7", comment: "Вс")
        ]
        let selectedDayNames = selectedDays.sorted().map { daysOfWeek[$0] }
        
        if selectedDays.count == 7 {
            return NSLocalizedString("schedule.everyday", comment: "Каждый день")
        } else {
            return selectedDayNames.joined(separator: ", ")
        }
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
    }
    
    @objc private func categoryTapped() {
        let categoryVC = CategoryViewController()
        categoryVC.delegate = self
        categoryVC.modalPresentationStyle = .pageSheet
        present(categoryVC, animated: true)
    }
    
    @objc private func scheduleTapped() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.modalPresentationStyle = .pageSheet
        
        scheduleViewController.onScheduleSelected = { [weak self] selectedDays in
            self?.updateScheduleValue(with: selectedDays)
        }
        
        present(scheduleViewController, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        delegate?.didUpdateTracker(
            tracker,
            newName: nameTextField.text ?? "",
            newEmoji: selectedEmoji,
            newColor: selectedColor,
            newSchedule: Array(selectedDays),
            newCategory: selectedCategory
        )
        
        dismiss(animated: true)
    }
    
    private func updateScheduleValue(with days: Set<Int>) {
        selectedDays = days
        
        if selectedDays.isEmpty {
            scheduleValueLabel.isHidden = true
            return
        }
        
        scheduleValueLabel.isHidden = false
        scheduleValueLabel.text = getScheduleText()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.5, animations: {
                self.scheduleLabelTopConstraint?.constant = 95
                self.scheduleValueLabelTopConstraint?.constant = 120
                self.view.layoutIfNeeded()
            })
        }
        
        validateForm()
    }
}

// MARK: - UITextFieldDelegate
extension EditTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > maxCharacterCount {
            characterLimitLabel.isHidden = false
            return false
        } else {
            characterLimitLabel.isHidden = true
        }
        
        validateForm()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateForm()
    }
}

// MARK: - UICollectionViewDataSource
extension EditTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else if collectionView == colorCollectionView {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as! EmojiCollectionViewCell
            let emoji = emojis[indexPath.item]
            let isSelected = emoji == selectedEmoji
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as! ColorCollectionViewCell
            let color = colors[indexPath.item]
            let isSelected = color == selectedColor
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate
extension EditTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            emojiCollectionView.reloadData()
            validateForm()
        } else if collectionView == colorCollectionView {
            selectedColor = colors[indexPath.item]
            colorCollectionView.reloadData()
            validateForm()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EditTrackerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        let textFieldFrame = nameTextField.convert(nameTextField.bounds, to: view)
        
        if textFieldFrame.contains(location) {
            return false
        }
        
        return true
    }
}

// MARK: - UIScrollViewDelegate
extension EditTrackerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        let shouldHideHeader = scrollOffset > 50
        
        if shouldHideHeader != isHeaderHidden {
            isHeaderHidden = shouldHideHeader
            
            UIView.animate(withDuration: 0.3, animations: {
                self.titleLabel.alpha = shouldHideHeader ? 0 : 1
                self.nameTextField.alpha = shouldHideHeader ? 0 : 1
                self.characterLimitLabel.alpha = shouldHideHeader ? 0 : 1
            })
        }
    }
}

// MARK: - CategoryViewControllerDelegate
extension EditTrackerViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        categoryValueLabel.text = category.title
        categoryValueLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.5, animations: {
                self.categoryLabelTopConstraint?.constant = 20
                self.categoryValueLabelTopConstraint?.constant = 45
                self.view.layoutIfNeeded()
            })
        }
        
        validateForm()
    }
}
