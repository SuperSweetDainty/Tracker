import UIKit

protocol EditCategoryViewControllerDelegate: AnyObject {
    func didUpdateCategory(_ category: TrackerCategory, newTitle: String)
}

final class EditCategoryViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let categoryTextField = UITextField()
    private let doneButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let category: TrackerCategory
    weak var delegate: EditCategoryViewControllerDelegate?
    private var isFormValid = false {
        didSet {
            updateDoneButtonState()
        }
    }
    
    // MARK: - Initialization
    init(category: TrackerCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YPWhite")
        
        setupTitle()
        setupCategoryTextField()
        setupDoneButton()
    }
    
    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("category.edit.title", comment: "Редактирование категории")
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
    
    private func setupCategoryTextField() {
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.text = category.title
        categoryTextField.font = UIFont.systemFont(ofSize: 17)
        categoryTextField.textColor = UIColor(named: "YPBlack")
        categoryTextField.backgroundColor = UIColor(named: "YPBackground")
        categoryTextField.layer.cornerRadius = 16
        categoryTextField.borderStyle = .none
        categoryTextField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        categoryTextField.leftView = paddingView
        categoryTextField.leftViewMode = .always
        
        setupClearButton()
        
        view.addSubview(categoryTextField)
        
        NSLayoutConstraint.activate([
            categoryTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupClearButton() {
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("×", for: .normal)
        clearButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        clearButton.backgroundColor = UIColor.clear
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        clearButton.isHidden = categoryTextField.text?.isEmpty ?? true
        
        let clearContainer = UIView()
        clearContainer.translatesAutoresizingMaskIntoConstraints = false
        clearContainer.addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            clearButton.centerXAnchor.constraint(equalTo: clearContainer.centerXAnchor),
            clearButton.centerYAnchor.constraint(equalTo: clearContainer.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 30),
            clearButton.heightAnchor.constraint(equalToConstant: 30),
            clearContainer.widthAnchor.constraint(equalToConstant: 52),
            clearContainer.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        categoryTextField.rightView = clearContainer
        categoryTextField.rightViewMode = .whileEditing
    }
    
    private func setupDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(NSLocalizedString("button.done", comment: "Готово"), for: .normal)
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = UIColor(named: "YPGray")
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
        
        validateForm()
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Private Methods
    private func updateDoneButtonState() {
        if isFormValid {
            doneButton.backgroundColor = UIColor(named: "YPBlack")
            doneButton.isEnabled = true
        } else {
            doneButton.backgroundColor = UIColor(named: "YPGray")
            doneButton.isEnabled = false
        }
    }
    
    private func validateForm() {
        let hasText = !(categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isDifferent = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != category.title
        isFormValid = hasText && isDifferent
        
        clearButton.isHidden = categoryTextField.text?.isEmpty ?? true
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func clearButtonTapped() {
        categoryTextField.text = ""
        validateForm()
    }
    
    @objc private func doneButtonTapped() {
        guard let newTitle = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !newTitle.isEmpty,
              newTitle != category.title else {
            return
        }
        
        delegate?.didUpdateCategory(category, newTitle: newTitle)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditCategoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validateForm()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count > 50 {
            return false
        }
        
        let hasText = !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isDifferent = newText.trimmingCharacters(in: .whitespacesAndNewlines) != category.title
        isFormValid = hasText && isDifferent
        updateDoneButtonState()
        
        clearButton.isHidden = newText.isEmpty
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateForm()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EditCategoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        let textFieldFrame = categoryTextField.convert(categoryTextField.bounds, to: view)
        
        if textFieldFrame.contains(location) {
            return false
        }
        
        return true
    }
}
