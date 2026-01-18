import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_colors.dart';
import '../../model/movie_model.dart';
import '../../services/movie_service.dart';
import '../../widgets/home/movie_banner.dart';
import '../../widgets/home/movie_card.dart';
import 'search_screen.dart';
import 'all_movies_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController = PageController(viewportFraction: 0.75);
  int _currentBannerIndex = 0;
  Timer? _autoPlayTimer;

  // State
  List<Movie> _allMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _nowShowingMovies = [];
  MovieStatus _selectedTab = MovieStatus.nowShowing;
  bool _isLoading = true;
  String? _errorMessage;
  MovieErrorType? _errorType;

  @override
  void initState() {
    super.initState();
    _loadMoviesFromAPI();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Load dữ liệu từ API
  Future<void> _loadMoviesFromAPI() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorType = null;
    });

    try {
      // Gọi song song các API để tối ưu tốc độ
      final results = await Future.wait([
        MovieService.getAllMovies(),
        MovieService.getPopularMovies(),
        MovieService.getNowShowingMovies(),
      ]);

      if (!mounted) return;
      
      setState(() {
        _allMovies = results[0];
        _popularMovies = results[1];
        _nowShowingMovies = results[2];
        _isLoading = false;
      });
    } on MovieServiceException catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _errorType = e.type;
      });
      print('MovieServiceException: $e');
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã xảy ra lỗi không xác định!';
        _errorType = MovieErrorType.unknown;
      });
      print('Error loading movies: $e');
    }
  }

  // Getter để filter phim theo tab
  List<Movie> get _filteredMovies {
    switch (_selectedTab) {
      case MovieStatus.nowShowing:
        return _allMovies.where((m) => m.status == MovieStatus.nowShowing).toList();
      case MovieStatus.special:
        return _allMovies.where((m) => m.status == MovieStatus.special).toList();
      case MovieStatus.comingSoon:
        return _allMovies.where((m) => m.status == MovieStatus.comingSoon).toList();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && mounted) {
        final movies = _filteredMovies;
        if (movies.isNotEmpty) {
          final nextPage = (_currentBannerIndex + 1) % movies.length;
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  /// Lấy icon phù hợp với loại lỗi
  Widget _buildErrorIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (_errorType) {
      case MovieErrorType.timeout:
        iconData = Icons.timer_off_outlined;
        iconColor = AppColors.warning;
        break;
      case MovieErrorType.noInternet:
        iconData = Icons.wifi_off_rounded;
        iconColor = AppColors.error;
        break;
      case MovieErrorType.serverError:
        iconData = Icons.cloud_off_rounded;
        iconColor = AppColors.error;
        break;
      default:
        iconData = Icons.error_outline_rounded;
        iconColor = AppColors.error;
    }
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 50, color: iconColor),
    );
  }

  /// Lấy tiêu đề theo loại lỗi
  String _getErrorTitle() {
    switch (_errorType) {
      case MovieErrorType.timeout:
        return 'Kết nối quá chậm';
      case MovieErrorType.noInternet:
        return 'Không có kết nối mạng';
      case MovieErrorType.serverError:
        return 'Lỗi máy chủ';
      default:
        return 'Đã xảy ra lỗi';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text(
                'Đang tải dữ liệu...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon theo loại lỗi
                _buildErrorIcon(),
                SizedBox(height: 24),
                
                // Tiêu đề lỗi
                Text(
                  _getErrorTitle(),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                
                // Mô tả lỗi
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                
                // Nút thử lại
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _loadMoviesFromAPI,
                    icon: Icon(Icons.refresh, size: 20),
                    label: Text(
                      'Thử lại',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final displayMovies = _filteredMovies;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMoviesFromAPI,
          color: AppColors.accent,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                _buildSearchBar(context),

                // Tab Bar
                _buildTabBar(),

                SizedBox(height: 20),

                // Banner Carousel
                if (displayMovies.isNotEmpty) ...[
                  _buildBannerCarousel(displayMovies),

                  // Dots Indicator
                  _buildDotsIndicator(displayMovies.length),

                  // Movie Info
                  _buildMovieInfo(displayMovies),
                ] else ...[
                  _buildEmptyState(),
                ],

                // Popular Section
                _buildSection(
                  context,
                  'Phổ Biến',
                  _popularMovies,
                  Icons.local_fire_department,
                  AppColors.warning,
                ),

                // Now Showing Section
                _buildSection(
                  context,
                  'Đang Chiếu',
                  _nowShowingMovies,
                  Icons.play_circle_filled,
                  AppColors.chipNowShowing,
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter, size: 60, color: AppColors.surface),
            SizedBox(height: 16),
            Text(
              'Không có phim nào',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(movies: _allMovies),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.searchBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.searchIcon, size: 22),
              SizedBox(width: 12),
              Text(
                'Tìm kiếm phim...',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab('Đang chiếu', MovieStatus.nowShowing),
          _buildTab('Đặc biệt', MovieStatus.special),
          _buildTab('Sắp chiếu', MovieStatus.comingSoon),
        ],
      ),
    );
  }

  Widget _buildTab(String title, MovieStatus status) {
    bool isSelected = _selectedTab == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = status;
            _currentBannerIndex = 0;
          });
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tabSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(List<Movie> movies) {
    return Container(
      height: 380,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentBannerIndex = index;
          });
        },
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
              }
              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 380,
                  width: Curves.easeOut.transform(value) * 300,
                  child: child,
                ),
              );
            },
            child: MovieBanner(movie: movies[index]),
          );
        },
      ),
    );
  }

  Widget _buildDotsIndicator(int count) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _currentBannerIndex == index ? 24 : 8,
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentBannerIndex == index
                  ? AppColors.accent
                  : AppColors.surface,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMovieInfo(List<Movie> movies) {
    if (movies.isEmpty) return SizedBox();

    final safeIndex = _currentBannerIndex.clamp(0, movies.length - 1);
    final currentMovie = movies[safeIndex];
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            currentMovie.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: 8),
          Text(
            currentMovie.genre,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                Icons.star,
                currentMovie.rating.toString(),
                AppColors.accent,
              ),
              SizedBox(width: 16),
              _buildInfoChip(
                Icons.access_time,
                '${currentMovie.duration} phút',
                AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Movie> movies, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllMoviesScreen(
                        title: title,
                        movies: movies,
                        icon: icon,
                        iconColor: color,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: movies.isEmpty
              ? Center(
                  child: Text(
                    'Không có phim',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: MovieCard(movie: movies[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
