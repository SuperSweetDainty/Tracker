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

    private var isFormValid: Bool = false {
        didSet { updateDoneButtonAppearance() }
    }

    // MARK: - Init
    init(category: TrackerCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupKeyboardDismiss()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryTextField.becomeFirstResponder()
    }

    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .white
        setupTitleLabel()
        setupTextField()
        setupDoneButton()
    }

    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("category.update.title", comment: "Редактирование категории")
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(resource: .ypBlack)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    private func setupTextField() {
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryTextField.text = category.title
        categoryTextField.font = .systemFont(ofSize: 17)
        categoryTextField.textColor = UIColor(resource: .ypBlack)
        categoryTextField.backgroundColor = UIColor(resource: .ypLightGray) .withAlphaComponent(0.3)
        categoryTextField.layer.cornerRadius = 16
        categoryTextField.delegate = self
        categoryTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        categoryTextField.leftViewMode = .always
        categoryTextField.placeholder = NSLocalizedString("category.field.placeholder", comment: "Введите название категории")

        categoryTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        clearButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        clearButton.setTitleColor(UIColor(resource: .ypBlack), for: .normal)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.isHidden = categoryTextField.text?.isEmpty ?? true

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(clearButton)

        NSLayoutConstraint.activate([
            clearButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            clearButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 30),
            clearButton.heightAnchor.constraint(equalToConstant: 30),
            container.widthAnchor.constraint(equalToConstant: 52),
            container.heightAnchor.constraint(equalToConstant: 75)
        ])

        categoryTextField.rightView = container
        categoryTextField.rightViewMode = .whileEditing
    }

    private func setupDoneButton() {
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(NSLocalizedString("button.common.done", comment: "Готово"), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor.systemGray
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

        validateTextField()
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    // MARK: - Private Helpers
    private func updateDoneButtonAppearance() {
        doneButton.isEnabled = isFormValid
        doneButton.backgroundColor = isFormValid ? UIColor(resource: .ypBlack) : UIColor.systemGray
    }

    private func validateTextField() {
        let trimmedText = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasContent = !trimmedText.isEmpty
        let changed = trimmedText != category.title
        isFormValid = hasContent && changed
        clearButton.isHidden = trimmedText.isEmpty
    }

    // MARK: - Actions
    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func clearTextField() {
        categoryTextField.text = ""
        validateTextField()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        validateTextField()
    }

    @objc private func doneButtonTapped() {
        let trimmedText = categoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmedText.isEmpty, trimmedText != category.title else { return }
        delegate?.didUpdateCategory(category, newTitle: trimmedText)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditCategoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) { validateTextField() }

    func textFieldDidEndEditing(_ textField: UITextField) { validateTextField() }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        let updated = (current as NSString).replacingCharacters(in: range, with: string)
        if updated.count > 38 { return false }
        validateTextField()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EditCategoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: view)
        let textFieldFrame = categoryTextField.convert(categoryTextField.bounds, to: view)
        return !textFieldFrame.contains(touchPoint)
    }
}
