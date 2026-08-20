import 'package:flutter/material.dart';
import '../models/work_day.dart';

class WorkDayTile extends StatelessWidget {
  final WorkDayRecord record;
  const WorkDayTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(width: 4, height: 40, decoration: BoxDecoration(color: record.type.color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(record.type.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (record.note.isNotEmpty) Expanded(child: Text(record.note, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Text('  ¥', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ])),
      ]),
    );
  }
}
