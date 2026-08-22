import Combine
import Foundation
import SwiftUI

enum AppTab: Int, CaseIterable {
    case disclaimer, language, intensity
}

enum Panel {
    case stack, intensity, language, debug
}

enum AppLanguage: String, CaseIterable {
    case zh, en, hi

    var speechCode: String {
        switch self {
        case .zh: return "zh-CN"
        case .en: return "en-US"
        case .hi: return "hi-IN"
        }
    }

    var label: (en: String, zh: String, hi: String) {
        switch self {
        case .zh: return ("Chinese", "中文", "चीनी")
        case .en: return ("English", "英语", "अंग्रेज़ी")
        case .hi: return ("Hindi", "印地语", "हिन्दी")
        }
    }
}

enum Copy {
    static let brand = "LASAL"
    static let disclaimer = """
    LASAL is a supplement to help people with visual impairment sense proximity to objects. It is not a replacement for other visual aids and should be used in tandem.

    Double tap to start or stop the program. Swipe up to change the menu, swipe left or right to adjust the settings relevant to the menu.
    """
}

final class AppStore: ObservableObject {
    @Published var tab: AppTab = .disclaimer
    @Published var panel: Panel = .stack
    @Published var intensity: Int = 3
    @Published var language: AppLanguage = .en
    @Published var sensing = false
    @Published var disclaimer: String = UserDefaults.standard.string(forKey: "lasal.disclaimer") ?? Copy.disclaimer
    @Published var debug = false

    func nextTab() {
        tab = AppTab(rawValue: (tab.rawValue + 1) % 3) ?? .disclaimer
        panel = .stack
    }

    func prevTab() {
        tab = AppTab(rawValue: (tab.rawValue + 2) % 3) ?? .disclaimer
        panel = .stack
    }

    func openPicker() {
        if tab == .intensity { panel = .intensity }
        if tab == .language { panel = .language }
    }

    func saveDisclaimer() {
        UserDefaults.standard.set(disclaimer, forKey: "lasal.disclaimer")
    }
}
