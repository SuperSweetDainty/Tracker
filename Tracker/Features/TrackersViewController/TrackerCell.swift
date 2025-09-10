import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseId = "TrackerCell"

    // MARK: - UI

    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        return view
    }()

    private lazy var emojiContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        return label
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.backgroundColor = UIColor(resource: .ypWhite)
        return button
    }()

    private var onToggleComplete: (() -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI

    private func setupUI() {
        contentView.addSubview(cardView)
        contentView.addSubview(bottomView)

        cardView.addSubview(emojiContainer)
        cardView.addSubview(titleLabel)
        emojiContainer.addSubview(emojiLabel)

        bottomView.addSubview(counterLabel)
        bottomView.addSubview(completeButton)

        [cardView, emojiContainer, emojiLabel, titleLabel, bottomView, counterLabel, completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // Card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            // Bottom
            bottomView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 58),

            // Complete button
            completeButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            completeButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),

            // Counter label
            counterLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            counterLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),

            // Emoji container
            emojiContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiContainer.widthAnchor.constraint(equalToConstant: 24),
            emojiContainer.heightAnchor.constraint(equalToConstant: 24),

            // Emoji label
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),

            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])

        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
    }

    // MARK: - Configure

    func configure(with tracker: Tracker, completed: Bool, counter: Int, onToggle: @escaping () -> Void) {
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        counterLabel.text = "\(counter) " + (counter == 1 ? "день" : "дней")
        cardView.backgroundColor = tracker.uiColor
        completeButton.backgroundColor = completed ? tracker.uiColor.withAlphaComponent(0.3) : tracker.uiColor
        completeButton.setImage(UIImage(systemName: completed ? "checkmark" : "plus"), for: .normal)
        onToggleComplete = onToggle
    }

    @objc private func completeTapped() {
        onToggleComplete?()
    }
}
