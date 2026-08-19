import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/work_day.dart';

class WorkDayProvider extends ChangeNotifier {
  static const String _workDayBoxName = 'work_days';
  static const String _priceConfigKey = 'price_config';

  late Box<WorkDayRecord> _box;
  PriceConfig? _priceConfig;
  List<WorkDayRecord> _records = [];
  DateTime _selectedYearMonth = DateTime.now();
  bool _isYearMode = false;

  List<WorkDayRecord> get records => _records;
  PriceConfig get priceConfig => _priceConfig ??= PriceConfig();
  DateTime get selectedYearMonth => _selectedYearMonth;
  int get selectedYear => _selectedYearMonth.year;
  int get selectedMonth => _selectedYearMonth.month;
  bool get isYearMode => _isYearMode;

  Future<void> init() async {
    try {
      _box = await Hive.openBox<WorkDayRecord>(_workDayBoxName);
      _loadPriceConfig();
      _loadRecords();
    } catch (e) {
      debugPrint('Hive error: $e');
      _priceConfig = PriceConfig();
      _records = [];
    }
  }

  void _loadPriceConfig() {
    _priceConfig = _box.get(_priceConfigKey);
    _priceConfig ??= PriceConfig();
  }

  void _loadRecords() {
    _records = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void updatePriceConfig(PriceConfig config) {
    _priceConfig = config;
    _box.put(_priceConfigKey, config);
    notifyListeners();
  }

  WorkDayRecord? getRecord(DateTime date) => _box.get(_dateKey(date));

  Future<void> saveRecord(WorkDayRecord record) async {
    try {
      final key = record.dateKey;
      final existing = _box.get(key);
      if (existing != null) record.id = existing.id;
      await _box.put(key, record);
      _loadRecords();
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  Future<void> deleteRecord(DateTime date) async {
    try {
      await _box.delete(_dateKey(date));
      _loadRecords();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  List<WorkDayRecord> getMonthRecords(int year, int month) =>
      _records.where((r) => r.date.year == year && r.date.month == month).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<WorkDayRecord> getYearRecords(int year) =>
      _records.where((r) => r.date.year == year).toList()..sort((a, b) => a.date.compareTo(b.date));

  Set<DateTime> getMonthMarkedDates(int year, int month) {
    return getMonthRecords(year, month)
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();
  }

  MonthlyStats getMonthlyStats(int year, int month) {
    return _calculateStats(getMonthRecords(year, month), year, month);
  }

  YearlyStats getYearlyStats(int year) {
    final records = getYearRecords(year);
    final monthlyStats = <int, MonthlyStats>{};
    for (int m = 1; m <= 12; m++) monthlyStats[m] = getMonthlyStats(year, m);
    return _calculateYearlyStats(records, year, monthlyStats);
  }

  MonthlyStats _calculateStats(List<WorkDayRecord> records, int year, int month) {
    var whiteShiftDays = 0, overtimeDays = 0, businessTripDays = 0, restDays = 0;
    var totalIncome = 0.0;
    for (final r in records) {
      switch (r.type) {
        case WorkDayType.whiteShift: whiteShiftDays++; totalIncome += r.price; break;
        case WorkDayType.overtime: overtimeDays++; totalIncome += r.price; break;
        case WorkDayType.businessTrip: businessTripDays++; totalIncome += r.price; break;
        case WorkDayType.rest: restDays++; break;
      }
    }
    return MonthlyStats(year: year, month: month, whiteShiftDays: whiteShiftDays, overtimeDays: overtimeDays, businessTripDays: businessTripDays, restDays: restDays, totalWorkDays: whiteShiftDays + overtimeDays + businessTripDays, totalIncome: totalIncome, records: records);
  }

  YearlyStats _calculateYearlyStats(List<WorkDayRecord> records, int year, Map<int, MonthlyStats> monthlyStats) {
    var whiteShiftDays = 0, overtimeDays = 0, businessTripDays = 0, restDays = 0;
    var totalIncome = 0.0;
    for (final r in records) {
      switch (r.type) {
        case WorkDayType.whiteShift: whiteShiftDays++; totalIncome += r.price; break;
        case WorkDayType.overtime: overtimeDays++; totalIncome += r.price; break;
        case WorkDayType.businessTrip: businessTripDays++; totalIncome += r.price; break;
        case WorkDayType.rest: restDays++; break;
      }
    }
    return YearlyStats(year: year, whiteShiftDays: whiteShiftDays, overtimeDays: overtimeDays, businessTripDays: businessTripDays, restDays: restDays, totalWorkDays: whiteShiftDays + overtimeDays + businessTripDays, totalIncome: totalIncome, monthlyStats: monthlyStats, records: records);
  }

  void setSelectedYearMonth(DateTime date) {
    _selectedYearMonth = DateTime(date.year, date.month);
    if (_isYearMode) _isYearMode = false;
    notifyListeners();
  }

  void setMonthView() { _isYearMode = false; notifyListeners(); }
  void setYearView() { _isYearMode = true; notifyListeners(); }

  Future<void> clearAllData() async {
    try {
      await _box.clear();
      _priceConfig = PriceConfig();
      await _box.put(_priceConfigKey, _priceConfig!);
      _loadRecords();
    } catch (e) {
      debugPrint('Clear error: $e');
    }
  }

  String _dateKey(DateTime date) => '${date.year}-${_pad2(date.month)}-${_pad2(date.day)}';
}

class MonthlyStats {
  final int year, month, whiteShiftDays, overtimeDays, businessTripDays, restDays, totalWorkDays;
  final double totalIncome;
  final List<WorkDayRecord> records;
  MonthlyStats({required this.year, required this.month, required this.whiteShiftDays, required this.overtimeDays, required this.businessTripDays, required this.restDays, required this.totalWorkDays, required this.totalIncome, required this.records});
  String get monthLabel => '${year}年${month}月';
}

class YearlyStats {
  final int year, whiteShiftDays, overtimeDays, businessTripDays, restDays, totalWorkDays;
  final double totalIncome;
  final Map<int, MonthlyStats> monthlyStats;
  final List<WorkDayRecord> records;
  YearlyStats({required this.year, required this.whiteShiftDays, required this.overtimeDays, required this.businessTripDays, required this.restDays, required this.totalWorkDays, required this.totalIncome, required this.monthlyStats, required this.records});
}

String _pad2(int v) => v.toString().padLeft(2, '0');





