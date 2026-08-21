import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'work_day.g.dart';

enum WorkDayType { whiteShift, overtime, businessTrip, rest }

extension WorkDayTypeExtension on WorkDayType {
  String get label {
    switch (this) {
      case WorkDayType.whiteShift: return '白班';
      case WorkDayType.overtime: return '加班';
      case WorkDayType.businessTrip: return '出差';
      case WorkDayType.rest: return '休息';
    }
  }
  Color get color => _Colors.colors[this]!;
  IconData get icon => _Colors.icons[this]!;
}

class _Colors {
  static const Map<WorkDayType, Color> colors = {
    WorkDayType.whiteShift: Color(0xFF1976D2),
    WorkDayType.overtime: Color(0xFFF57C00),
    WorkDayType.businessTrip: Color(0xFF388E3C),
    WorkDayType.rest: Color(0xFF9E9E9E),
  };
  static const Map<WorkDayType, IconData> icons = {
    WorkDayType.whiteShift: Icons.wb_sunny,
    WorkDayType.overtime: Icons.nights_stay,
    WorkDayType.businessTrip: Icons.flight,
    WorkDayType.rest: Icons.bed,
  };
}

@HiveType(typeId: 0)
class WorkDayRecord extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) DateTime date;
  @HiveField(2) WorkDayType type;
  @HiveField(3) double price;
  @HiveField(4) String note;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) DateTime updatedAt;

  WorkDayRecord({String? id, required this.date, required this.type, required this.price, this.note = '', DateTime? createdAt, DateTime? updatedAt})
    : id = id ?? const Uuid().v4(),
      createdAt = createdAt ?? DateTime.now(),
      updatedAt = updatedAt ?? DateTime.now();

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
  String get displayDate => '${date.year}年${date.month}月${date.day}日';
  String get shortDisplay => '${date.month}月${date.day}日';

  WorkDayRecord copyWith({WorkDayType? type, double? price, String? note, DateTime? date}) {
    return WorkDayRecord(id: id, date: date ?? this.date, type: type ?? this.type, price: price ?? this.price, note: note ?? this.note, createdAt: createdAt, updatedAt: DateTime.now());
  }

  @override
  String toString() => "WorkDayRecord(, , , "")";
}

@HiveType(typeId: 1)
class PriceConfig extends HiveObject {
  @HiveField(0) double whiteShiftPrice;
  @HiveField(1) double overtimePrice;
  @HiveField(2) double businessTripPrice;
  @HiveField(3) double restPrice;

  PriceConfig({this.whiteShiftPrice = 300.0, this.overtimePrice = 400.0, this.businessTripPrice = 350.0, this.restPrice = 0.0});

  double getPrice(WorkDayType type) {
    switch (type) {
      case WorkDayType.whiteShift: return whiteShiftPrice;
      case WorkDayType.overtime: return overtimePrice;
      case WorkDayType.businessTrip: return businessTripPrice;
      case WorkDayType.rest: return restPrice;
    }
  }

  void setPrice(WorkDayType type, double price) {
    switch (type) {
      case WorkDayType.whiteShift: whiteShiftPrice = price; break;
      case WorkDayType.overtime: overtimePrice = price; break;
      case WorkDayType.businessTrip: businessTripPrice = price; break;
      case WorkDayType.rest: restPrice = price; break;
    }
  }
}

String _pad2(int v) => v.toString().padLeft(2, '0');
