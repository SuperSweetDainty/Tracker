import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    private let emojiLabel = UILabel()
    static let identifier = "EmojiCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = .systemFont(ofSize: 32, weight: .bold)
        emojiLabel.textAlignment = .center
        emojiLabel.textColor = UIColor(resource: .ypBlack)
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
            contentView.backgroundColor = UIColor(resource: .ypDarkGray)
            contentView.layer.cornerRadius = 8
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
        }
    }
}
