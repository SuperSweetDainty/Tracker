import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let containerView = UIView()
    private let tableView = UITableView()
    private let doneButton = UIButton(type: .system)
    
    // MARK: - Data
    private let daysOfWeek = [
        NSLocalizedString("weekday.1", comment: "Понедельник"),
        NSLocalizedString("weekday.2", comment: "Вторник"),
        NSLocalizedString("weekday.3", comment: "Среда"),
        NSLocalizedString("weekday.4", comment: "Четверг"),
        NSLocalizedString("weekday.5", comment: "Пятница"),
        NSLocalizedString("weekday.6", comment: "Суббота"),
        NSLocalizedString("weekday.7", comment: "Воскресенье")
    ]
    
    private var selectedDays: Set<Int> = []
    
    // MARK: - Callback
    var onScheduleSelected: ((Set<Int>) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDoneButtonState()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YPWhite")
        setupHeader()
        setupContainer()
        setupDoneButton()
    }
    
    private func setupHeader() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("schedule.title", comment: "Расписание")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(named: "YPBackground")
        containerView.layer.cornerRadius = 16
        view.addSubview(containerView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.0)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 525),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(NSLocalizedString("button.done", comment: "Готово"), for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        doneButton.layer.cornerRadius = 16
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 19, left: 32, bottom: 19, right: 32)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 50),
            doneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        onScheduleSelected?(selectedDays)
        dismiss(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let dayIndex = sender.tag
        if sender.isOn {
            selectedDays.insert(dayIndex)
        } else {
            selectedDays.remove(dayIndex)
        }
        updateDoneButtonState()
    }
    
    private func updateDoneButtonState() {
        let hasSelectedDays = !selectedDays.isEmpty
        doneButton.isEnabled = hasSelectedDays
        doneButton.backgroundColor = hasSelectedDays ? UIColor(named: "YPBlack") : UIColor(named: "YPGray")
        doneButton.setTitleColor(hasSelectedDays ? UIColor(named: "YPWhite") : UIColor(named: "YPGray"), for: .normal)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
        cell.textLabel?.text = daysOfWeek[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(named: "YPBlack")
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == daysOfWeek.count - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.maskedCorners = []
        }
        
        let switchView = UISwitch()
        switchView.tag = indexPath.row
        switchView.isOn = selectedDays.contains(indexPath.row)
        switchView.onTintColor = UIColor(named: "Blue")
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == daysOfWeek.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
}
