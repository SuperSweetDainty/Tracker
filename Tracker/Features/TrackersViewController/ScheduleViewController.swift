import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Weekday])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private var selectedDays: Set<Weekday> = []
    
    // MARK: - Text constants
    private let scheduleTitleText = "Расписание"
    private let doneText = "Готово"
    
    // MARK: - UI
    private lazy var scheduleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = scheduleTitleText
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        table.layer.cornerRadius = 16
        table.backgroundColor = UIColor(resource: .ypBackground)
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.separatorStyle = .singleLine
        table.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.5))
        table.tableFooterView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 0.5))
        return table
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(doneText, for: .normal)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        let sortedDays = Weekday.allCases.filter { selectedDays.contains($0) }
        delegate?.scheduleViewController(self, didSelectDays: sortedDays)
        dismiss(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = Weekday.allCases[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        view.addSubview(scheduleTitleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            scheduleTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            scheduleTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            tableView.topAnchor.constraint(equalTo: scheduleTitleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - UITableView
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let day = Weekday.allCases[indexPath.row]
        cell.configure(day: day, isOn: selectedDays.contains(day))
        cell.switchChanged = { [weak self] isOn in
            if isOn {
                self?.selectedDays.insert(day)
            } else {
                self?.selectedDays.remove(day)
            }
        }
        
        cell.backgroundColor = UIColor(resource: .ypBackground)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
