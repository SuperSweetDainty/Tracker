import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let colorView = UIView()
    
    // MARK: - Properties
    static let identifier = "ColorCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with colorName: String, isSelected: Bool) {
        colorView.backgroundColor = UIColor(named: colorName)
        updateSelection(isSelected: isSelected, colorName: colorName)
    }
    
    private func updateSelection(isSelected: Bool, colorName: String) {
        if isSelected {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor(named: colorName)?.withAlphaComponent(0.3).cgColor
            contentView.layer.cornerRadius = 8
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.cornerRadius = 8
        }
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.clear
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 8
        colorView.clipsToBounds = true
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
}
