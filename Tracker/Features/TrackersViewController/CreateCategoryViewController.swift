import UIKit

final class CreateCategoryViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let categoryTextField = UITextField()
    private let doneButton = UIButton(type: .system)
    private let checkmarkImageView = UIImageView()
    
    // MARK: - Properties
    private let viewModel: CategoryViewModelProtocol
    private var isFormValid = false {
        didSet { updateDoneButtonState() }
    }
    
    // MARK: - Initialization
    init(viewModel: CategoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryTextField.text = ""
        validateForm()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.white
        
        setupCheckmarkView()
        setupTitleLabel()
        setupCategoryTextField()
        setupDoneButton()
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("category.create.title", comment: "Новая категория")
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
    
    private func setupCategoryTextField() {
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.placeholder = NSLocalizedString("category.field.placeholder", comment: "Введите название категории")
        categoryTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        categoryTextField.textColor = UIColor(resource: .ypBlack)
        categoryTextField.backgroundColor = UIColor(red: 0.90, green: 0.91, blue: 0.92, alpha: 0.30)
        categoryTextField.layer.cornerRadius = 16
        categoryTextField.borderStyle = .none
        categoryTextField.delegate = self
        
        // padding left
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        categoryTextField.leftView = paddingView
        categoryTextField.leftViewMode = .always
        
        setupCheckmarkView()
        view.addSubview(categoryTextField)
        
        NSLayoutConstraint.activate([
            categoryTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupCheckmarkView() {
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = UIColor(resource: .ypBlue)
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.isHidden = true
        
        let checkmarkContainer = UIView()
        checkmarkContainer.translatesAutoresizingMaskIntoConstraints = false
        checkmarkContainer.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkmarkContainer.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkmarkContainer.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
            checkmarkContainer.widthAnchor.constraint(equalToConstant: 52),
            checkmarkContainer.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        categoryTextField.rightView = checkmarkContainer
        categoryTextField.rightViewMode = .always
    }
    
    private func setupDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(NSLocalizedString("button.common.done", comment: "Готово"), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = UIColor(resource: .ypGray)
        doneButton.layer.cornerRadius = 16
        doneButton.isEnabled = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Validation
    private func updateDoneButtonState() {
        if isFormValid {
            doneButton.backgroundColor = UIColor(resource: .ypBlack)
            doneButton.isEnabled = true
            checkmarkImageView.isHidden = false
        } else {
            doneButton.backgroundColor = UIColor(resource: .ypGray)
            doneButton.isEnabled = false
            checkmarkImageView.isHidden = true
        }
    }
    
    private func validateForm() {
        let hasText = !(categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        isFormValid = hasText
    }

    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func doneButtonTapped() {
        guard let title = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else { return }
        
        viewModel.createCategory(title: title)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validateForm()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > 38 { return false }
        
        let hasText = !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        isFormValid = hasText
        updateDoneButtonState()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateForm()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CreateCategoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        let textFieldFrame = categoryTextField.convert(categoryTextField.bounds, to: view)
        return !textFieldFrame.contains(location)
    }
}
