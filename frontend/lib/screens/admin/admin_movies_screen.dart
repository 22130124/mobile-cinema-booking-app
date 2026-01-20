import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_colors.dart';
import '../../model/movie_model.dart';
import '../../services/admin/admin_movie_api_service.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'admin_dashboard_screen.dart';
import 'admin_trailers_screen.dart';

// Màn hình quản lý danh sách phim cho Admin
class AdminMoviesScreen extends StatefulWidget {
  final bool embedded; // true = được embed trong màn hình khác, không cần Scaffold
  
  const AdminMoviesScreen({super.key, this.embedded = false});

  @override
  State<AdminMoviesScreen> createState() => _AdminMoviesScreenState();
}

class _AdminMoviesScreenState extends State<AdminMoviesScreen> {
  final _api = AdminMovieApiService();
  final _searchController = TextEditingController();
  
  List<Movie> _movies = [];
  List<Genre> _genres = [];
  bool _isLoading = true;
  String? _error;
  MovieStatus? _filterStatus;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getAllMovies(status: _filterStatus),
        _api.getAllGenres(),
      ]);

      if (!mounted) return;
      setState(() {
        _movies = results[0] as List<Movie>;
        _genres = results[1] as List<Genre>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _loadData();
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final movies = await _api.searchMovies(query);
        if (!mounted) return;
        setState(() {
          _movies = movies;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    });
  }

  void _onFilterChanged(MovieStatus? status) {
    setState(() {
      _filterStatus = status;
      _searchController.clear();
    });
    _loadData();
  }

  Future<void> _showMovieForm({Movie? movie}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MovieFormSheet(
        movie: movie,
        genres: _genres,
        api: _api,
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _showMovieDetail(Movie movie) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MovieDetailSheet(movie: movie),
    );
  }

  Future<void> _deleteMovie(Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xoá phim?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Bạn có chắc muốn xoá "${movie.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ', style: TextStyle(color: AppColors.textSecondary)),
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

    if (confirmed == true) {
      try {
        await _api.deleteMovie(movie.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá phim thành công')),
        );
        _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Search & Filter
        _buildSearchAndFilter(),
        
        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : _error != null
                  ? _buildError()
                  : _movies.isEmpty
                      ? _buildEmpty()
                      : _buildMovieList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nếu embedded trong màn hình khác (như AdminMainScreen), chỉ trả về content
    if (widget.embedded) {
      return _buildContent();
    }
    
    // Nếu là màn hình độc lập, wrap trong Scaffold
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AdminDrawer(
        currentRoute: 'movies',
        onMenuTap: (routeKey) {
          if (routeKey == 'movies') {
            Navigator.pop(context);
            return;
          }
          
          // Lấy ROOT navigator (của app, không phải của drawer)
          final navigator = Navigator.of(context, rootNavigator: true);
          
          // Đóng drawer trước
          Navigator.pop(context);
          
          // Navigate sau khi drawer đóng
          Future.delayed(const Duration(milliseconds: 200), () {
            Widget? screen;
            switch (routeKey) {
              case 'dashboard':
                screen = const AdminDashboardScreen();
                break;
              case 'trailers':
                screen = const AdminTrailersScreen();
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
          'Quản lý danh sách phim',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: () => _showMovieForm(),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên phim...',
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textHint),
                      onPressed: () {
                        _searchController.clear();
                        _loadData();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Tất cả'),
                const SizedBox(width: 8),
                _buildFilterChip(MovieStatus.nowShowing, '🟢 Đang chiếu'),
                const SizedBox(width: 8),
                _buildFilterChip(MovieStatus.comingSoon, '🟡 Sắp chiếu'),
                const SizedBox(width: 8),
                _buildFilterChip(MovieStatus.ended, '⚫ Ngừng chiếu'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(MovieStatus? status, String label) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(status),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accent.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.accent : AppColors.border,
      ),
      checkmarkColor: AppColors.accent,
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Đã xảy ra lỗi',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 64,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có phim nào',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showMovieForm(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm phim mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _movies.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddButton();
          }
          return _buildMovieCard(_movies[index - 1]);
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showMovieForm(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'Thêm phim mới',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Card(
      color: AppColors.backgroundCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMovieDetail(movie),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie.posterUrl,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 100,
                    color: AppColors.surface,
                    child: const Icon(Icons.movie, color: AppColors.textHint),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & ID
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${movie.id}',
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Duration, Rating, AgeRating
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.duration} phút',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating?.toStringAsFixed(1) ?? '-',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        if (movie.ageRating != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textHint),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              movie.ageRating!,
                              style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Release date & Status
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          movie.releaseDate,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusBadge(movie.status),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Genres
                    if (movie.genres != null && movie.genres!.isNotEmpty)
                      Text(
                        movie.genres!.join(', '),
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Action buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.warning, size: 20),
                    onPressed: () => _showMovieForm(movie: movie),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    onPressed: () => _deleteMovie(movie),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MovieStatus status) {
    Color bgColor;
    String label;

    switch (status) {
      case MovieStatus.nowShowing:
        bgColor = AppColors.success;
        label = 'Đang chiếu';
        break;
      case MovieStatus.special:
        bgColor = AppColors.primary;
        label = 'Đặc biệt';
        break;
      case MovieStatus.comingSoon:
        bgColor = AppColors.warning;
        label = 'Sắp chiếu';
        break;
      case MovieStatus.ended:
        bgColor = AppColors.textHint;
        label = 'Ngừng chiếu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bgColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Sheet hiển thị chi tiết phim
class _MovieDetailSheet extends StatelessWidget {
  final Movie movie;

  const _MovieDetailSheet({required this.movie});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header with poster
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      movie.posterUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 180,
                        color: AppColors.surface,
                        child: const Icon(Icons.movie, size: 48, color: AppColors.textHint),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.access_time, '${movie.duration} phút'),
                        _buildInfoRow(Icons.calendar_today, movie.releaseDate),
                        _buildInfoRow(Icons.star, movie.rating?.toStringAsFixed(1) ?? 'N/A'),
                        if (movie.ageRating != null)
                          _buildInfoRow(Icons.person, movie.ageRating!),
                        if (movie.director != null)
                          _buildInfoRow(Icons.movie_creation, movie.director!),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Genres
              if (movie.genres != null && movie.genres!.isNotEmpty) ...[
                const Text(
                  'Thể loại',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: movie.genres!.map((genre) => Chip(
                    label: Text(genre),
                    backgroundColor: AppColors.surface,
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Cast
              if (movie.cast != null) ...[
                const Text(
                  'Diễn viên',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.cast!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
              ],

              // Description
              if (movie.description != null) ...[
                const Text(
                  'Mô tả',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.description!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Sheet form thêm/sửa phim
class _MovieFormSheet extends StatefulWidget {
  final Movie? movie;
  final List<Genre> genres;
  final AdminMovieApiService api;

  const _MovieFormSheet({
    this.movie,
    required this.genres,
    required this.api,
  });

  @override
  State<_MovieFormSheet> createState() => _MovieFormSheetState();
}

class _MovieFormSheetState extends State<_MovieFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _releaseDateController;
  late TextEditingController _posterUrlController;
  late TextEditingController _backdropUrlController;
  late TextEditingController _ratingController;
  late TextEditingController _directorController;
  late TextEditingController _castController;
  
  String? _ageRating;
  MovieStatus _status = MovieStatus.comingSoon;
  bool _isSpecial = false;
  Set<int> _selectedGenreIds = {};
  bool _isSaving = false;

  final List<String> _ageRatings = ['P', 'T13', 'T16', 'T18', 'C'];

  @override
  void initState() {
    super.initState();
    final movie = widget.movie;
    
    _titleController = TextEditingController(text: movie?.title ?? '');
    _descriptionController = TextEditingController(text: movie?.description ?? '');
    _durationController = TextEditingController(text: movie?.duration.toString() ?? '');
    _releaseDateController = TextEditingController(text: movie?.releaseDate ?? '');
    _posterUrlController = TextEditingController(text: movie?.posterUrl ?? '');
    _backdropUrlController = TextEditingController(text: movie?.backdropUrl ?? '');
    _ratingController = TextEditingController(text: movie?.rating?.toString() ?? '');
    _directorController = TextEditingController(text: movie?.director ?? '');
    _castController = TextEditingController(text: movie?.cast ?? '');
    
    // Validate ageRating
    final movieAgeRating = movie?.ageRating;
    _ageRating = (movieAgeRating != null && _ageRatings.contains(movieAgeRating)) 
        ? movieAgeRating 
        : null;
    _status = movie?.status ?? MovieStatus.comingSoon;
    _isSpecial = movie?.isSpecial ?? false;
    
    // Load genre IDs từ movie hiện có khi edit
    if (movie?.genreIds != null && movie!.genreIds!.isNotEmpty) {
      _selectedGenreIds = movie.genreIds!.toSet();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _releaseDateController.dispose();
    _posterUrlController.dispose();
    _backdropUrlController.dispose();
    _ratingController.dispose();
    _directorController.dispose();
    _castController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      _releaseDateController.text = 
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = MovieRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        duration: int.parse(_durationController.text.trim()),
        releaseDate: _releaseDateController.text.trim(),
        posterUrl: _posterUrlController.text.trim(),
        backdropUrl: _backdropUrlController.text.trim().isEmpty 
            ? null 
            : _backdropUrlController.text.trim(),
        rating: _ratingController.text.trim().isEmpty 
            ? null 
            : double.parse(_ratingController.text.trim()),
        director: _directorController.text.trim().isEmpty 
            ? null 
            : _directorController.text.trim(),
        cast: _castController.text.trim().isEmpty 
            ? null 
            : _castController.text.trim(),
        ageRating: _ageRating,
        isSpecial: _isSpecial,
        status: _status.name.toUpperCase(),
        genreIds: _selectedGenreIds.toList(),
      );

      if (widget.movie != null) {
        await widget.api.updateMovie(widget.movie!.id, request);
      } else {
        await widget.api.createMovie(request);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.movie != null ? 'Đã cập nhật phim' : 'Đã thêm phim mới'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.movie != null ? 'Sửa phim' : 'Thêm phim mới',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Lưu'),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Tên phim *',
                      validator: (v) => v?.isEmpty == true ? 'Bắt buộc' : null,
                    ),
                    
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Mô tả',
                      maxLines: 3,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _durationController,
                            label: 'Thời lượng (phút) *',
                            keyboardType: TextInputType.number,
                            validator: (v) => v?.isEmpty == true ? 'Bắt buộc' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _ratingController,
                            label: 'Đánh giá (0-10)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    // Release date
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _releaseDateController,
                          label: 'Ngày khởi chiếu *',
                          suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textHint),
                          validator: (v) => v?.isEmpty == true ? 'Bắt buộc' : null,
                        ),
                      ),
                    ),

                    _buildTextField(
                      controller: _posterUrlController,
                      label: 'URL Poster *',
                      validator: (v) => v?.isEmpty == true ? 'Bắt buộc' : null,
                    ),

                    _buildTextField(
                      controller: _backdropUrlController,
                      label: 'URL Backdrop',
                    ),

                    _buildTextField(
                      controller: _directorController,
                      label: 'Đạo diễn',
                    ),

                    _buildTextField(
                      controller: _castController,
                      label: 'Diễn viên',
                    ),

                    // Age Rating dropdown
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _ageRating,
                      decoration: _inputDecoration('Độ tuổi'),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: _ageRatings.map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r),
                      )).toList(),
                      onChanged: (v) => setState(() => _ageRating = v),
                    ),

                    // Status
                    const SizedBox(height: 16),
                    const Text(
                      'Trạng thái',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: MovieStatus.values.map((s) => ChoiceChip(
                        label: Text(_statusLabel(s)),
                        selected: _status == s,
                        onSelected: (_) => setState(() => _status = s),
                        selectedColor: AppColors.accent.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _status == s ? AppColors.accent : AppColors.textSecondary,
                        ),
                      )).toList(),
                    ),

                    // Genres
                    const SizedBox(height: 16),
                    const Text(
                      'Thể loại',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.genres.map((g) => FilterChip(
                        label: Text(g.name),
                        selected: _selectedGenreIds.contains(g.id),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGenreIds.add(g.id);
                            } else {
                              _selectedGenreIds.remove(g.id);
                            }
                          });
                        },
                        selectedColor: AppColors.accent.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedGenreIds.contains(g.id) 
                              ? AppColors.accent 
                              : AppColors.textSecondary,
                        ),
                        checkmarkColor: AppColors.accent,
                      )).toList(),
                    ),

                    // Is Special
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text(
                        'Phim đặc biệt',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        'Hiển thị badge Special trên poster',
                        style: TextStyle(color: AppColors.textHint, fontSize: 12),
                      ),
                      value: _isSpecial,
                      onChanged: (v) => setState(() => _isSpecial = v),
                      activeColor: AppColors.accent,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(MovieStatus status) {
    switch (status) {
      case MovieStatus.nowShowing:
        return 'Đang chiếu';
      case MovieStatus.special:
        return 'Đặc biệt';
      case MovieStatus.comingSoon:
        return 'Sắp chiếu';
      case MovieStatus.ended:
        return 'Ngừng chiếu';
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: _inputDecoration(label).copyWith(suffixIcon: suffixIcon),
      ),
    );
  }
}
