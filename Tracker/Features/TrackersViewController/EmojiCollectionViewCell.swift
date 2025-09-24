import UIKit

// MARK: - UIFont Extension
extension UIFont {
    static func emojiTitleFont(size: CGFloat = 32) -> UIFont {
        UIFont.boldSystemFont(ofSize: size)
    }
}

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let emojiLabel = UILabel()
    
    // MARK: - Properties
    static let identifier = "EmojiCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.clear
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = UIFont.emojiTitleFont()
        emojiLabel.textAlignment = .center
        emojiLabel.textColor = UIColor(named: "YPBlack")
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        
        if isSelected {
            contentView.backgroundColor = UIColor(named: "YPGray")?.withAlphaComponent(0.3)
            contentView.layer.cornerRadius = 8
        } else {
            contentView.backgroundColor = UIColor.clear
            contentView.layer.cornerRadius = 0
        }
    }
}
