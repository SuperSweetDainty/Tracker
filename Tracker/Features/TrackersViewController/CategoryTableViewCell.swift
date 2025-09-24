import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let mainContainer = UIView()
    private let nameLabel = UILabel()
    private let tickImageView = UIImageView()
    
    // MARK: - Properties
    static let identifier = "CategoryCell"
    var onLongPress: ((TrackerCategory) -> Void)?
    private var category: TrackerCategory?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUIComponents() {
        backgroundColor = .clear
        selectionStyle = .none
        
        mainContainer.translatesAutoresizingMaskIntoConstraints = false
        mainContainer.backgroundColor = UIColor(named: "YPBackground")
        mainContainer.layer.cornerRadius = 16
        contentView.addSubview(mainContainer)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        longPressGesture.minimumPressDuration = 0.5
        mainContainer.addGestureRecognizer(longPressGesture)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        nameLabel.textColor = UIColor(named: "YPBlack")
        nameLabel.numberOfLines = 1
        mainContainer.addSubview(nameLabel)
        
        tickImageView.translatesAutoresizingMaskIntoConstraints = false
        tickImageView.image = UIImage(systemName: "checkmark")
        tickImageView.tintColor = UIColor(named: "YPBlue")
        tickImageView.contentMode = .scaleAspectFit
        tickImageView.isHidden = true
        mainContainer.addSubview(tickImageView)
        
        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            mainContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            mainContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainContainer.heightAnchor.constraint(equalToConstant: 75),
            
            nameLabel.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: mainContainer.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: tickImageView.leadingAnchor, constant: -16),
            
            tickImageView.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -16),
            tickImageView.centerYAnchor.constraint(equalTo: mainContainer.centerYAnchor),
            tickImageView.widthAnchor.constraint(equalToConstant: 24),
            tickImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Configuration
    func configure(with category: TrackerCategory, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        nameLabel.text = category.title
        tickImageView.isHidden = !isSelected
        self.category = category
        
        mainContainer.subviews.forEach { subview in
            if subview != nameLabel && subview != tickImageView {
                subview.removeFromSuperview()
            }
        }
        
        if isFirst && isLast {
            mainContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                 .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            mainContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            mainContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            mainContainer.layer.maskedCorners = []
        }
        
        if !isLast {
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = UIColor(named: "YPGray")
            mainContainer.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        tickImageView.isHidden = true
        category = nil
    }
    
    // MARK: - Actions
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began, let category = category {
            onLongPress?(category)
        }
    }
}
