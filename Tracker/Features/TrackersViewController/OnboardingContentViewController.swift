import UIKit

final class OnboardingContentViewController: UIViewController {
    
    // MARK: - UI
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let actionButton = UIButton()
    
    // MARK: - Properties
    private let index: Int
    private let text: String
    private let imageName: String
    private let pageControl = UIPageControl()
    
    // Callback
    var onAction: (() -> Void)?
    
    // MARK: - Init
    init(index: Int, text: String, imageName: String) {
        self.index = index
        self.text = text
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Setup
private extension OnboardingContentViewController {
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        configureImageView()
        configureTitleLabel()
        configureButton()
    }
    
    func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = text
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(resource: .ypBlack)
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func configureButton() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle(NSLocalizedString("onboarding.button.start", comment: "Вот это технологии!"), for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        actionButton.backgroundColor = UIColor.ypBlack
        actionButton.layer.cornerRadius = 16
        actionButton.layer.masksToBounds = true
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 19, left: 32, bottom: 19, right: 32)
        actionButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func didTapButton() {
        onAction?()
    }
}
