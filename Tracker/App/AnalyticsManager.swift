import Foundation
import YandexMobileMetrica

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}

    // MARK: - Legacy Tracker Events
    func trackTrackerCreated(name: String, category: String, schedule: [Int]) {
        let params: [String: Any] = [
            "tracker_name": name,
            "category": category,
            "schedule_days": schedule.count,
            "is_daily": schedule.count == 7
        ]
        YMMYandexMetrica.reportEvent("tracker_created", parameters: params)
    }

    func trackTrackerCompleted(trackerId: UUID, trackerName: String) {
        reportTrackerEvent(name: "tracker_completed", id: trackerId, nameValue: trackerName)
    }

    func trackTrackerUncompleted(trackerId: UUID, trackerName: String) {
        reportTrackerEvent(name: "tracker_uncompleted", id: trackerId, nameValue: trackerName)
    }

    func trackTrackerEdited(trackerId: UUID, trackerName: String) {
        reportTrackerEvent(name: "tracker_edited", id: trackerId, nameValue: trackerName)
    }

    func trackTrackerDeleted(trackerId: UUID, trackerName: String) {
        reportTrackerEvent(name: "tracker_deleted", id: trackerId, nameValue: trackerName)
    }

    private func reportTrackerEvent(name: String, id: UUID, nameValue: String) {
        let params: [String: Any] = [
            "tracker_id": id.uuidString,
            "tracker_name": nameValue
        ]
        YMMYandexMetrica.reportEvent(name, parameters: params)
    }

    // MARK: - Screen Events
    func trackScreenOpen(screen: String) {
        sendEvent(name: "event", parameters: ["event": "open", "screen": screen])
    }

    func trackScreenClose(screen: String) {
        sendEvent(name: "event", parameters: ["event": "close", "screen": screen])
    }

    func trackButtonClick(screen: String, item: String) {
        sendEvent(name: "event", parameters: ["event": "click", "screen": screen, "item": item])
    }

    // MARK: - Category Events
    func trackCategoryCreated(categoryName: String) {
        sendEvent(name: "category_created", parameters: ["category_name": categoryName])
    }

    func trackCategoryEdited(oldName: String, newName: String) {
        sendEvent(name: "category_edited", parameters: ["old_category_name": oldName, "new_category_name": newName])
    }

    func trackCategoryDeleted(categoryName: String) {
        sendEvent(name: "category_deleted", parameters: ["category_name": categoryName])
    }

    // MARK: - User Interaction Events
    func trackButtonTapped(buttonName: String, screenName: String) {
        sendEvent(name: "button_tapped", parameters: ["button_name": buttonName, "screen_name": screenName])
    }

    func trackSearchPerformed(query: String, resultsCount: Int) {
        sendEvent(name: "search_performed", parameters: ["search_query": query, "results_count": resultsCount])
    }

    func trackScreenView(screenName: String) {
        sendEvent(name: "screen_view", parameters: ["screen_name": screenName])
    }

    func trackStatisticsViewed() {
        YMMYandexMetrica.reportEvent("statistics_viewed")
    }

    func trackFiltersUsed(filterType: String) {
        sendEvent(name: "filters_used", parameters: ["filter_type": filterType])
    }

    // MARK: - Test & Debug Methods
    func checkAnalyticsStatus() {
        print("📊 ===== АНАЛИТИКА: СТАТУС =====")
        print("API ключ: 7d0dcc04-9131-4d4e-8804-43e4e9a984b2")
        print("SDK версия: \(YMMYandexMetrica.libraryVersion)")
        print("SDK готов к работе")
        print("📊 ==============================")
    }

    func testAnalytics() {
        print("🧪 ===== ТЕСТ АНАЛИТИКИ =====")
        print("Отправляем тестовые события...")
        trackScreenOpen(screen: "Main")
        trackButtonClick(screen: "Main", item: "add_track")
        trackButtonClick(screen: "Main", item: "track")
        trackButtonClick(screen: "Main", item: "filter")
        trackButtonClick(screen: "Main", item: "edit")
        trackButtonClick(screen: "Main", item: "delete")
        trackScreenClose(screen: "Main")
        print("✅ Все тестовые события отправлены!")
        print("🧪 ===========================")
    }

    // MARK: - Private Helpers
    private func sendEvent(name: String, parameters: [String: Any]) {
        YMMYandexMetrica.reportEvent(name, parameters: parameters)
#if DEBUG
        print("📊 Событие отправлено: \(name) - \(parameters)")
#endif
    }
}
