import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @StateObject private var lidar = LidarSession()
    @State private var upHeld = false
    @State private var downHeld = false
    @State private var holdStarted: Date?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                (store.panel == .intensity || store.panel == .language ? Color.white : Color.black)
                    .ignoresSafeArea()

                tabStack(size: geo.size)

                if store.panel == .intensity {
                    IntensityWheel()
                        .transition(.move(edge: .trailing))
                }
                if store.panel == .language {
                    LanguageWheel()
                        .transition(.move(edge: .trailing))
                }
                if store.panel == .debug {
                    DebugView(lidar: lidar)
                }

                VolumeRocker(upHeld: $upHeld, downHeld: $downHeld)
            }
            .gesture(swipe(size: geo.size))
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.52)
                    .onEnded { _ in
                        Announcer.page(store.tab, panel: store.panel, intensity: store.intensity, language: store.language, hold: true)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            )
            .onTapGesture(count: 2) { toggleSensing() }
            .onChange(of: store.tab) { _, _ in announce() }
            .onChange(of: store.panel) { _, _ in announce() }
            .onAppear { announce() }
            .onChange(of: upHeld) { _, _ in considerChord() }
            .onChange(of: downHeld) { _, _ in considerChord() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                if store.sensing { lidar.enterBackground() }
            }
        }
        .environmentObject(store)
    }

    private func announce() {
        if store.panel == .debug { return }
        Announcer.page(store.tab, panel: store.panel, intensity: store.intensity, language: store.language)
    }

    @ViewBuilder
    private func tabStack(size: CGSize) -> some View {
        Group {
            switch store.tab {
            case .disclaimer:
                DisclaimerView()
            case .intensity:
                HubView(title: label(.intensity), value: numberLabel(store.intensity), primary: hintPrimary, secondary: hintSecondary)
            case .language:
                HubView(title: label(.language), value: langLabel(store.language), primary: hintPrimary, secondary: hintSecondary)
            }
        }
        .foregroundStyle(store.panel == .intensity || store.panel == .language ? Color.black : Color.white)
    }

    private func swipe(size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height
                if abs(dy) > abs(dx) && store.panel == .stack {
                    if dy < -70 { store.nextTab(); UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
                    else if dy > 70 { store.prevTab(); UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
                } else if abs(dx) > abs(dy) {
                    if dx < -70 && store.panel == .stack { store.openPicker() }
                    if dx > 70 && (store.panel == .intensity || store.panel == .language) {
                        store.panel = .stack
                    }
                }
            }
    }

    private func toggleSensing() {
        store.sensing.toggle()
        if store.sensing { lidar.start() } else { lidar.stop() }
        let text = store.sensing
            ? (store.language == .zh ? "传感已开启" : store.language == .hi ? "सेंसिंग चालू" : "Sensing on")
            : (store.language == .zh ? "传感已关闭" : store.language == .hi ? "सेंसिंग बंद" : "Sensing off")
        Announcer.speak(text, language: store.language)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    private func considerChord() {
        if upHeld && downHeld {
            if holdStarted == nil { holdStarted = Date() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                guard upHeld, downHeld, let start = holdStarted, Date().timeIntervalSince(start) >= 1.95 else { return }
                store.panel = store.panel == .debug ? .stack : .debug
                Announcer.speak(store.language == .zh ? "调试" : store.language == .hi ? "डिबग" : "Debug mode", language: store.language)
                holdStarted = nil
            }
        } else {
            holdStarted = nil
        }
    }

    private func label(_ tab: AppTab) -> String {
        switch (tab, store.language) {
        case (.disclaimer, .en): return "Disclaimer"
        case (.disclaimer, .zh): return "免责声明"
        case (.disclaimer, .hi): return "अस्वीकरण"
        case (.intensity, .en): return "Intensity"
        case (.intensity, .zh): return "强度"
        case (.intensity, .hi): return "तीव्रता"
        case (.language, .en): return "Language"
        case (.language, .zh): return "语言"
        case (.language, .hi): return "भाषा"
        }
    }

    private func numberLabel(_ n: Int) -> String {
        Announcer.numberLabel(n, language: store.language)
    }

    private func langLabel(_ lang: AppLanguage) -> String {
        switch store.language {
        case .en: return lang.label.en
        case .zh: return lang.label.zh
        case .hi: return lang.label.hi
        }
    }

    private var hintPrimary: String {
        switch (store.tab, store.language) {
        case (.disclaimer, .en): return "Swipe left for language settings"
        case (.disclaimer, .zh): return "向左滑动进入语言设置"
        case (.disclaimer, .hi): return "भाषा सेटिंग के लिए बाएँ स्वाइप करें"
        case (.language, .en): return "Swipe left for language selection"
        case (.language, .zh): return "向左滑动选择语言"
        case (.language, .hi): return "भाषा चुनने के लिए बाएँ स्वाइप करें"
        case (.intensity, .en): return "Swipe left for intensity selection"
        case (.intensity, .zh): return "向左滑动选择强度"
        case (.intensity, .hi): return "तीव्रता चुनने के लिए बाएँ स्वाइप करें"
        }
    }

    private var hintSecondary: String {
        switch (store.tab, store.language) {
        case (.disclaimer, .en): return "Swipe up for Language"
        case (.disclaimer, .zh): return "向上滑动进入语言"
        case (.disclaimer, .hi): return "भाषा के लिए ऊपर स्वाइप करें"
        case (.language, .en): return "Swipe up for Intensity"
        case (.language, .zh): return "向上滑动进入强度"
        case (.language, .hi): return "तीव्रता के लिए ऊपर स्वाइप करें"
        case (.intensity, .en): return "Swipe up for Disclaimer"
        case (.intensity, .zh): return "向上滑动进入免责声明"
        case (.intensity, .hi): return "अस्वीकरण के लिए ऊपर स्वाइप करें"
        }
    }
}

struct DisclaimerView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(Copy.brand)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .tracking(4)
                .foregroundStyle(.gray)
            Text(title)
                .font(.system(size: 56, weight: .semibold, design: .default))
                .tracking(-2)
                .textCase(.uppercase)
            TextEditor(text: $store.disclaimer)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(height: 108)
                .background(Color.white.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.18), lineWidth: 1))
                .onChange(of: store.disclaimer) { _, _ in store.saveDisclaimer() }
            Spacer()
            HintFooter(primary: primary, secondary: secondary)
        }
        .padding(.horizontal, 28)
        .padding(.top, 72)
        .padding(.bottom, 36)
    }

    private var title: String {
        store.language == .zh ? "免责声明" : store.language == .hi ? "अस्वीकरण" : "Disclaimer"
    }
    private var primary: String {
        store.language == .zh ? "向左滑动进入语言设置" : store.language == .hi ? "भाषा सेटिंग के लिए बाएँ स्वाइप करें" : "Swipe left for language settings"
    }
    private var secondary: String {
        store.language == .zh ? "向上滑动进入语言" : store.language == .hi ? "भाषा के लिए ऊपर स्वाइप करें" : "Swipe up for Language"
    }
}

