import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../model/admin/trailer_admin_dto.dart';
import '../../services/admin/admin_trailer_api_service.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'admin_cinemas_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_movies_screen.dart';

class AdminTrailersScreen extends StatefulWidget {
  const AdminTrailersScreen({super.key});

  @override
  State<AdminTrailersScreen> createState() => _AdminTrailersScreenState();
}

class _AdminTrailersScreenState extends State<AdminTrailersScreen> {
  final _movieIdCtl = TextEditingController(); // rỗng = list all
  final _api = AdminTrailerApiService();

  Future<List<TrailerAdminDto>>? future;

  void load() {
    final raw = _movieIdCtl.text.trim();
    final movieId = raw.isEmpty ? null : int.tryParse(raw);

    setState(() {
      future = _api.list(movieId: movieId);
    });
  }

  Future<void> openYoutube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Không mở được YouTube')));
    }
  }

  Future<void> openCreateDialog() async {
    final initMovieId = int.tryParse(_movieIdCtl.text.trim()) ?? 1;

    final result = await showDialog<_TrailerFormResult>(
      context: context,
      builder: (_) => _TrailerFormDialog(
        title: 'Thêm trailer',
        initialMovieId: initMovieId,
        allowEditMovieId: true,
      ),
    );
    if (result == null) return;

    await _api.create(
      movieId: result.movieId,
      youtubeVideoId: result.youtubeVideoId,
      title: result.title,
    );

    if (!mounted) return;
    load();
  }

  Future<void> openEditDialog(TrailerAdminDto t) async {
    final result = await showDialog<_TrailerFormResult>(
      context: context,
      builder: (_) => _TrailerFormDialog(
        title: 'Sửa trailer',
        initialMovieId: t.movieId,
        initialYoutubeVideoId: t.youtubeVideoId,
        initialTitle: t.title,
        allowEditMovieId: false, // backend update request không có movieId
      ),
    );
    if (result == null) return;

    await _api.update(
      id: t.id,
      youtubeVideoId: result.youtubeVideoId,
      title: result.title,
    );

    if (!mounted) return;
    load();
  }

  Future<void> deleteTrailer(TrailerAdminDto t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Xoá trailer?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${t.title} (#${t.id})',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await _api.delete(t.id);

    if (!mounted) return;
    load();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  @override
  void dispose() {
    _movieIdCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AdminDrawer(
        currentRoute: 'trailers',
        onMenuTap: (routeKey) {
          if (routeKey == 'trailers') {
            Navigator.pop(context);
            return;
          }
          
          // Lấy ROOT navigator (của app)
          final navigator = Navigator.of(context, rootNavigator: true);
          Navigator.pop(context);

          Future.delayed(const Duration(milliseconds: 200), () {
            Widget? screen;
            switch (routeKey) {
              case 'dashboard':
                screen = const AdminDashboardScreen();
                break;
              case 'movies':
                screen = const AdminMoviesScreen();
                break;
              case 'cinemas':
                screen = const AdminCinemasScreen();
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
          'Admin • Trailers',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: load,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
          ),
          IconButton(
            tooltip: 'Thêm trailer',
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
                          Expanded(child: _buildMovieIdField()),
                          const SizedBox(width: 12),
                          _buildFilterButton(),
                        ],
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(width: double.infinity, child: _buildMovieIdField()),
                          _buildFilterButton(),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<TrailerAdminDto>>(
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
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có trailer',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final t = list[i];

                      return Card(
                        color: AppColors.backgroundCard,
                        child: ListTile(
                          title: Text(
                            '${t.title}  (#${t.id})',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            'movieId: ${t.movieId} • ${t.youtubeVideoId}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: Wrap(
                            spacing: 6,
                            children: [
                              IconButton(
                                tooltip: 'Open',
                                icon: const Icon(Icons.open_in_new, color: AppColors.accent),
                                onPressed: t.youtubeVideoId.isEmpty
                                    ? null
                                    : () => openYoutube(t.youtubeVideoId),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit, color: AppColors.warning),
                                onPressed: () => openEditDialog(t),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => deleteTrailer(t),
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

  Widget _buildMovieIdField() {
    return TextField(
      controller: _movieIdCtl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Movie ID (bỏ trống = tất cả)',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accent),
        ),
      ),
      onSubmitted: (_) => load(),
    );
  }

  Widget _buildFilterButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
      ),
      onPressed: load,
      icon: const Icon(Icons.filter_alt),
      label: const Text('Lọc / Tải'),
    );
  }
}

class _TrailerFormResult {
  final int movieId;
  final String youtubeVideoId;
  final String title;

  _TrailerFormResult({
    required this.movieId,
    required this.youtubeVideoId,
    required this.title,
  });
}

class _TrailerFormDialog extends StatefulWidget {
  final String title;
  final int initialMovieId;
  final String initialYoutubeVideoId;
  final String initialTitle;
  final bool allowEditMovieId;

  const _TrailerFormDialog({
    required this.title,
    required this.initialMovieId,
    this.initialYoutubeVideoId = '',
    this.initialTitle = '',
    required this.allowEditMovieId,
  });

  @override
  State<_TrailerFormDialog> createState() => _TrailerFormDialogState();
}

class _TrailerFormDialogState extends State<_TrailerFormDialog> {
  late final TextEditingController movieIdCtl;
  late final TextEditingController youtubeCtl;
  late final TextEditingController titleCtl;

  @override
  void initState() {
    super.initState();
    movieIdCtl = TextEditingController(text: widget.initialMovieId.toString());
    youtubeCtl = TextEditingController(text: widget.initialYoutubeVideoId);
    titleCtl = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    movieIdCtl.dispose();
    youtubeCtl.dispose();
    titleCtl.dispose();
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
              controller: movieIdCtl,
              enabled: widget.allowEditMovieId,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('Movie ID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: youtubeCtl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('YouTube Video ID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleCtl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dec('Title'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            final movieId = int.tryParse(movieIdCtl.text.trim());
            if (movieId == null) return;

            Navigator.pop(
              context,
              _TrailerFormResult(
                movieId: movieId,
                youtubeVideoId: youtubeCtl.text.trim(),
                title: titleCtl.text.trim(),
              ),
            );
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class AdminTrailersContent extends StatefulWidget {
  const AdminTrailersContent({super.key});

  @override
  State<AdminTrailersContent> createState() => _AdminTrailersContentState();
}

class _AdminTrailersContentState extends State<AdminTrailersContent> {
  final _movieIdCtl = TextEditingController();
  final _api = AdminTrailerApiService();

  Future<List<TrailerAdminDto>>? future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  @override
  void dispose() {
    _movieIdCtl.dispose();
    super.dispose();
  }

  void load() {
    final raw = _movieIdCtl.text.trim();
    final movieId = raw.isEmpty ? null : int.tryParse(raw);
    setState(() {
      future = _api.list(movieId: movieId);
    });
  }

  Future<void> openYoutube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Không mở được YouTube')));
    }
  }

  Future<void> openCreateDialog() async {
    final initMovieId = int.tryParse(_movieIdCtl.text.trim()) ?? 1;

    final result = await showDialog<_TrailerFormResult>(
      context: context,
      builder: (_) => _TrailerFormDialog(
        title: 'Thêm trailer',
        initialMovieId: initMovieId,
        allowEditMovieId: true,
      ),
    );
    if (result == null) return;

    await _api.create(
      movieId: result.movieId,
      youtubeVideoId: result.youtubeVideoId,
      title: result.title,
    );

    if (!mounted) return;
    load();
  }

  Future<void> openEditDialog(TrailerAdminDto t) async {
    final result = await showDialog<_TrailerFormResult>(
      context: context,
      builder: (_) => _TrailerFormDialog(
        title: 'Sửa trailer',
        initialMovieId: t.movieId,
        initialYoutubeVideoId: t.youtubeVideoId,
        initialTitle: t.title,
        allowEditMovieId: false,
      ),
    );
    if (result == null) return;

    await _api.update(
      id: t.id,
      youtubeVideoId: result.youtubeVideoId,
      title: result.title,
    );

    if (!mounted) return;
    load();
  }

  Future<void> deleteTrailer(TrailerAdminDto t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Xoá trailer?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('${t.title} (#${t.id})', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await _api.delete(t.id);
    if (!mounted) return;
    load();
  }

  Widget _buildMovieIdField() {
    return TextField(
      controller: _movieIdCtl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Movie ID (để trống = tất cả)',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.movie, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      onSubmitted: (_) => load(),
    );
  }

  Widget _buildFilterButton() {
    return ElevatedButton.icon(
      onPressed: load,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black),
      icon: const Icon(Icons.search),
      label: const Text('Lọc'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Padding(
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
                        Expanded(child: _buildMovieIdField()),
                        const SizedBox(width: 12),
                        _buildFilterButton(),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: openCreateDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm'),
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(width: double.infinity, child: _buildMovieIdField()),
                        _buildFilterButton(),
                        ElevatedButton.icon(
                          onPressed: openCreateDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm'),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<TrailerAdminDto>>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snap.error}', style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
                  );
                }

                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('Không có trailer', style: TextStyle(color: AppColors.textSecondary)));
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final t = list[i];
                    return Card(
                      color: AppColors.backgroundCard,
                      child: ListTile(
                        title: Text('${t.title}  (#${t.id})', style: const TextStyle(color: AppColors.textPrimary)),
                        subtitle: Text('movieId: ${t.movieId} • ${t.youtubeVideoId}', style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            IconButton(
                              tooltip: 'Open',
                              icon: const Icon(Icons.open_in_new, color: AppColors.accent),
                              onPressed: t.youtubeVideoId.isEmpty ? null : () => openYoutube(t.youtubeVideoId),
                            ),
                            IconButton(
                              tooltip: 'Sửa',
                              icon: const Icon(Icons.edit, color: AppColors.warning),
                              onPressed: () => openEditDialog(t),
                            ),
                            IconButton(
                              tooltip: 'Xoá',
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => deleteTrailer(t),
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
    );
  }
}
