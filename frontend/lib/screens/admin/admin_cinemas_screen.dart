import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../model/admin/cinema_dto.dart';
import '../../services/admin/admin_cinema_api_service.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'admin_dashboard_screen.dart';
import 'admin_movies_screen.dart';
import 'admin_trailers_screen.dart';

class AdminCinemasScreen extends StatefulWidget {
  const AdminCinemasScreen({super.key});

  @override
  State<AdminCinemasScreen> createState() => _AdminCinemasScreenState();
}

class _AdminCinemasScreenState extends State<AdminCinemasScreen> {
  final _api = AdminCinemaApiService();
  final _searchCtl = TextEditingController();

  Future<List<CinemaDto>>? future;
  bool showInactive = true;

  void load() {
    setState(() {
      future = _api.list();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> openCreateDialog() async {
    final result = await showDialog<_CinemaFormResult>(
      context: context,
      builder: (_) => const _CinemaFormDialog(
        title: 'Add cinema',
      ),
    );
    if (result == null) return;

    await _api.create(
      name: result.name,
      address: result.address,
      city: result.city,
      imageUrl: result.imageUrl,
      isActive: result.isActive,
    );

    if (!mounted) return;
    load();
  }

  Future<void> openEditDialog(CinemaDto cinema) async {
    final result = await showDialog<_CinemaFormResult>(
      context: context,
      builder: (_) => _CinemaFormDialog(
        title: 'Edit cinema',
        initialName: cinema.name,
        initialAddress: cinema.address,
        initialCity: cinema.city,
        initialImageUrl: cinema.imageUrl,
        initialIsActive: cinema.isActive,
      ),
    );
    if (result == null) return;

    await _api.update(
      id: cinema.id,
      name: result.name,
      address: result.address,
      city: result.city,
      imageUrl: result.imageUrl,
      isActive: result.isActive,
    );

    if (!mounted) return;
    load();
  }

  Future<void> toggleActive(CinemaDto cinema) async {
    final nextActive = !cinema.isActive;
    if (!nextActive) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: const Text(
            'Deactivate cinema?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '${cinema.name} (#${cinema.id})',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Deactivate'),
            ),
          ],
        ),
      );
      if (ok != true) return;

      await _api.deactivate(cinema.id);
    } else {
      await _api.update(
        id: cinema.id,
        name: cinema.name,
        address: cinema.address,
        city: cinema.city,
        imageUrl: cinema.imageUrl,
        isActive: true,
      );
    }

    if (!mounted) return;
    load();
  }

