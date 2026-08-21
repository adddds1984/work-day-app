import packagefluttermaterialdart;
import packageproviderproviderdart;
import ../models/work_day.dart;
import ../providers/work_day_provider.dart;
import ../utils/app_colors.dart;
import ../widgets/work_day_tile.dart;

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
      appBar: AppBar(title: const Text(stat)),
      body: Column(children: [
        _buildYearPicker(provider),
        if (!provider.isYearMode) _buildMonthPicker(provider),
        Expanded(child: provider.isYearMode ? _buildYearStats(provider) : _buildMonthStats(provider)),
      ]),
    );
  }
}
