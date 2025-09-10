import UIKit


final class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let colorView = UIView()
    static let identifier = "ColorCell"
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
    }
    
    // MARK: - Public Methods
    
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
    
    // MARK: - Private Methods
    
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
}
