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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primaryLight,
      child: Row(children: [
        const Icon(Icons.calendar_today, color: AppColors.primary),
        const SizedBox(width: 8),
        const Text('年份', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: provider.selectedYear,
          underline: const SizedBox(),
          items: List.generate(10, (i) => DropdownMenuItem(
            value: provider.selectedYear - 5 + i,
            child: Text('${provider.selectedYear - 5 + i} 年'),
          )),
          onChanged: (v) => provider.setSelectedYearMonth(DateTime(v ?? provider.selectedYear, provider.selectedMonth)),
        ),
        const Spacer(),
        Row(children: [
          _buildToggleBtn('月统计', !provider.isYearMode, () => provider.setMonthView()),
          const SizedBox(width: 8),
          _buildToggleBtn('年统计', provider.isYearMode, () => provider.setYearView()),
        ]),
      ]),
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.grey[200], borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    ),
  );

  Widget _buildMonthPicker(WorkDayProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(children: [
        const Text('月份：', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Wrap(spacing: 6, runSpacing: 6, children: List.generate(12, (i) {
            final m = i + 1;
            final selected = m == provider.selectedMonth;
            return ChoiceChip(
              label: Text('${m}月'),
              selected: selected,
              onSelected: (_) => provider.setSelectedYearMonth(DateTime(provider.selectedYear, m)),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
            );
          })),
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
        const Text('工日明细', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (stats.records.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('本月暂无工日记录', style: TextStyle(color: Colors.grey))))
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
        const Text('年度明细', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (stats.records.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('本年暂无工日记录', style: TextStyle(color: Colors.grey))))
        else
          ...stats.records.map((r) => WorkDayTile(record: r)),
      ]),
    );
  }

  Widget _buildSummaryCard(MonthlyStats stats) {
    final isMonthly = stats is MonthlyStats;
    final year = stats.year;
    final month = isMonthly ? stats.month : null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Text('${year}年${month != null ? '${month}月' : '全年'}统计', style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildStatItem('总天数', '${stats.totalWorkDays}', Colors.white),
          _buildStatItem('总收入', '¥${stats.totalIncome.toStringAsFixed(0)}', Colors.yellow[100]!),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildStatItem('白班', '${stats.whiteShiftDays}', WorkDayType.whiteShift.color),
          _buildStatItem('加班', '${stats.overtimeDays}', WorkDayType.overtime.color),
          _buildStatItem('出差', '${stats.businessTripDays}', WorkDayType.businessTrip.color),
          _buildStatItem('休息', '${stats.restDays}', WorkDayType.rest.color),
        ]),
      ]),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) => Column(
    children: [Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)))],
  );

  Widget _buildMonthlyTable(YearlyStats stats) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        _buildTableRow(['月份', '白班', '加班', '出差', '休息', '天数', '收入'], isHeader: true),
        ...stats.monthlyStats.entries.map((e) => _buildTableRow([
          '${_pad2(e.key)}月',
          '${e.value.whiteShiftDays}',
          '${e.value.overtimeDays}',
          '${e.value.businessTripDays}',
          '${e.value.restDays}',
          '${e.value.totalWorkDays}',
          '¥${e.value.totalIncome.toStringAsFixed(0)}',
        ])),
        _buildTableRow(['合计', '${stats.whiteShiftDays}', '${stats.overtimeDays}', '${stats.businessTripDays}', '${stats.restDays}', '${stats.totalWorkDays}', '¥${stats.totalIncome.toStringAsFixed(0)}'], isTotal: true),
      ]),
    );
  }

  Widget _buildTableRow(List<String> values, {bool isHeader = false, bool isTotal = false}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
    child: Row(children: values.map((v) => Expanded(child: Text(v, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal, color: isHeader ? Colors.white : (isTotal ? AppColors.primary : Colors.black87))))).toList()),
  );
}

String _pad2(int v) => v.toString().padLeft(2, '0');





