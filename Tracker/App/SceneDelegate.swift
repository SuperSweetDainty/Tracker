import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        if onboardingCompleted {
            window.rootViewController = MainTabBarController()
        } else {
            window.rootViewController = OnboardingContainerViewController()
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
