# 记工日 APP - 重构版

## 项目结构

```
work_day_app/
├── lib/
│   ├── main.dart                    # 入口 + 全局Provider
│   ├── models/
│   │   ├── work_day.dart            # 数据模型(HiveObject)
│   │   └── work_day.g.dart          # Hive适配器
│   ├── providers/
│   │   └── work_day_provider.dart   # Provider状态管理
│   ├── screens/
│   │   ├── home_screen.dart         # 日历主页
│   │   ├── stats_screen.dart        # 统计页面
│   │   └── settings_screen.dart     # 设置页面
│   └── utils/
│       └── app_colors.dart          # 颜色/图标常量
├── pubspec.yaml
└── README.md
```

## 重构改进点

### 1. Provider 状态管理
- 使用 `ChangeNotifierProvider` 管理全局状态
- 数据变更自动刷新UI
- 参考 Expense-Tracker 的 ExpenseProvider

### 2. HiveObject 基类
- WorkDayRecord 继承 HiveObject
- 支持 `.save()` / `.delete()` 原生操作
- 使用 uuid 生成唯一ID

### 3. 全局 Hive Box
- 在 main.dart 中初始化全局 Box
- 避免重复打开/关闭 Box

### 4. 常量类
- WorkDayColors 管理颜色和图标
- AppColors 管理主题色

## 运行步骤

```bash
cd work_day_app
flutter pub get
flutter run
```

## 构建 APK

```bash
flutter build apk --release
# APK 位于: build/app/outputs/flutter-apk/app-release.apk
```