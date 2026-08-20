import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/work_day.dart';
import '../providers/work_day_provider.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  final WorkDayProvider provider;
  const SettingsScreen({super.key, required this.provider});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Map<WorkDayType, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final type in WorkDayType.values) {
      _controllers[type] = TextEditingController(text: widget.provider.priceConfig.getPrice(type).toStringAsFixed(0));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('工日单价设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('设置各类型工日的默认单价，新建工日时自动带入', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 24),
        ...WorkDayType.values.map((type) => _buildPriceTile(type)),
        const SizedBox(height: 32),
        const Text('数据管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDataAction(icon: Icons.save, title: '导出数据', subtitle: '导出所有工日记录为文本文件', onTap: _exportData),
        const SizedBox(height: 12),
        _buildDataAction(icon: Icons.delete_forever, title: '清空所有数据', subtitle: '删除所有工日记录和设置', color: Colors.red, onTap: _clearAllData),
        const SizedBox(height: 24),
        const Text('关于', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const _AboutCard(),
      ])),
    );
  }

  Widget _buildPriceTile(WorkDayType type) {
    final controller = _controllers[type]!;
    return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))]), child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: type.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(type.icon, color: type.color, size: 24)),
      const SizedBox(width: 16),
      Expanded(child: Text(type.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
      SizedBox(width: 100, child: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*(\.\d*)?$'))], decoration: InputDecoration(prefixText: '¥ ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: type.color)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)), textAlign: TextAlign.right, onChanged: (v) { final price = double.tryParse(v); if (price != null && price >= 0) { widget.provider.priceConfig.setPrice(type, price); widget.provider.updatePriceConfig(widget.provider.priceConfig); } }),
    ]));
  }

  Widget _buildDataAction({required IconData icon, required String title, required String subtitle, Color color = Colors.blue, required VoidCallback onTap}) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))]), child: Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600]))])), Icon(Icons.chevron_right, color: Colors.grey[400])]));

  void _exportData() {
    final config = widget.provider.priceConfig;
    final now = DateTime.now();
    String content = '工日数据导出 - ${now.year}年${now.month}月${now.day}日\n\n';
    content += '=== 单价设置 ===\n白班: ¥${config.whiteShiftPrice}\n加班: ¥${config.overtimePrice}\n出差: ¥${config.businessTripPrice}\n休息: ¥${config.restPrice}\n\n';
    content += '=== 工日记录 ===\n';
    for (int year = 2020; year <= now.year; year++) {
      for (int month = 1; month <= 12; month++) {
        final records = widget.provider.getMonthRecords(year, month);
        if (records.isNotEmpty) {
          content += '\n--- $year年$month月 ---\n';
          for (final r in records) content += '  ¥${r.price}\n';
        }
      }
    }
    showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Text('导出数据'), content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: SelectableText(content))), actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('关闭')),
      ElevatedButton.icon(onPressed: () { Clipboard.setData(ClipboardData(text: content)); if (dialogContext.mounted) { Navigator.pop(dialogContext); ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('已复制到剪贴板'))); } }, icon: const Icon(Icons.copy), label: const Text('复制')),
    ]));
  }

  void _clearAllData() {
    showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Text('确认清空数据'), content: const Text('此操作将删除所有工日记录和设置，且无法恢复。确定要继续吗？'), actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
      ElevatedButton(onPressed: () async { await widget.provider.clearAllData(); if (dialogContext.mounted) Navigator.pop(dialogContext); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('数据已清空'))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('确认清空')),
    ]));
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))]), child: const Column(children: [Text('记工日', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('版本 2.0.0', style: TextStyle(color: Colors.grey)), SizedBox(height: 8), Text('离线工日记录工具', style: TextStyle(color: Colors.grey)), SizedBox(height: 16), Text('所有数据保存在本地，无需联网', style: TextStyle(color: Colors.grey, fontSize: 12))],));
}




