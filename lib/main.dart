import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_day_app/providers/work_day_provider.dart';
import 'package:work_day_app/screens/home_screen.dart';
import 'package:work_day_app/screens/stats_screen.dart';
import 'package:work_day_app/screens/settings_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:work_day_app/models/work_day.dart';
import '../utils/app_colors.dart';

/// 主入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WorkDayRecordAdapter());
  Hive.registerAdapter(PriceConfigAdapter());
  Hive.registerAdapter(WorkDayTypeEnumAdapter());
  runApp(const WorkDayApp());
}

/// 主应用
class WorkDayApp extends StatelessWidget {
  const WorkDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkDayProvider()..init(),
      child: MaterialApp(
        title: '记工日',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

/// 主界面 - 底部导航
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final provider = context.read<WorkDayProvider>();
    _pages = [
      HomeScreen(provider: provider),
      StatsScreen(provider: provider),
      SettingsScreen(provider: provider),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '日历'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '统计'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