  List<CinemaDto> _applyFilter(List<CinemaDto> list) {
    final term = _searchCtl.text.trim().toLowerCase();
    Iterable<CinemaDto> filtered = list;

    if (!showInactive) {
      filtered = filtered.where((c) => c.isActive);
    }

    if (term.isNotEmpty) {
      filtered = filtered.where((c) {
        final haystack = '${c.name} ${c.address} ${c.city}'.toLowerCase();
        return haystack.contains(term);
      });
    }

    return filtered.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AdminDrawer(
        currentRoute: 'cinemas',
        onMenuTap: (routeKey) {
          if (routeKey == 'cinemas') {
            Navigator.pop(context);
            return;
          }

          final navigator = Navigator.of(context, rootNavigator: true);
          Navigator.pop(context);

          Future.delayed(const Duration(milliseconds: 200), () {
            Widget? screen;
            switch (routeKey) {
              case 'dashboard':
                screen = const AdminDashboardScreen();
                break;
              case 'trailers':
                screen = const AdminTrailersScreen();
                break;
              case 'movies':
                screen = const AdminMoviesScreen();
                break;
            }

            if (screen != null) {
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => screen!),
              );
            }
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Admin - Cinemas',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: load,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
          ),
          IconButton(
            tooltip: 'Add cinema',
            onPressed: openCreateDialog,
            icon: const Icon(Icons.add, color: AppColors.accent),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: AppColors.backgroundCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSearchField(),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.divider, height: 16),
                    _buildActiveToggle(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<CinemaDto>>(
                future: future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snap.error}',
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final list = _applyFilter(snap.data ?? []);
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'No cinemas',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final c = list[i];
                      return _buildCinemaCard(c);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinemaCard(CinemaDto cinema) {
    final statusColor = cinema.isActive ? AppColors.success : AppColors.error;
    final statusLabel = cinema.isActive ? 'Active' : 'Inactive';
    final addressLine = cinema.address.trim();
    final cityLine = cinema.city.trim();
    final hasAddress = addressLine.isNotEmpty || cityLine.isNotEmpty;

    return Card(
      color: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCinemaAvatar(cinema.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${cinema.name} (#${cinema.id})',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusPill(label: statusLabel, color: statusColor),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (addressLine.isNotEmpty)
                        Text(
                          addressLine,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      if (cityLine.isNotEmpty)
                        Text(
                          cityLine,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      if (!hasAddress)
                        const Text(
                          'No address info',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionLink(
                  icon: Icons.edit,
                  label: 'Edit',
                  color: AppColors.warning,
                  onTap: () => openEditDialog(cinema),
                ),
                const SizedBox(width: 16),
                _buildActionLink(
                  icon: cinema.isActive ? Icons.block : Icons.check_circle,
                  label: cinema.isActive ? 'Deactivate' : 'Activate',
                  color: cinema.isActive ? AppColors.error : AppColors.success,
                  onTap: () => toggleActive(cinema),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinemaAvatar(String imageUrl) {
    final trimmed = imageUrl.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 54,
        height: 54,
        color: AppColors.surface,
        child: trimmed.isEmpty
            ? const Icon(Icons.location_city, color: AppColors.textHint)
            : Image.network(
                trimmed,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(Icons.location_city, color: AppColors.textHint),
                ),
              ),
      ),
    );
  }

  Widget _buildStatusPill({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionLink({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchCtl,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search by name, address, city',
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: const Icon(Icons.search, color: AppColors.searchIcon),
        filled: true,
        fillColor: AppColors.searchBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onSubmitted: (_) => setState(() {}),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildActiveToggle() {
    return Row(
      children: [
        const Text(
          'Show inactive',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const Spacer(),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: showInactive,
            onChanged: (v) => setState(() => showInactive = v),
            activeColor: AppColors.backgroundLight,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: AppColors.textHint,
            inactiveTrackColor: AppColors.border,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class _CinemaFormResult {
  final String name;
  final String address;
  final String city;
  final String imageUrl;
  final bool isActive;

  _CinemaFormResult({
    required this.name,
    required this.address,
    required this.city,
    required this.imageUrl,
    required this.isActive,
  });
}

class _CinemaFormDialog extends StatefulWidget {
  final String title;
  final String initialName;
  final String initialAddress;
  final String initialCity;
  final String initialImageUrl;
  final bool initialIsActive;

  const _CinemaFormDialog({
    required this.title,
    this.initialName = '',
    this.initialAddress = '',
    this.initialCity = '',
    this.initialImageUrl = '',
    this.initialIsActive = true,
  });

  @override
  State<_CinemaFormDialog> createState() => _CinemaFormDialogState();
}

class _CinemaFormDialogState extends State<_CinemaFormDialog> {
  late final TextEditingController nameCtl;
  late final TextEditingController addressCtl;
  late final TextEditingController cityCtl;
  late final TextEditingController imageCtl;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    nameCtl = TextEditingController(text: widget.initialName);
    addressCtl = TextEditingController(text: widget.initialAddress);
    cityCtl = TextEditingController(text: widget.initialCity);
    imageCtl = TextEditingController(text: widget.initialImageUrl);
    isActive = widget.initialIsActive;
  }

  @override
  void dispose() {
    nameCtl.dispose();
    addressCtl.dispose();
    cityCtl.dispose();
    imageCtl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent),
        ),
      );

  void _submit() {
    final name = nameCtl.text.trim();
    final address = addressCtl.text.trim();
    final city = cityCtl.text.trim();
    final imageUrl = imageCtl.text.trim();

    if (name.isEmpty || address.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, address, and city are required.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _CinemaFormResult(
        name: name,
        address: address,
        city: city,
        imageUrl: imageUrl,
        isActive: isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      title: Text(
        widget.title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressCtl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('Address'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cityCtl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('City'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: imageCtl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('Image URL (optional)'),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
              activeColor: AppColors.accent,
              title: const Text('Active', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
          ),
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
