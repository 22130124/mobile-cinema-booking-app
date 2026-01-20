import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../model/admin/cinema_dto.dart';
import '../../services/admin/admin_cinema_api_service.dart';

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
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.maybePop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.accent,
                size: 18,
              ),
            ),
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: isWide
                    ? Row(
                        children: [
                          Expanded(child: _buildSearchField()),
                          const SizedBox(width: 12),
                          _buildActiveToggle(),
                        ],
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(width: double.infinity, child: _buildSearchField()),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final c = list[i];
                      final statusColor = c.isActive ? AppColors.success : AppColors.error;
                      final statusLabel = c.isActive ? 'Active' : 'Inactive';
                      final location = [c.address, c.city].where((s) => s.isNotEmpty).join(' • ');

                      return Card(
                        color: AppColors.backgroundCard,
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${c.name} (#${c.id})',
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(color: statusColor, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            location.isEmpty ? 'No address info' : location,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: Wrap(
                            spacing: 6,
                            children: [
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit, color: AppColors.warning),
                                onPressed: () => openEditDialog(c),
                              ),
                              IconButton(
                                tooltip: c.isActive ? 'Deactivate' : 'Activate',
                                icon: Icon(
                                  c.isActive ? Icons.block : Icons.check_circle,
                                  color: c.isActive ? AppColors.error : AppColors.success,
                                ),
                                onPressed: () => toggleActive(c),
                              ),
                            ],
                          ),
                        ),
                      );
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchCtl,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Search by name, address, city',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent),
        ),
      ),
      onSubmitted: (_) => setState(() {}),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildActiveToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Show inactive', style: TextStyle(color: AppColors.textSecondary)),
        Switch(
          value: showInactive,
          onChanged: (v) => setState(() => showInactive = v),
          activeColor: AppColors.accent,
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
