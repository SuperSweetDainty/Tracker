import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    private let colorView = UIView()
    static let identifier = "ColorCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
    }
    
    func configure(with color: String, isSelected: Bool) {
        colorView.backgroundColor = UIColor(named: color)
        
        if isSelected {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor(named: color)?.withAlphaComponent(0.3).cgColor
            contentView.layer.cornerRadius = 8
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
            contentView.layer.cornerRadius = 0
        }
    }
}
