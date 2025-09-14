import UIKit

final class OnboardingContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let pageVC = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: .horizontal)
    private let pageControl = UIPageControl()
    
    private var pages: [OnboardingContentViewController] = []
    private var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageVC()
        setupPageControl()
    }
    
    // MARK: - Setup
    private func setupPages() {
        let first = OnboardingContentViewController(
            index: 0,
            text: "Отслеживайте только то, что хотите",
            imageName: "Onboard1"
        )
        let second = OnboardingContentViewController(
            index: 1,
            text: "Даже если это не литры воды и йога",
            imageName: "Onboard2"
        )
        
        first.onAction = { [weak self] in self?.finishOnboarding() }
        second.onAction = { [weak self] in self?.finishOnboarding() }
        
        pages = [first, second]
    }
    
    private func setupPageVC() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        pageVC.dataSource = self
        pageVC.delegate = self
        
        if let first = pages.first {
            pageVC.setViewControllers([first], direction: .forward, animated: false)
        }
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.currentPageIndicatorTintColor = .label
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120)
        ])
    }
    
    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        
        let mainVC = MainTabBarController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainVC
            window.makeKeyAndVisible()
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingContentViewController,
              let index = pages.firstIndex(of: currentVC),
              index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingContentViewController,
              let index = pages.firstIndex(of: currentVC),
              index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
    
    // MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? OnboardingContentViewController,
              let index = pages.firstIndex(of: currentVC) else {
            return
        }
        currentIndex = index
        pageControl.currentPage = index
    }
}