struct HubView: View {
    var title: String
    var value: String
    var primary: String
    var secondary: String
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(Copy.brand)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .tracking(4)
                .foregroundStyle(.gray)
            Text(title)
                .font(.system(size: 56, weight: .semibold))
                .tracking(-2)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 44, weight: .semibold))
            Spacer()
            HintFooter(primary: primary, secondary: secondary)
        }
        .padding(.horizontal, 28)
        .padding(.top, 72)
        .padding(.bottom, 36)
    }
}

struct HintFooter: View {
    var primary: String
    var secondary: String
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "chevron.up")
                Text(primary)
                Text(secondary)
            }
            .font(.system(size: 11, weight: .medium))
            .tracking(1.4)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
            .foregroundStyle(.gray)
            Spacer()
        }
    }
}

struct IntensityWheel: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                Text("INTENSITY").font(.system(size: 11, weight: .medium, design: .monospaced)).tracking(3).foregroundStyle(.gray)
                Picker("Intensity", selection: $store.intensity) {
                    ForEach(1...5, id: \.self) { n in
                        Text("\(n)").tag(n)
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: store.intensity) { _, n in Announcer.number(n, language: store.language) }
                Text("SWIPE RIGHT FOR BACK TO MENU").font(.system(size: 11)).tracking(1.4).foregroundStyle(.gray)
            }
            .foregroundStyle(.black)
        }
    }
}

struct LanguageWheel: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                Text("LANGUAGE").font(.system(size: 11, weight: .medium, design: .monospaced)).tracking(3).foregroundStyle(.gray)
                Picker("Language", selection: $store.language) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(store.language == .zh ? lang.label.zh : store.language == .hi ? lang.label.hi : lang.label.en)
                            .tag(lang)
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: store.language) { _, lang in
                    Announcer.speak(store.language == .zh ? lang.label.zh : store.language == .hi ? lang.label.hi : lang.label.en, language: lang)
                }
                Text("SWIPE RIGHT FOR BACK TO MENU").font(.system(size: 11)).tracking(1.4).foregroundStyle(.gray)
            }
            .foregroundStyle(.black)
        }
    }
}

struct DebugView: View {
    @EnvironmentObject var store: AppStore
    @ObservedObject var lidar: LidarSession
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("LASAL / SYS").font(.system(size: 11, design: .monospaced)).tracking(3).foregroundStyle(.gray)
            Text("Debug").font(.system(size: 48, weight: .semibold))
            Grid(alignment: .leading) {
                row("Arch", "arm64")
                row("Sensing", store.sensing ? "on" : "off")
                row("LiDAR", lidar.hasSceneDepth ? "sceneDepth" : "feature points")
                row("Distance", String(format: "%.2f m", lidar.distance))
                row("Intensity", "\(store.intensity)")
            }
            .font(.system(size: 13, design: .monospaced))
            Text("True scene-depth LiDAR requires iPhone 12 Pro or later. Sensing stays alive in background via audio + ARKit.")
                .font(.system(size: 13))
                .foregroundStyle(.gray)
            Spacer()
        }
        .padding(28)
        .foregroundStyle(.white)
        .background(Color.black.ignoresSafeArea())
    }

    func row(_ k: String, _ v: String) -> some View {
        GridRow {
            Text(k.uppercased()).foregroundStyle(.gray)
            Text(v).gridColumnAlignment(.trailing)
        }
    }
}

struct VolumeRocker: View {
    @Binding var upHeld: Bool
    @Binding var downHeld: Bool
    var body: some View {
        VStack(spacing: 8) {
            Capsule().fill(upHeld ? Color.white : Color.white.opacity(0.28)).frame(width: 8, height: 48)
                .gesture(DragGesture(minimumDistance: 0).onChanged { _ in upHeld = true }.onEnded { _ in upHeld = false })
            Capsule().fill(downHeld ? Color.white : Color.white.opacity(0.28)).frame(width: 8, height: 48)
                .gesture(DragGesture(minimumDistance: 0).onChanged { _ in downHeld = true }.onEnded { _ in downHeld = false })
        }
        .padding(.leading, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 120)
    }
}
