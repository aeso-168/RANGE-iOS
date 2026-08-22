import AVFoundation

enum Announcer {
    private static let synth = AVSpeechSynthesizer()

    static func speak(_ text: String, language: AppLanguage) {
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: language.speechCode)
        u.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        synth.speak(u)
    }

    static func page(_ tab: AppTab, language: AppLanguage) {
        let text: String
        switch (tab, language) {
        case (.disclaimer, .en): text = "Disclaimer"
        case (.disclaimer, .zh): text = "免责声明"
        case (.disclaimer, .hi): text = "अस्वीकरण"
        case (.intensity, .en): text = "Intensity"
        case (.intensity, .zh): text = "强度"
        case (.intensity, .hi): text = "तीव्रता"
        case (.language, .en): text = "Language"
        case (.language, .zh): text = "语言"
        case (.language, .hi): text = "भाषा"
        }
        speak(text, language: language)
    }

    static func number(_ n: Int, language: AppLanguage) {
        let en = ["One", "Two", "Three", "Four", "Five"]
        let zh = ["一", "二", "三", "四", "五"]
        let hi = ["एक", "दो", "तीन", "चार", "पाँच"]
        let i = min(5, max(1, n)) - 1
        let text = language == .zh ? zh[i] : language == .hi ? hi[i] : en[i]
        speak(text, language: language)
    }
}
