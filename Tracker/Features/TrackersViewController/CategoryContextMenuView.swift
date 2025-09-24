import UIKit

protocol CategoryContextMenuViewDelegate: AnyObject {
    func didTapEditCategory(_ category: TrackerCategory)
    func didTapDeleteCategory(_ category: TrackerCategory)
}

final class CategoryContextMenuView: UIView {
    
    private let containerView = UIView()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let separatorView = UIView()
    
    weak var delegate: CategoryContextMenuViewDelegate?
    private var category: TrackerCategory?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(named: "YPLight Gray")
        containerView.layer.cornerRadius = 13
        addSubview(containerView)
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle(NSLocalizedString("category.context.edit", comment: ""), for: .normal)
        editButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        editButton.backgroundColor = .clear
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        containerView.addSubview(editButton)
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor(named: "Gray")?.withAlphaComponent(0.3)
        containerView.addSubview(separatorView)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle(NSLocalizedString("category.context.delete", comment: ""), for: .normal)
        deleteButton.setTitleColor(UIColor(named: "YPRed"), for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        deleteButton.backgroundColor = .clear
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 250),
            containerView.heightAnchor.constraint(equalToConstant: 96),
            
            editButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            editButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            editButton.heightAnchor.constraint(equalToConstant: 48),
            
            separatorView.topAnchor.constraint(equalTo: editButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            deleteButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func configure(with category: TrackerCategory) {
        self.category = category
    }
    
    @objc private func editButtonTapped() {
        guard let category = category else { return }
        delegate?.didTapEditCategory(category)
    }
    
    @objc private func deleteButtonTapped() {
        guard let category = category else { return }
        delegate?.didTapDeleteCategory(category)
    }
}
