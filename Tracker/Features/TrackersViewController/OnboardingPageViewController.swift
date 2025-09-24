import UIKit

final class OnboardingPageViewController: UIViewController {
    
    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let pageIndex: Int
    private let titleText: String
    private let backgroundImageName: String
    
    // MARK: - Callback
    var onActionButtonTapped: (() -> Void)?
    
    init(pageIndex: Int, titleText: String, backgroundImageName: String) {
        self.pageIndex = pageIndex
        self.titleText = titleText
        self.backgroundImageName = backgroundImageName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        setupBackgroundImage()
        setupTitleLabel()
        setupActionButton()
    }
    
    private func setupBackgroundImage() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: backgroundImageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = titleText
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.baselineAdjustment = .alignBaselines
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 32.0 / 32.0
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributedString = NSAttributedString(
            string: titleText,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: titleLabel.font ?? UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor(named: "YPBlack") ?? UIColor.black,
                .kern: 0.0
            ]
        )
        titleLabel.attributedText = attributedString
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 105),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupActionButton() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle(NSLocalizedString("onboarding.action", comment: "Кнопка онбординга"), for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        actionButton.backgroundColor = UIColor(named: "YPBlack")
        actionButton.layer.cornerRadius = 16
        actionButton.layer.masksToBounds = true
        
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 19, left: 32, bottom: 19, right: 32)
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        view.addSubview(actionButton)
        
        let screenHeight = UIScreen.main.bounds.height
        let buttonTopSpacing: CGFloat = screenHeight <= 667 ? 120 : 170
        
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: buttonTopSpacing),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func actionButtonTapped() {
        onActionButtonTapped?()
    }
}
