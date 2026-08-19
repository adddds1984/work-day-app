import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/work_day.dart';
import '../providers/work_day_provider.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final WorkDayProvider provider;
  const HomeScreen({super.key, required this.provider});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记工日')),
      body: Column(children: [_buildCalendar(), _buildSelectedDateInfo()]),
    );
  }

  Widget _buildCalendar() {
    final provider = widget.provider;
    return Container(
      padding: const EdgeInsets.all(8),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
          _showEditDialog(context, selectedDay);
        },
        onFormatChanged: (format) { if (_calendarFormat != format) setState(() => _calendarFormat = format); },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
          todayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        headerStyle: const HeaderStyle(
          formatButtonDecoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.all(Radius.circular(20))),
          formatButtonTextStyle: TextStyle(color: Colors.white),
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12), weekendStyle: TextStyle(color: Colors.red, fontSize: 12)),
        eventLoader: (day) {
          final record = provider.getRecord(DateTime(day.year, day.month, day.day));
          return record != null ? [record] : [];
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            final record = events.first as WorkDayRecord;
            return Positioned(bottom: 2, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: record.type.color, shape: BoxShape.circle)));
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    if (_selectedDay == null) {
      return const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('点击日期添加工日记录', style: TextStyle(color: Colors.grey))));
    }
    final provider = widget.provider;
    final record = provider.getRecord(_selectedDay!);
    final normalizedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(DateFormat('yyyy年MM月dd日').format(normalizedDate), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 12),
        if (record != null) ...[
          _buildInfoRow('工日类型', record.type.label, record.type.color),
          const SizedBox(height: 8),
          _buildInfoRow('当日单价', '${record.price.toStringAsFixed(0)}'),
          if (record.note.isNotEmpty) ...[const SizedBox(height: 8), _buildInfoRow('备注', record.note)],
        ],
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showEditDialog(context, normalizedDate),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('编辑'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
      ]),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? color]) {
    return Row(children: [
      Text('\label：', style: const TextStyle(color: Colors.grey)),
      Expanded(child: Text(value, style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
    ]);
  }

  void _showEditDialog(BuildContext context, DateTime date) {
    final provider = widget.provider;
    final existing = provider.getRecord(date);
    final config = provider.priceConfig;
    WorkDayType selectedType = existing?.type ?? WorkDayType.whiteShift;
    double selectedPrice = existing?.price ?? config.getPrice(selectedType);
    String noteText = existing?.note ?? '';
    final priceController = TextEditingController(text: selectedPrice.toStringAsFixed(0));

    showDialog(context: context, builder: (dialogContext) {
      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: Text('编辑工日 - ', style: const TextStyle(fontSize: 18)),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('工日类型', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: WorkDayType.values.map((type) {
              final isSelected = type == selectedType;
              return ChoiceChip(
                label: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: type.color, shape: BoxShape.circle)),
                  const SizedBox(width: 6), Text(type.label),
                ]),
                selected: isSelected,
                onSelected: (_) => setDialogState(() { selectedType = type; selectedPrice = config.getPrice(type); priceController.text = selectedPrice.toStringAsFixed(0); }),
                selectedColor: type.color.withOpacity(0.2),
                backgroundColor: Colors.grey[100],
              );
            }).toList()),
            const SizedBox(height: 16),
            const Text('当日单价（元）', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*(\.\d*)?\$'))],
              decoration: const InputDecoration(prefixText: '¥ ', border: OutlineInputBorder(), hintText: '请输入金额'),
              onChanged: (v) { final p = double.tryParse(v); if (p != null) setDialogState(() => selectedPrice = p); },
            ),
            const SizedBox(height: 16),
            const Text('备注（可选）', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '输入备注信息...'),
              controller: TextEditingController(text: noteText),
              onChanged: (v) => setDialogState(() => noteText = v),
            ),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
            if (existing != null) TextButton(onPressed: () => _confirmDelete(dialogContext, date), child: const Text('删除', style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(priceController.text);
                if (price == null || price < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入有效的单价')));
                  return;
                }
                _saveRecord(dialogContext, date, selectedType, price, noteText);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('保存'),
            ),
          ],
        );
      });
    });
  }

  Future<void> _saveRecord(BuildContext context, DateTime date, WorkDayType type, double price, String note) async {
    final provider = widget.provider;
    final existing = provider.getRecord(date);
    await provider.saveRecord(WorkDayRecord(id: existing?.id, date: date, type: type, price: price, note: note));
    if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存成功'))); }
  }

  void _confirmDelete(BuildContext context, DateTime date) {
    showDialog(context: context, builder: (dialogContext) {
      return AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ' + DateFormat('MM月dd日').format(date) + ' 的工日记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              await widget.provider.deleteRecord(date);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('删除成功'))); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      );
    });
  }
}





