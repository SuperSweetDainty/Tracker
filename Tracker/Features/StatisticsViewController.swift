import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()
    
    // MARK: - Statistics Cards
    private let completedTrackersCard = StatisticsCard()
    private let averageValueCard = StatisticsCard()
    private let bestPeriodCard = StatisticsCard()
    private let idealDaysCard = StatisticsCard()

    // MARK: - Properties
    private let statisticsManager: StatisticsManagerProtocol = StatisticsManager()
    private var hasStatistics = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStatistics()
        
        AnalyticsManager.shared.trackStatisticsViewed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YPWhite")
        setupScrollView()
        setupTitle()
        setupEmptyState()
        setupStatisticsCards()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("statistics.title", comment: "Статистика")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .left
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.image = UIImage(named: "StatisticError")
        emptyStateImageView.contentMode = .scaleAspectFit
        view.addSubview(emptyStateImageView)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textColor = UIColor(named: "YPBlack")
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 18.0 / 12.0
        paragraphStyle.alignment = .center
        
        let attributedString = NSAttributedString(
            string: NSLocalizedString("statistics.empty", comment: "Анализировать пока нечего"),
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: emptyStateLabel.font ?? UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor(named: "YPBlack") ?? UIColor.black
            ]
        )
        emptyStateLabel.attributedText = attributedString
        
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupStatisticsCards() {
        [bestPeriodCard, idealDaysCard, completedTrackersCard, averageValueCard].forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(card)
        }
        
        NSLayoutConstraint.activate([
            bestPeriodCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            bestPeriodCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bestPeriodCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bestPeriodCard.heightAnchor.constraint(equalToConstant: 90),
            
            idealDaysCard.topAnchor.constraint(equalTo: bestPeriodCard.bottomAnchor, constant: 12),
            idealDaysCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            idealDaysCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            idealDaysCard.heightAnchor.constraint(equalToConstant: 90),
            
            completedTrackersCard.topAnchor.constraint(equalTo: idealDaysCard.bottomAnchor, constant: 12),
            completedTrackersCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completedTrackersCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            completedTrackersCard.heightAnchor.constraint(equalToConstant: 90),
            
            averageValueCard.topAnchor.constraint(equalTo: completedTrackersCard.bottomAnchor, constant: 12),
            averageValueCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            averageValueCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            averageValueCard.heightAnchor.constraint(equalToConstant: 90),
            averageValueCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Statistics Loading
    private func loadStatistics() {
        let statistics = statisticsManager.calculateStatistics()
        hasStatistics = statistics.completedTrackers > 0
        
        if hasStatistics {
            bestPeriodCard.configure(
                value: "\(statistics.bestPeriod)",
                title: NSLocalizedString("statistics.best.period", comment: "Лучший период")
            )
            
            idealDaysCard.configure(
                value: "\(statistics.idealDays)",
                title: NSLocalizedString("statistics.ideal.days", comment: "Идеальные дни")
            )
            
            completedTrackersCard.configure(
                value: "\(statistics.completedTrackers)",
                title: NSLocalizedString("statistics.completed.trackers", comment: "Трекеров завершено")
            )
            
            averageValueCard.configure(
                value: String(format: "%.1f", statistics.averageValue),
                title: NSLocalizedString("statistics.average.value", comment: "Среднее значение")
            )
        }
        updateUI()
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        let showEmptyState = !hasStatistics
        emptyStateImageView.isHidden = !showEmptyState
        emptyStateLabel.isHidden = !showEmptyState
        bestPeriodCard.isHidden = showEmptyState
        idealDaysCard.isHidden = showEmptyState
        completedTrackersCard.isHidden = showEmptyState
        averageValueCard.isHidden = showEmptyState
    }
}

// MARK: - Statistics Card Component
final class StatisticsCard: UIView {
    
    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let gradientBorderView = UIView()
    private let valueLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "YPWhite")
        layer.cornerRadius = 16
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.layer.cornerRadius = 16
        gradientBorderView.layer.borderWidth = 1
        addSubview(gradientBorderView)
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.boldSystemFont(ofSize: 34)
        valueLabel.textColor = UIColor(named: "YPBlack")
        valueLabel.textAlignment = .left
        addSubview(valueLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            gradientBorderView.topAnchor.constraint(equalTo: topAnchor),
            gradientBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientBorderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }
    
    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
        DispatchQueue.main.async { [weak self] in
            self?.setupBorder(color: "")
        }
    }
    
    private func setupBorder(color: String) {
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        gradientBorderView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let color1 = UIColor(named: "CollectionColor1") ?? UIColor.red
        let color5 = UIColor(named: "CollectionColor5") ?? UIColor.green
        let color3 = UIColor(named: "CollectionColor3") ?? UIColor.blue
        
        print("DEBUG: CollectionColor1 = \(color1), CollectionColor5 = \(color5), CollectionColor3 = \(color3)")
        
        gradientBorderView.layer.borderWidth = 1
        gradientBorderView.layer.borderColor = UIColor.clear.cgColor
        gradientBorderView.layer.cornerRadius = 16
        
        let borderLayer = CAGradientLayer()
        borderLayer.frame = bounds
        borderLayer.colors = [
            color1.cgColor,
            color5.cgColor,
            color3.cgColor
        ]
        borderLayer.startPoint = CGPoint(x: 0, y: 0)
        borderLayer.endPoint = CGPoint(x: 1, y: 0)
        borderLayer.cornerRadius = 16
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        
        let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 15)
        outerPath.append(innerPath)
        
        maskLayer.path = outerPath.cgPath
        borderLayer.mask = maskLayer
        
        gradientBorderView.layer.addSublayer(borderLayer)
        
        print("DEBUG: Gradient frame = \(borderLayer.frame)")
        print("DEBUG: Gradient colors count = \(borderLayer.colors?.count ?? 0)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let borderLayer = gradientBorderView.layer.sublayers?.first as? CAGradientLayer {
            borderLayer.frame = bounds
            borderLayer.cornerRadius = 16
            
            if let maskLayer = borderLayer.mask as? CAShapeLayer {
                let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
                let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 15)
                outerPath.append(innerPath)
                maskLayer.path = outerPath.cgPath
            }
        }
    }
}
