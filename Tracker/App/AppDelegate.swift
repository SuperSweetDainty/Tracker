import UIKit
import CoreData
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
        let apiKey = "7d0dcc04-9131-4d4e-8804-43e4e9a984b2"
        
        if let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey) {
            #if DEBUG
            configuration.logs = true
            configuration.crashReporting = true
            #endif
            
            YMMYandexMetrica.activate(with: configuration)
            
            #if DEBUG
            print("📊 YandexMobileMetrica активирована с API ключом: \(apiKey)")
            print("📊 Версия SDK: \(YMMYandexMetrica.libraryVersion)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                AnalyticsTest.runFullTest()
            }
            #endif
        } else {
            #if DEBUG
            print("❌ Ошибка инициализации YandexMobileMetrica")
            #endif
        }
        
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    lazy var persistentContainer: NSPersistentContainer = CoreDataManager.shared.persistentContainer

    func saveContext() {
        CoreDataManager.shared.saveContext()
    }
}
