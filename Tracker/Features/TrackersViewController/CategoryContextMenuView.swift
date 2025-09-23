import UIKit

protocol CategoryContextMenuViewDelegate: AnyObject {
    func didTapEdit(_ category: TrackerCategory)
    func didTapDelete(_ category: TrackerCategory)
}

final class CategoryContextMenuView: UIView {
    
    // MARK: - UI
    private let backgroundContainer = UIView()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let separator = UIView()
    
    // MARK: - Properties
    weak var delegate: CategoryContextMenuViewDelegate?
    private var category: TrackerCategory?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupLayout() {
        backgroundColor = .clear
        
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainer.backgroundColor = .secondarySystemBackground
        backgroundContainer.layer.cornerRadius = 12
        addSubview(backgroundContainer)
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle(
            NSLocalizedString("category.menu.edit", comment: "Редактировать"),
            for: .normal
        )
        editButton.setTitleColor(.label, for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 17)
        editButton.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        backgroundContainer.addSubview(editButton)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        backgroundContainer.addSubview(separator)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle(
            NSLocalizedString("category.menu.delete", comment: "Удалить"),
            for: .normal
        )
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 17)
        deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        backgroundContainer.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            backgroundContainer.topAnchor.constraint(equalTo: topAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundContainer.widthAnchor.constraint(equalToConstant: 250),
            backgroundContainer.heightAnchor.constraint(equalToConstant: 96),
            
            editButton.topAnchor.constraint(equalTo: backgroundContainer.topAnchor),
            editButton.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 48),
            
            separator.topAnchor.constraint(equalTo: editButton.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            
            deleteButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor)
        ])
    }
    
    // MARK: - Config
    func configure(with category: TrackerCategory) {
        self.category = category
    }
    
    // MARK: - Actions
    @objc private func handleEdit() {
        guard let category = category else { return }
        delegate?.didTapEdit(category)
    }
    
    @objc private func handleDelete() {
        guard let category = category else { return }
        delegate?.didTapDelete(category)
    }
}
