import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/work_day.dart';
import '../providers/work_day_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/work_day_tile.dart';

class StatsScreen extends StatefulWidget {
  final WorkDayProvider provider;
  const StatsScreen({super.key, required this.provider});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: Column(children: [
        _buildYearPicker(provider),
        if (!provider.isYearMode) _buildMonthPicker(provider),
        Expanded(child: provider.isYearMode ? _buildYearStats(provider) : _buildMonthStats(provider)),
      ]),
    );
  }

  Widget _buildYearPicker(WorkDayProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.primaryLight,
      child: Row(children: [
        const Text('年份：', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<DateTime>(
            value: DateTime(provider.selectedYear, 1),
            isExpanded: true,
            underline: const SizedBox(),
            items: List.generate(10, (i) {
              final year = DateTime.now().year - 5 + i;
              return DropdownMenuItem(
                value: DateTime(year, 1),
                child: Text(''),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                provider.setSelectedYearMonth(value);
                provider.setYearView();
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildMonthPicker(WorkDayProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.primaryLight,
      child: Row(children: [
        const Text('月份：', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<DateTime>(
            value: DateTime(provider.selectedYear, provider.selectedMonth),
            isExpanded: true,
            underline: const SizedBox(),
            items: List.generate(12, (i) {
              final month = i + 1;
              return DropdownMenuItem(
                value: DateTime(provider.selectedYear, month),
                child: Text(''),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                provider.setSelectedYearMonth(value);
                provider.setMonthView();
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildMonthStats(WorkDayProvider provider) {
    final stats = provider.getMonthlyStats(provider.selectedYear, provider.selectedMonth);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSummaryCard(stats),
        const SizedBox(height: 16),
        Text('明细', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (stats.records.isEmpty)
          const Center(child: Text('暂无记录', style: TextStyle(color: Colors.grey)))
        else
          ...stats.records.map((r) => WorkDayTile(record: r)),
      ]),
    );
  }

  Widget _buildYearStats(WorkDayProvider provider) {
    final stats = provider.getYearlyStats(provider.selectedYear);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSummaryCard(stats),
        const SizedBox(height: 16),
        const Text('月度汇总', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildMonthlyTable(stats),
        const SizedBox(height: 16),
        const Text('全年明细', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (stats.records.isEmpty)
          const Center(child: Text('暂无记录', style: TextStyle(color: Colors.grey)))
        else
          ...stats.records.map((r) => WorkDayTile(record: r)),
      ]),
    );
  }

  Widget _buildSummaryCard(MonthlyStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(
            stats is YearlyStats ? '年' : stats.monthLabel,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildStatItem('总天数', '', AppColors.primary),
              _buildStatItem('白班', '', const Color(0xFF1976D2)),
              _buildStatItem('加班', '', const Color(0xFFF57C00)),
              _buildStatItem('出差', '', const Color(0xFF388E3C)),
              _buildStatItem('休息', '', Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('总收入：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(
                '¥',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }

  Widget _buildMonthlyTable(YearlyStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('月份', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('白班', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('加班', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('出差', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('休息', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('总收入', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(12, (i) {
            final month = i + 1;
            final m = stats.monthlyStats[month]!;
            return DataRow(cells: [
              DataCell(Text('')),
              DataCell(Text('')),
              DataCell(Text('')),
              DataCell(Text('')),
              DataCell(Text('')),
              DataCell(Text('¥')),
            ]);
          }),
        ),
      ),
    );
  }
}
