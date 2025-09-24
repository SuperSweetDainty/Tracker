import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let headerLabel = UILabel()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let daysLabel = UILabel()
    private let completionButton = UIButton(type: .system)
    
    // MARK: - Properties
    static let identifier = "TrackerCell"
    private var tracker: Tracker?
    private var selectedDate: Date = Date()
    var onCompletionToggled: ((Tracker) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        
        // Добавляем контекстное меню для долгого нажатия на цветную часть
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        containerView.addInteraction(contextMenuInteraction)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.boldSystemFont(ofSize: 19)
        headerLabel.textColor = UIColor(named: "YPBlack")
        headerLabel.textAlignment = .left
        contentView.addSubview(headerLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.clear.cgColor
        contentView.addSubview(containerView)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = UIFont.systemFont(ofSize: 16)
        emojiLabel.textAlignment = .left
        containerView.addSubview(emojiLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines = 2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 18.0 / 12.0
        nameLabel.attributedText = NSAttributedString(
            string: nameLabel.text ?? "",
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: nameLabel.font ?? UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.white
            ]
        )
        
        containerView.addSubview(nameLabel)
        
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = UIColor(named: "YPBlack")
        daysLabel.textAlignment = .left
        contentView.addSubview(daysLabel)
        
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        completionButton.layer.cornerRadius = 17

        completionButton.isUserInteractionEnabled = true
        completionButton.layer.zPosition = 999
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(completionButtonTapped))
        completionButton.addGestureRecognizer(tapGesture)
        
        contentView.addSubview(completionButton)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            headerLabel.heightAnchor.constraint(equalToConstant: 18),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            daysLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            completionButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            completionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            completionButton.widthAnchor.constraint(equalToConstant: 34),
            completionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func completionButtonTapped() {
        guard let tracker = tracker else {
            return
        }
        
        // Проверяем, не пытается ли пользователь выполнить привычку заранее
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: selectedDate)
        
        if selectedDay > today {
            // Показываем анимацию "запрета" для будущих дат
            showDenialAnimation()
            return
        }

        AnalyticsManager.shared.trackButtonClick(screen: "Main", item: "track")
        
        onCompletionToggled?(tracker)
    }
    
    // MARK: - Animation
    private func showDenialAnimation() {
        // Анимация покачивания влево-вправо
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        shakeAnimation.duration = 0.5
        shakeAnimation.values = [-10, 10, -8, 8, -5, 5, 0]
        
        completionButton.layer.add(shakeAnimation, forKey: "shake")
        
        // Небольшая вибрация (если доступна)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    
    func configure(with tracker: Tracker, selectedDate: Date, isCompleted: Bool, completedCount: Int) {
        self.tracker = tracker
        self.selectedDate = selectedDate
        

        headerLabel.isHidden = true
        
        emojiLabel.text = tracker.emoji
        
        nameLabel.text = tracker.name
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 18.0 / 12.0
        nameLabel.attributedText = NSAttributedString(
            string: tracker.name,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: nameLabel.font ?? UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.white
            ]
        )
        
        daysLabel.text = getDayText(for: completedCount)
        
        containerView.backgroundColor = UIColor(named: tracker.color) ?? UIColor(named: "YPGreen")
        
        updateCompletionButton(isCompleted: isCompleted)
    }
    
    func configure(with category: TrackerCategory, selectedDate: Date, isCompleted: Bool, completedCount: Int) {
        self.selectedDate = selectedDate
        
        headerLabel.isHidden = false
        headerLabel.text = category.title
        
        if let firstTracker = category.trackers.first {
            self.tracker = firstTracker
            emojiLabel.text = firstTracker.emoji
            nameLabel.text = firstTracker.name
            containerView.backgroundColor = UIColor(named: firstTracker.color) ?? UIColor(named: "YPGreen")
        }
        
        daysLabel.text = getDayText(for: completedCount)
        
        updateCompletionButton(isCompleted: isCompleted)
    }
    
    private func updateCompletionButton(isCompleted: Bool) {
        
        let cellColor = UIColor(named: tracker?.color ?? "YPGreen") ?? UIColor.systemGreen
        
        if isCompleted {

            completionButton.setImage(nil, for: .normal)
            completionButton.setTitle("✓", for: .normal)
            completionButton.setTitleColor(UIColor(named: "YPWhite"), for: .normal)
            completionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            completionButton.backgroundColor = cellColor.withAlphaComponent(0.3)
            completionButton.alpha = 1.0
        } else {

            completionButton.setImage(nil, for: .normal)
            completionButton.setTitle("+", for: .normal)
            completionButton.setTitleColor(UIColor(named: "YPWhite"), for: .normal)
            completionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .light)
            completionButton.backgroundColor = cellColor
            completionButton.alpha = 1.0
        }
        
        completionButton.isHidden = false
        
        completionButton.layoutIfNeeded()
        contentView.layoutIfNeeded()
    }
    
    private func getDayText(for count: Int) -> String {
        let format = NSLocalizedString("days.count", comment: "N дней (плюрализация)")
        return String.localizedStringWithFormat(format, count)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let tracker = tracker else { return nil }
        
        return UIContextMenuConfiguration(
            identifier: tracker.id as NSCopying,
            previewProvider: { [weak self] in
                return nil
            },
            actionProvider: { [weak self] _ in
                guard let self = self, let tracker = self.tracker else { return nil }
                
                let editAction = UIAction(
                    title: NSLocalizedString("action.edit", comment: "Редактировать")
                ) { _ in
                    NotificationCenter.default.post(
                        name: NSNotification.Name("TrackerEditRequested"),
                        object: tracker
                    )
                }
                
                let deleteAction = UIAction(
                    title: NSLocalizedString("action.delete", comment: "Удалить"),
                    attributes: .destructive
                ) { _ in
                    NotificationCenter.default.post(
                        name: NSNotification.Name("TrackerDeleteRequested"),
                        object: tracker
                    )
                }
                
                return UIMenu(children: [editAction, deleteAction])
            }
        )
    }
}
