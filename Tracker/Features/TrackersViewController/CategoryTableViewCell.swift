import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    // MARK: - UI
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    // MARK: - Properties
    static let identifier = "CategoryTableViewCell"
    var onLongPress: ((TrackerCategory) -> Void)?
    private var category: TrackerCategory?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        addLongPressGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(resource: .ypGray).withAlphaComponent(0.15)
        containerView.layer.cornerRadius = 16
        contentView.addSubview(containerView)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor(resource: .ypBlack)
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
        
        // Checkmark
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = UIColor(resource: .ypBlue)
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.isHidden = true
        containerView.addSubview(checkmarkImageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 75),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -16),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func addLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gesture.minimumPressDuration = 0.5
        containerView.addGestureRecognizer(gesture)
    }
    
    // MARK: - Configure
    func configure(with category: TrackerCategory, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        titleLabel.text = category.title
        checkmarkImageView.isHidden = !isSelected
        self.category = category
        
        // Скругляем углы в зависимости от позиции
        if isFirst && isLast {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                 .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            containerView.layer.maskedCorners = []
        }
        
        // Добавляем разделитель, если не последняя
        containerView.subviews.forEach {
            if $0.tag == 999 { $0.removeFromSuperview() }
        }
        
        if !isLast {
            let separator = UIView()
            separator.tag = 999
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = UIColor(resource: .ypGray).withAlphaComponent(0.3)
            containerView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        checkmarkImageView.isHidden = true
        category = nil
    }
    
    // MARK: - Actions
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began, let category = category {
            onLongPress?(category)
        }
    }
}
