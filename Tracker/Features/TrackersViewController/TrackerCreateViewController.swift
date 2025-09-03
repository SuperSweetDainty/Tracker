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
    private var trackerColor: UIColor? = UIColor(resource: .ypGreen)
    private var weekDaysForTracker: [Weekday] = []

    private var cells: [(title: String, subtitle: String?)] = [
        ("Категория", "Важное"),
        ("Расписание", nil)
    ]

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
        field.layer.masksToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.delegate = self
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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

    private lazy var stackButtons: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        table.layer.cornerRadius = 16
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return table
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypWhite)
        setupUI()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Button Actions
    private func createTracker() {
        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: trackerColor ?? .gray,
            emoji: "😎",
            schedule: weekDaysForTracker
        )
        delegate?.trackerCreateViewController(self, didCreate: tracker, inCategory: categoryTitle)
        dismiss(animated: true)
    }

    // MARK: - Helpers
    private func updateCreateButton() {
        let hasName = !trackerName.trimmingCharacters(in: .whitespaces).isEmpty
        let hasSchedule = !weekDaysForTracker.isEmpty
        createButton.isEnabled = hasName && hasSchedule
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
        button.layer.masksToBounds = true
        button.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
        return button
    }

    // MARK: - UI Setup
    private func setupUI() {
        [trackerTitleLabel, stackTextFieldView, tableView, stackButtons].forEach { view.addSubview($0) }
    }

    private func setupConstraints() {
        [trackerTitleLabel, stackTextFieldView, textField, tableView, stackButtons].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            trackerTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackerTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            stackTextFieldView.topAnchor.constraint(equalTo: trackerTitleLabel.bottomAnchor, constant: 38),
            stackTextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackTextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: stackTextFieldView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            stackButtons.heightAnchor.constraint(equalToConstant: 60),
            stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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

    // Добавляем скрытие клавиатуры по нажатию "Done"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        if indexPath.row == cells.count - 1 {
            // скрыть нижний разделитель у последней ячейки ("Расписание")
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            // нормальный разделитель
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(resource: .ypBackground)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if cells[indexPath.row].title == "Расписание" {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            scheduleVC.modalPresentationStyle = .automatic
            present(scheduleVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
}
