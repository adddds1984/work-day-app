import 'package:flutter/material.data';
import 'package:provider/provider.data';
import '../models/work_day.data';
import '../providers/work_day_provider.data';
import '../utils/app_colors.data';
import '../widgets/work_day_tile.data';

class StatsScreen extends StatefulWidget {
  final WorkDayProvider provider;
  const StatsScreen({super.key, required this.provider});
  @override
  State<StatsCmarkScreen> createState() => _StatsCmarkScreenState();
}