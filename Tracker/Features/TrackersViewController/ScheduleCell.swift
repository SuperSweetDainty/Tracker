import UIKit

final class ScheduleCell: UITableViewCell {
    
    static let identifier = "ScheduleCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let toggleSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor(named: "YPBlue")
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    // Callback при изменении состояния переключателя
    var switchChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggleSwitch.leadingAnchor, constant: -16),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(day: Weekday, isOn: Bool) {
        titleLabel.text = day.title
        toggleSwitch.isOn = isOn
    }
    
    @objc private func switchValueChanged() {
        switchChanged?(toggleSwitch.isOn)
    }
}
