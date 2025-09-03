import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(resource: .ypWhite)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = titleAttributes
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = titleAttributes
        
        tabBar.standardAppearance = tabAppearance
        tabBar.scrollEdgeAppearance = tabAppearance
        
        let trackersVC = TrackersViewController()
        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tracker),
            selectedImage: nil
        )
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statistic),
            selectedImage: nil
        )
        
        viewControllers = [trackersVC, statisticsVC]
        
        tabBar.addTopBorder(color: .ypGray, height: 0.5)
    }
}

extension UITabBar {
    func addTopBorder(color: UIColor = .lightGray, height: CGFloat = 1.0) {
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
        self.layer.addSublayer(topBorder)
    }
}
