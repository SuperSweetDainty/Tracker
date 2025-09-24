import UIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - UI Elements
    private let pageControl = UIPageControl()
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    // MARK: - Data
    private var pages: [OnboardingPageViewController] = []
    private var currentPageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageViewController()
        setupPageControl()
    }
    
    private func setupPages() {
        let page1 = OnboardingPageViewController(
            pageIndex: 0,
            titleText: NSLocalizedString("onboarding.title.0", comment: "Онбординг 1"),
            backgroundImageName: "Onboard1"
        )
        
        let page2 = OnboardingPageViewController(
            pageIndex: 1,
            titleText: NSLocalizedString("onboarding.title.1", comment: "Онбординг 2"),
            backgroundImageName: "Onboard2"
        )
        
        pages = [page1, page2]
        page1.onActionButtonTapped = { [weak self] in
            self?.finishOnboarding()
        }
        page2.onActionButtonTapped = { [weak self] in
            self?.finishOnboarding()
        }
    }
    
    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
        }
    }
    
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(named: "YPGray")?.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = UIColor(named: "YPBlack")
        pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140),
            pageControl.widthAnchor.constraint(equalToConstant: 134),
            pageControl.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    @objc private func pageControlValueChanged() {
        let direction: UIPageViewController.NavigationDirection = pageControl.currentPage > currentPageIndex ? .forward : .reverse
        
        if let targetPage = pages[safe: pageControl.currentPage] {
            pageViewController.setViewControllers([targetPage], direction: direction, animated: true)
            currentPageIndex = pageControl.currentPage
        }
    }
    
    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
        let tabBarController = MainTabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        tabBarController.modalTransitionStyle = .crossDissolve
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentVC),
              currentIndex > 0 else {
            return nil
        }
        
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentVC),
              currentIndex < pages.count - 1 else {
            return nil
        }
        
        return pages[currentIndex + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return
        }
        
        currentPageIndex = currentIndex
        pageControl.currentPage = currentIndex
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
