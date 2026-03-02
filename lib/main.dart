import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';

void main() {
  runApp(const SedentaryReminderApp());
}

// Exercise model
class Exercise {
  String name;
  String duration;
  String description;
  String icon;
  bool isEnabled;

  Exercise({
    required this.name,
    required this.duration,
    required this.description,
    required this.icon,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'duration': duration,
        'description': description,
        'icon': icon,
        'isEnabled': isEnabled,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'] ?? '',
        duration: json['duration'] ?? '',
        description: json['description'] ?? '',
        icon: json['icon'] ?? 'fitness_center',
        isEnabled: json['isEnabled'] ?? true,
      );
}

// All available exercises (from original Swift app)
final List<Exercise> allExercises = [
  Exercise(
    name: '颈部环绕',
    duration: '30秒',
    description: '头部缓慢转动，先顺时针5圈，再逆时针5圈',
    icon: 'head',
  ),
  Exercise(
    name: '肩部耸动',
    duration: '30秒',
    description: '双肩向上耸起至耳朵处，保持2秒后放下，重复10次',
    icon: 'accessibility_new',
  ),
  Exercise(
    name: '背部伸展',
    duration: '1分钟',
    description: '双手交叉举过头顶，身体向左右两侧弯曲',
    icon: 'self_improvement',
  ),
  Exercise(
    name: '站立拉伸',
    duration: '1分钟',
    description: '站起来，双手放在背部，身体前倾拉伸',
    icon: 'directions_walk',
  ),
  Exercise(
    name: '眼球放松',
    duration: '30秒',
    description: '看向远处20英尺(6米)外的物体20秒',
    icon: 'visibility',
  ),
  Exercise(
    name: '手腕活动',
    duration: '30秒',
    description: '顺时针和逆时针转动手腕各10次',
    icon: 'pan_tool',
  ),
  Exercise(
    name: '腰椎放松',
    duration: '1分钟',
    description: '坐在椅子上，双手抱膝向胸部靠近',
    icon: 'airline_seat_recline_normal',
  ),
  Exercise(
    name: '深呼吸',
    duration: '30秒',
    description: '深呼吸4秒，屏住4秒，呼出4秒，重复5次',
    icon: 'air',
  ),
];

class SedentaryReminderApp extends StatelessWidget {
  const SedentaryReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sedentary Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  // Settings
  int intervalMinutes = 45;
  bool isEnabled = true;
  bool soundEnabled = true;
  String playMode = 'random';
  List<Exercise> exercises = [];
  int currentIndex = 0;

  // Timer
  Timer? _timer;
  int _remainingSeconds = 0;

  // SharedPreferences
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _initTray();
    _updateRemainingTime();
    if (isEnabled) {
      _startTimer();
    }
  }

  Future<void> _loadSettings() async {
    intervalMinutes = _prefs.getInt('intervalMinutes') ?? 45;
    isEnabled = _prefs.getBool('isEnabled') ?? true;
    soundEnabled = _prefs.getBool('soundEnabled') ?? true;
    playMode = _prefs.getString('playMode') ?? 'random';

    final String? exercisesData = _prefs.getString('exercises');
    if (exercisesData != null && exercisesData.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(exercisesData);
      exercises = jsonList.map((e) => Exercise.fromJson(e)).toList();
    } else {
      exercises = List.from(allExercises);
    }
    setState(() {});
  }

  Future<void> _saveSettings() async {
    await _prefs.setInt('intervalMinutes', intervalMinutes);
    await _prefs.setBool('isEnabled', isEnabled);
    await _prefs.setBool('soundEnabled', soundEnabled);
    await _prefs.setString('playMode', playMode);
    final String exercisesData =
        jsonEncode(exercises.map((e) => e.toJson()).toList());
    await _prefs.setString('exercises', exercisesData);
  }

