import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func categoryViewController(_ controller: CategoryViewController, didSelectCategory category: String)
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
    private var contextMenuView: CategoryContextMenuView?
    private var dimmingView: UIView?
    weak var delegate: CategoryViewControllerDelegate?

    // MARK: - Initialization
    init(viewModel: CategoryViewModelProtocol = CategoryViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadCategories()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        setupTitle()
        setupTableView()
        setupAddButton()
        setupEmptyState()
    }

    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Категория"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(resource: .ypBlack)
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
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    private func setupAddButton() {
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.setTitleColor(.white, for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.backgroundColor = UIColor(resource: .ypBlack)
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
        emptyStateImageView.image = UIImage(resource: .star)
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateImageView.isHidden = true
        view.addSubview(emptyStateImageView)

        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "Привычки и события можно\nобъединить по смыслу"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12)
        emptyStateLabel.textColor = UIColor(resource: .ypBlack)
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
    }

    private func updateUI() {
        let hasCategories = !viewModel.categories.isEmpty
        tableView.isHidden = !hasCategories
        emptyStateImageView.isHidden = hasCategories
        emptyStateLabel.isHidden = hasCategories
        tableView.reloadData()
    }

    @objc private func addCategoryButtonTapped() {
        let createVC = CreateCategoryViewController(viewModel: viewModel)
        createVC.modalPresentationStyle = .pageSheet
        present(createVC, animated: true)
    }

    // MARK: - Context Menu
    private func showContextMenu(for category: TrackerCategory, at indexPath: IndexPath) {
        hideContextMenu()
        
        // Получаем ячейку
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let cellFrameInView = tableView.convert(cell.frame, to: view)

        // Создаем блюр
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds

        // Маска с отверстием под ячейку
        let path = UIBezierPath(rect: blurView.bounds)
        let holePath = UIBezierPath(roundedRect: cellFrameInView, cornerRadius: 12)
        path.append(holePath)
        path.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        blurView.layer.mask = maskLayer

        // Добавляем блюр
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

        let cellBottomY = cellFrameInView.maxY
        NSLayoutConstraint.activate([
            menu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            menu.topAnchor.constraint(equalTo: view.topAnchor, constant: cellBottomY + 8)
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
        viewModel.categories.count
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
        viewModel.selectCategory(category)
        delegate?.categoryViewController(self, didSelectCategory: category.title)
        dismiss(animated: true)
    }
}

// MARK: - CategoryContextMenuViewDelegate
extension CategoryViewController: CategoryContextMenuViewDelegate {

    func didTapEdit(_ category: TrackerCategory) {
        hideContextMenu()
        
        let editVC = EditCategoryViewController(category: category)
        editVC.delegate = self
        editVC.modalPresentationStyle = .pageSheet
        present(editVC, animated: true)
    }

    func didTapDelete(_ category: TrackerCategory) {
        hideContextMenu()
        viewModel.deleteCategory(category)
    }
}

extension CategoryViewController: EditCategoryViewControllerDelegate {
    func didUpdateCategory(_ category: TrackerCategory, newTitle: String) {
        viewModel.updateCategoryTitle(category, newTitle: newTitle)
        tableView.reloadData()
        hideContextMenu()
    }
}
