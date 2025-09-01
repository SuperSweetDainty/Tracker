import UIKit

final class CustomTableViewCell: UITableViewCell {
    static let identifier = "CustomTableViewCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(named: "YPBlack")
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "YPGray")
        label.numberOfLines = 1
        return label
    }()

    private lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func setup() {
        contentView.addSubview(titleStack)
        selectionStyle = .none

        titleStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56)
        ])
    }

    // MARK: - Configure
    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle == nil)
    }
}