  Future<void> _initTray() async {
    trayManager.addListener(this);
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png',
    );
    await _updateTrayMenu();
    await trayManager.setToolTip('Sedentary Reminder');
  }

  Future<void> _updateTrayMenu() async {
    final enabledExercises = exercises.where((e) => e.isEnabled).toList();
    Menu menu = Menu(
      items: [
        MenuItem(
          label: isEnabled ? '✓ 提醒已开启' : '✗ 提醒已关闭',
          disabled: true,
        ),
        MenuItem.separator(),
        MenuItem(
          label: '间隔: $intervalMinutes 分钟',
          disabled: true,
        ),
        MenuItem.separator(),
        MenuItem(
          label: isEnabled ? '立即提醒' : '已禁用',
          disabled: !isEnabled || enabledExercises.isEmpty,
          onClick: (menuItem) => _triggerExercise(),
        ),
        MenuItem.separator(),
        MenuItem(
          label: '打开设置',
          onClick: (menuItem) => _openSettings(),
        ),
        MenuItem(
          label: '退出',
          onClick: (menuItem) => exit(0),
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = intervalMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isEnabled) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _triggerExercise();
        _remainingSeconds = intervalMinutes * 60;
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _remainingSeconds = 0;
    });
  }

  void _updateRemainingTime() {
    if (isEnabled) {
      _remainingSeconds = intervalMinutes * 60;
    }
  }

  void _triggerExercise() {
    final enabledExercises = exercises.where((e) => e.isEnabled).toList();
    if (enabledExercises.isEmpty) return;

    Exercise exercise;
    if (playMode == 'random') {
      exercise = enabledExercises[DateTime.now().millisecond % enabledExercises.length];
    } else {
      exercise = enabledExercises[currentIndex % enabledExercises.length];
      currentIndex++;
    }

    _showExerciseDialog(exercise);
  }

  void _showExerciseDialog(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🧘 ${exercise.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⏱️ 时长: ${exercise.duration}'),
            const SizedBox(height: 8),
            Text(exercise.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('完成'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerExercise(); // Next exercise
            },
            child: const Text('下一个'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    ).then((_) => _loadSettings());
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get _enabledCount => exercises.where((e) => e.isEnabled).length;

  // TrayListener callbacks
  @override
  void onTrayIconMouseDown() {
    _openSettings();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {}

  @override
  void dispose() {
    _timer?.cancel();
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedentary Reminder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      isEnabled ? Icons.notifications_active : Icons.notifications_off,
                      size: 40,
                      color: isEnabled ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnabled ? '提醒已开启' : '提醒已关闭',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isEnabled)
                          Text(
                            '下次提醒: $_formattedTime',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Switch(
                      value: isEnabled,
                      onChanged: (value) {
                        setState(() {
                          isEnabled = value;
                          if (value) {
                            _startTimer();
                          } else {
                            _stopTimer();
                          }
                        });
                        _saveSettings();
                        _updateTrayMenu();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Interval setting
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.timer),
                    const SizedBox(width: 12),
                    const Text('提醒间隔:'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: intervalMinutes,
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('30分钟')),
                        DropdownMenuItem(value: 45, child: Text('45分钟')),
                        DropdownMenuItem(value: 60, child: Text('1小时')),
                        DropdownMenuItem(value: 90, child: Text('90分钟')),
                        DropdownMenuItem(value: 120, child: Text('2小时')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            intervalMinutes = value;
                            if (isEnabled) {
                              _startTimer();
                            }
                          });
                          _saveSettings();
                          _updateTrayMenu();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Play mode
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔀 播放模式',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'random', label: Text('随机'), icon: Icon(Icons.shuffle)),
                        ButtonSegment(value: 'sequential', label: Text('顺序'), icon: Icon(Icons.repeat)),
                      ],
                      selected: {playMode},
                      onSelectionChanged: (value) {
                        setState(() {
                          playMode = value.first;
                          currentIndex = 0;
                        });
                        _saveSettings();
                        _updateTrayMenu();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sound toggle
            SwitchListTile(
              title: const Text('开启声音提醒'),
              secondary: const Icon(Icons.volume_up),
              value: soundEnabled,
              onChanged: (value) {
                setState(() {
                  soundEnabled = value;
                });
                _saveSettings();
              },
            ),
            const SizedBox(height: 16),

            // Exercise list header
            Row(
              children: [
                const Text(
                  '📋 锻炼动作',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '$_enabledCount/${exercises.length}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Exercise list
            Expanded(
              child: Card(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return CheckboxListTile(
                      value: exercise.isEnabled,
                      onChanged: (value) {
                        setState(() {
                          exercise.isEnabled = value ?? false;
                        });
                        _saveSettings();
                        _updateTrayMenu();
                      },
                      title: Text(exercise.name),
                      subtitle: Text(exercise.duration),
                      secondary: Icon(_getIconData(exercise.icon)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Trigger button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isEnabled && _enabledCount > 0 ? _triggerExercise : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('立即提醒'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final Map<String, IconData> iconMap = {
      'head': Icons.face,
      'accessibility_new': Icons.accessibility_new,
      'self_improvement': Icons.self_improvement,
      'directions_walk': Icons.directions_walk,
      'visibility': Icons.visibility,
      'pan_tool': Icons.pan_tool,
      'airline_seat_recline_normal': Icons.airline_seat_recline_normal,
      'air': Icons.air,
      'fitness_center': Icons.fitness_center,
    };
    return iconMap[iconName] ?? Icons.fitness_center;
  }
}

// Settings page (separate window)
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // Reuse HomePage UI but in navigation
    return const HomePage();
  }
}
