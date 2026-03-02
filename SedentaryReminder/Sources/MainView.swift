import SwiftUI

struct MainView: View {
    let appDelegate: AppDelegate
    
    @AppStorage("intervalMinutes") private var intervalMinutes: Int = 45
    @AppStorage("isEnabled") private var isEnabled: Bool = true
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("playMode") private var playMode: String = "random"
    @AppStorage("selectedExercises") private var selectedExercisesData: Data = Data()
    
    @State private var exercises: [Exercise] = []
    @State private var currentIndex: Int = 0
    
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
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: isEnabled ? "bell.badge.fill" : "bell.slash")
                    .foregroundColor(isEnabled ? .green : .gray)
                Text(isEnabled ? "提醒已开启" : "提醒已关闭").font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("提醒间隔:")
                    Picker("", selection: $intervalMinutes) {
                        Text("30分钟").tag(30)
                        Text("45分钟").tag(45)
                        Text("1小时").tag(60)
                        Text("90分钟").tag(90)
                        Text("2小时").tag(120)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                    .onChange(of: intervalMinutes) { _, newValue in appDelegate.updateInterval(newValue) }
                }
                Toggle("开启声音提醒", isOn: $soundEnabled).onChange(of: soundEnabled) { _, newValue in appDelegate.updateSound(newValue) }
                Toggle("启用提醒", isOn: $isEnabled).onChange(of: isEnabled) { _, newValue in appDelegate.updateEnabled(newValue) }
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("🎮 播放模式").font(.subheadline.bold())
                Picker("", selection: $playMode) {
                    Label("随机", systemImage: "shuffle").tag("random")
                    Label("顺序", systemImage: "repeat").tag("sequential")
                }
                .pickerStyle(.segmented)
                .onChange(of: playMode) { _, newValue in saveSelectedExercises(); appDelegate.playMode = newValue }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("📋 锻炼动作").font(.subheadline.bold())
                    Spacer()
                    Text("\(enabledExercisesCount)/\(exercises.count)").font(.caption).foregroundColor(.secondary)
                }
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach($exercises) { $exercise in
                            HStack {
                                Toggle("", isOn: $exercise.isEnabled).toggleStyle(.checkbox)
                                Image(systemName: exercise.icon).frame(width: 20).foregroundColor(exercise.isEnabled ? .blue : .gray)
                                VStack(alignment: .leading) {
                                    Text(exercise.name).font(.subheadline).foregroundColor(exercise.isEnabled ? .primary : .secondary)
                                    Text(exercise.duration).font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(6)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(6)
                            .onChange(of: exercise.isEnabled) { _, _ in saveSelectedExercises() }
                        }
                    }
                }
                .frame(height: 160)
            }
            
            Button("立即提醒") { triggerExercise() }
                .buttonStyle(.borderedProminent)
                .disabled(enabledExercisesCount == 0)
            
            Text("✓ 登录时自动启动").font(.caption).foregroundColor(.secondary)
        }
        .padding(12)
        .frame(width: 320)
        .onAppear { loadExercises() }
    }
    
    private var enabledExercisesCount: Int { exercises.filter { $0.isEnabled }.count }
    
    private func loadExercises() {
        if selectedExercisesData.isEmpty {
            exercises = allExercises
            saveSelectedExercises()
        } else {
            exercises = (try? JSONDecoder().decode([Exercise].self, from: selectedExercisesData)) ?? allExercises
        }
        appDelegate.playMode = playMode
    }
    
    private func saveSelectedExercises() {
        if let data = try? JSONEncoder().encode(exercises) {
            selectedExercisesData = data
            appDelegate.updateExercises(exercises.filter { $0.isEnabled })
        }
    }
    
    private func triggerExercise() {
        let enabledList = exercises.filter { $0.isEnabled }
        guard !enabledList.isEmpty else { return }
        let exercise = playMode == "random" ? enabledList.randomElement()! : { currentIndex = currentIndex % enabledList.count; return enabledList[currentIndex]; currentIndex += 1; }()
        appDelegate.showExercisePopover(exercise: exercise)
    }
}
