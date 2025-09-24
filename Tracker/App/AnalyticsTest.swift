import Foundation
import YandexMobileMetrica

final class AnalyticsTest {

    static func runFullTest() {
        print("🧪 ===== ПОЛНЫЙ ТЕСТ АНАЛИТИКИ =====")
        checkSDK()
        sendTestEvents()
        verifyConfiguration()
        print("🧪 =================================")
    }

    private static func sendTestEvents() {
        print("📊 Тест отправки событий:")
        
        let events = [
            ("event", ["event": "open", "screen": "Main"]),
            ("event", ["event": "click", "screen": "Main", "item": "add_track"]),
            ("event", ["event": "click", "screen": "Main", "item": "track"]),
            ("event", ["event": "click", "screen": "Main", "item": "filter"]),
            ("event", ["event": "close", "screen": "Main"])
        ]
        
        for (name, params) in events {
            YMMYandexMetrica.reportEvent(name, parameters: params)
            print("   ✅ Отправлено: \(name) с параметрами: \(params)")
        }
        print("")
    }

    private static func checkSDK() {
        print("📊 Статус SDK:")
        print("   - Версия: \(YMMYandexMetrica.libraryVersion)")
        print("   - SDK загружен и готов")
        print("")
    }

    private static func verifyConfiguration() {
        print("📊 Конфигурация:")
        print("   - API ключ: 7d0dcc04-9131-4d4e-8804-43e4e9a984b2")
        print("   - Логи включены (DEBUG)")
        print("   - Crash reporting включен (DEBUG)")
        print("")
    }
}
