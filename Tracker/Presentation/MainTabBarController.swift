import UIKit

class MainTabBarController: UITabBarController {
    
    private let topBorderView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupTopBorder()
    }
    
    private func setupTabBar() {
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.trackers", comment: "Trackers tab"),
            image: UIImage(named: "TrackerImage"),
            selectedImage: UIImage(named: "TrackerImage")
        )
        
        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.statistics", comment: "Statistics tab"),
            image: UIImage(named: "StatisticImage"),
            selectedImage: UIImage(named: "StatisticImage")
        )
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
        
        tabBar.backgroundColor = UIColor(named: "YPWhite")
        tabBar.tintColor = UIColor(named: "YPBlue")
        tabBar.unselectedItemTintColor = UIColor(named: "YPGray")
    }
    
    private func setupTopBorder() {
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        topBorderView.backgroundColor = UIColor(named: "TabbarBorder")
        view.addSubview(topBorderView)
        
        NSLayoutConstraint.activate([
            topBorderView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -4),
            topBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
