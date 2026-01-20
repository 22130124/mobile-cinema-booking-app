import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../model/admin/report_overview_dto.dart';
import '../../services/admin/reports_api_service.dart';
import '../../services/admin/cinema_api_service.dart';
import '../../model/admin/cinema_dto.dart';
import 'admin_cinemas_screen.dart';
import 'admin_trailers_screen.dart';

// Chart
import '../../model/admin/daily_revenue_point_dto.dart';
import '../../widgets/admin/revenue_line_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _api = ReportsApiService();
  final _cinemaApi = CinemaApiService();

  late DateTime from;
  late DateTime to;
  DateTime? lastUpdatedAt;

  Future<ReportOverviewDto>? future;
  Future<List<DailyRevenuePointDto>>? chartFuture;
  List<CinemaDto> cinemas = [];
  int? selectedCinemaId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    from = DateTime(now.year, now.month, 1, 0, 0, 0);
    to = now;
    _reload();
    _loadCinemas();
  }

  String _fmt(DateTime dt) => dt.toString().replaceFirst('.000', '');

  String _formatVnd(double value) {
    final s = value.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final reverseIndex = s.length - i;
      buf.write(s[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buf.write(',');
    }
    return '${buf.toString()} ₫';
  }

  void _reload() {
    setState(() {
      future = _api.getOverview(from: from, to: to, cinemaId: selectedCinemaId);
      chartFuture = _api.getRevenueDaily(from: from, to: to, cinemaId: selectedCinemaId);
      lastUpdatedAt = DateTime.now();
    });
  }

  void _refreshAll() {
    _reload();
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    try {
      cinemas = await _cinemaApi.list();
      setState(() {});
    } catch (e) {
      // ignore errors for cinema list (keep UI usable)
    }
  }

  void _setPresetToday() {
    final now = DateTime.now();
    setState(() {
      from = DateTime(now.year, now.month, now.day, 0, 0, 0);
      to = now;
    });
    _reload();
  }

  void _setPreset7d() {
    final now = DateTime.now();
    setState(() {
      from = now.subtract(const Duration(days: 7));
      to = now;
    });
    _reload();
  }

  void _setPreset30d() {
    final now = DateTime.now();
    setState(() {
      from = now.subtract(const Duration(days: 30));
      to = now;
    });
    _reload();
  }

  void _setPresetThisMonth() {
    final now = DateTime.now();
    setState(() {
      from = DateTime(now.year, now.month, 1, 0, 0, 0);
      to = now;
    });
    _reload();
  }

  Future<void> _pickDateTime({
    required DateTime current,
    required ValueChanged<DateTime> onChanged,
  }) async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: current,
    );
    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (t == null) return;

    onChanged(DateTime(d.year, d.month, d.day, t.hour, t.minute, 0));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final chartCard = Card(
      color: AppColors.backgroundCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue chart',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<DailyRevenuePointDto>>(
                future: chartFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Lỗi chart: ${snap.error}',
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final points = snap.data ?? [];
                  if (points.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có dữ liệu chart trong khoảng thời gian này',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return RevenueLineChart(points: points);
                },
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Admin • Thống kê'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCinemasScreen()),
              );
              if (!mounted) return;
              _loadCinemas();
            },
            icon: const Icon(Icons.location_city, color: AppColors.accent),
            label: const Text(
              'Cinemas',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminTrailersScreen()),
            ),
            icon: const Icon(Icons.movie, color: AppColors.accent),
            label: const Text(
              'Trailers',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preset filters
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PresetChip(label: 'Today', onTap: _setPresetToday),
                _PresetChip(label: '7 days', onTap: _setPreset7d),
                _PresetChip(label: '30 days', onTap: _setPreset30d),
                _PresetChip(label: 'This month', onTap: _setPresetThisMonth),
                  // Cinema filter dropdown styled to match admin theme
                  ConstrainedBox(
                    // Reduced width so dropdown aligns better with chips
                    constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isDense: true,
                          iconSize: 20,
                          value: selectedCinemaId,
                          hint: Text('All cinemas', style: TextStyle(color: AppColors.textSecondary)),
                          dropdownColor: AppColors.backgroundCard,
                          style: TextStyle(color: AppColors.textPrimary),
                          iconEnabledColor: AppColors.accent,
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All cinemas', style: TextStyle(color: AppColors.textPrimary)),
                            ),
                            ...cinemas.map((c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.name, style: TextStyle(color: AppColors.textPrimary)),
                                )),
                          ],
                          onChanged: (v) {
                            setState(() => selectedCinemaId = v);
                            _reload();
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Custom range (auto-update, no apply button)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => _pickDateTime(
                    current: from,
                    onChanged: (v) {
                      setState(() => from = v);
                      _reload();
                    },
                  ),
                  child: Text('From: ${_fmt(from)}'),
                ),
                OutlinedButton(
                  onPressed: () => _pickDateTime(
                    current: to,
                    onChanged: (v) {
                      setState(() => to = v);
                      _reload();
                    },
                  ),
                  child: Text('To: ${_fmt(to)}'),
                ),
                if (lastUpdatedAt != null)
                  Text(
                    'Last updated: ${_fmt(lastUpdatedAt!)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<ReportOverviewDto>(
                future: future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Lỗi: ${snap.error}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  final data = snap.data!;
                  final cards = <Widget>[
                    _KpiCard(
                      title: 'Total revenue',
                      value: _formatVnd(data.totalRevenue),
                      icon: Icons.payments,
                    ),
                    _KpiCard(
                      title: 'Paid orders',
                      value: data.totalPaidOrders.toString(),
                      icon: Icons.receipt_long,
                    ),
                    _KpiCard(
                      title: 'Tickets sold',
                      value: data.totalTicketsSold.toString(),
                      icon: Icons.confirmation_number,
                    ),
                  ];

                  if (isWide) {
                    return Column(
                      children: [
                        Row(
                          children: cards
                              .map(
                                (c) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: c,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: chartCard),
                      ],
                    );
                  }

                  return ListView(
                    children: [
                      ...cards.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: c,
                        ),
                      ),
                      SizedBox(height: 320, child: chartCard),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      side: const BorderSide(color: AppColors.border),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
