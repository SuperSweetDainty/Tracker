import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

protocol CategoryViewControllerContextMenuDelegate: AnyObject {
    func didTapEditCategory(_ category: TrackerCategory)
    func didTapDeleteCategory(_ category: TrackerCategory)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let addCategoryButton = UIButton(type: .system)
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()
    
    // MARK: - Properties
    private var viewModel: CategoryViewModelProtocol
    weak var delegate: CategoryViewControllerDelegate?
    weak var contextMenuDelegate: CategoryViewControllerContextMenuDelegate?
    private var contextMenuView: CategoryContextMenuView?
    private var dimmingView: UIView?
    
    // MARK: - Initialization
    init(viewModel: CategoryViewModelProtocol = CategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadCategories()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YPWhite")
        
        setupTitle()
        setupTableView()
        setupAddButton()
        setupEmptyState()
    }
    
    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("category.title", comment: "Категория")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
    }
    
    private func setupAddButton() {
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.setTitle(NSLocalizedString("category.add.button", comment: "Добавить категорию"), for: .normal)
        addCategoryButton.setTitleColor(UIColor(named: "YPWhite"), for: .normal)
        addCategoryButton.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.backgroundColor = UIColor(named: "YPBlack")
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.contentEdgeInsets = UIEdgeInsets(top: 19, left: 32, bottom: 19, right: 32)
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        view.addSubview(addCategoryButton)
        

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.image = UIImage(named: "StarImage")
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateImageView.isHidden = true
        view.addSubview(emptyStateImageView)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = NSLocalizedString("category.empty", comment: "Пустое состояние категорий")
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12)
        emptyStateLabel.textColor = UIColor(named: "YPBlack")
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        
        viewModel.onCategorySelected = { [weak self] category in
        }
        
        viewModel.onCategoryCreated = { [weak self] category in
            DispatchQueue.main.async {
                self?.viewModel.selectCategory(category)
            }
        }
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        let hasCategories = !viewModel.categories.isEmpty
        tableView.isHidden = !hasCategories
        emptyStateImageView.isHidden = hasCategories
        emptyStateLabel.isHidden = hasCategories
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addCategoryButtonTapped() {
        let createCategoryVC = CreateCategoryViewController(viewModel: viewModel)
        createCategoryVC.modalPresentationStyle = .pageSheet
        present(createCategoryVC, animated: true)
    }
    
    // MARK: - Context Menu
    private func showContextMenu(for category: TrackerCategory, at indexPath: IndexPath) {
        hideContextMenu()
        
        // Получаем ячейку
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let cellFrameInView = tableView.convert(cell.frame, to: view)

        // Создаем блюр с отверстием под ячейку
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds

        let path = UIBezierPath(rect: blurView.bounds)
        let holePath = UIBezierPath(roundedRect: cellFrameInView, cornerRadius: 16)
        path.append(holePath)
        path.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        blurView.layer.mask = maskLayer

        view.addSubview(blurView)
        dimmingView = blurView

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideContextMenu))
        blurView.addGestureRecognizer(tapGesture)

        // Создаем меню
        let menu = CategoryContextMenuView()
        menu.delegate = self
        menu.configure(with: category)
        menu.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menu)

        NSLayoutConstraint.activate([
            menu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            menu.topAnchor.constraint(equalTo: view.topAnchor, constant: cellFrameInView.maxY + 8)
        ])

        contextMenuView = menu
    }

    @objc private func hideContextMenu() {
        contextMenuView?.removeFromSuperview()
        contextMenuView = nil
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }
}
// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as! CategoryTableViewCell
        
        let category = viewModel.categories[indexPath.row]
        let isSelected = viewModel.selectedCategory?.title == category.title
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == viewModel.categories.count - 1
        cell.configure(with: category, isSelected: isSelected, isFirst: isFirst, isLast: isLast)
        
        cell.onLongPress = { [weak self] category in
            self?.showContextMenu(for: category, at: indexPath)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
        delegate?.didSelectCategory(category)
        dismiss(animated: true)
    }
}

// MARK: - CategoryContextMenuViewDelegate
extension CategoryViewController: CategoryContextMenuViewDelegate {
    func didTapEditCategory(_ category: TrackerCategory) {
        hideContextMenu()
        
        let editCategoryVC = EditCategoryViewController(category: category)
        editCategoryVC.delegate = self
        editCategoryVC.modalPresentationStyle = .pageSheet
        present(editCategoryVC, animated: true)
    }
    
    func didTapDeleteCategory(_ category: TrackerCategory) {
        hideContextMenu()
        
        let alert = UIAlertController(
            title: NSLocalizedString("category.delete.alert.title", comment: "Удалить категорию?"),
            message: NSLocalizedString("category.delete.alert.message", comment: "Сообщение удаления категории"),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("action.cancel", comment: "Отмена"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("action.delete", comment: "Удалить"), style: .destructive) { [weak self] _ in
            AnalyticsManager.shared.trackCategoryDeleted(categoryName: category.title)
            self?.viewModel.deleteCategory(category)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - EditCategoryViewControllerDelegate
extension CategoryViewController: EditCategoryViewControllerDelegate {
    func didUpdateCategory(_ category: TrackerCategory, newTitle: String) {
        AnalyticsManager.shared.trackCategoryEdited(oldName: category.title, newName: newTitle)
        viewModel.updateCategoryTitle(category, newTitle: newTitle)
    }
}
