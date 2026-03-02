import SwiftUI
import UserNotifications
import AppKit

@main
struct SedentaryReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var timer: Timer?
    var soundEnabled: Bool = true
    var isEnabled: Bool = true
    var intervalMinutes: Int = 45
    var playMode: String = "random"
    var exercises: [Exercise] = []
    var currentIndex: Int = 0
    
    private let allExercises: [Exercise] = [
        Exercise(name: "颈部环绕", duration: "30秒", description: "头部缓慢转动，先顺时针5圈，再逆时针5圈", icon: "head"),
        Exercise(name: "肩部耸动", duration: "30秒", description: "双肩向上耸起至耳朵处，保持2秒后放下，重复10次", icon: "figure.stand"),
        Exercise(name: "背部伸展", duration: "1分钟", description: "双手交叉举过头顶，身体向左右两侧弯曲", icon: "figure.flexibility"),
        Exercise(name: "站立拉伸", duration: "1分钟", description: "站起来，双手放在背部，身体前倾拉伸", icon: "figure.stand"),
        Exercise(name: "眼球放松", duration: "30秒", description: "看向远处20英尺(6米)外的物体20秒", icon: "eye"),
        Exercise(name: "手腕活动", duration: "30秒", description: "顺时针和逆时针转动手腕各10次", icon: "hand.raised"),
        Exercise(name: "腰椎放松", duration: "1分钟", description: "坐在椅子上，双手抱膝向胸部靠近", icon: "figure.sitting"),
        Exercise(name: "深呼吸", duration: "30秒", description: "深呼吸4秒，屏住4秒，呼出4秒，重复5次", icon: "wind"),
    ]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        loadSettings()
        exercises = allExercises
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "figure.walk", accessibilityDescription: "久坐提醒")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MainView(appDelegate: self))
        
        requestNotificationPermission()
        startTimer()
        registerLoginItem()
    }
    
    func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "settings"),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            intervalMinutes = settings.intervalMinutes
            soundEnabled = settings.soundEnabled
            isEnabled = settings.isEnabled
            playMode = settings.playMode
        }
    }
    
    func saveSettings() {
        let settings = AppSettings(intervalMinutes: intervalMinutes, soundEnabled: soundEnabled, isEnabled: isEnabled, playMode: playMode)
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "settings")
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func startTimer() {
        timer?.invalidate()
        guard isEnabled else { return }
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(intervalMinutes * 60), repeats: true) { [weak self] _ in
            self?.triggerReminder()
        }
    }
    
    func triggerReminder() {
        guard isEnabled, !exercises.isEmpty else { return }
        let exercise = playMode == "random" ? exercises.randomElement()! : exercises[currentIndex % exercises.count]
        
        let content = UNMutableNotificationContent()
        content.title = "该起来活动一下了！"
        content.body = "\(exercise.name) - \(exercise.duration)"
        content.sound = soundEnabled ? .default : nil
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
        
        DispatchQueue.main.async { self.showExercisePopover(exercise: exercise) }
    }
    
    func showExercisePopover(exercise: Exercise) {
        let alert = NSAlert()
        alert.messageText = "该起来活动一下了！"
        alert.informativeText = "\n\(exercise.name)\n⏱ \(exercise.duration)\n\n\(exercise.description)"
        alert.alertStyle = .informational
        if soundEnabled { NSSound.beep() }
        alert.addButton(withTitle: "知道了")
        alert.addButton(withTitle: "稍后提醒")
        
        if alert.runModal() == .alertSecondButtonReturn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 300) { [weak self] in self?.triggerReminder() }
        }
    }
    
    func registerLoginItem() {
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        }
    }
    
    @objc func togglePopover() {
        if popover.isShown { popover.performClose(nil) }
        else if let button = statusItem.button { popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY) }
    }
    
    func updateInterval(_ minutes: Int) { intervalMinutes = minutes; saveSettings(); startTimer() }
    func updateEnabled(_ enabled: Bool) { isEnabled = enabled; saveSettings(); enabled ? startTimer() : timer?.invalidate() }
    func updateSound(_ enabled: Bool) { soundEnabled = enabled; saveSettings() }
    func updateExercises(_ newExercises: [Exercise]) { exercises = newExercises }
}

struct AppSettings: Codable {
    var intervalMinutes: Int = 45
    var soundEnabled: Bool = true
    var isEnabled: Bool = true
    var playMode: String = "random"
}

struct Exercise: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let duration: String
    let description: String
    let icon: String
    var isEnabled: Bool = true
}
