import 'package:flutter/material.dart';
import 'dart:async';

import '../../config/app_colors.dart';
import '../../model/movie_model.dart';
import '../../services/movie_service.dart';

import '../../widgets/home/movie_banner.dart';
import '../../widgets/home/movie_card.dart';

import 'search_screen.dart';
import 'all_movies_screen.dart';

// TODO: sửa đường dẫn import này theo project của bạn
import '../movie_details/movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(viewportFraction: 0.75);
  int currentBannerIndex = 0;
  Timer? autoPlayTimer;

  // State
  List<Movie> allMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> nowShowingMovies = [];

  MovieStatus selectedTab = MovieStatus.nowShowing;
  bool isLoading = true;
  String? errorMessage;
  MovieErrorType? errorType;

  @override
  void initState() {
    super.initState();
    loadMoviesFromAPI();
    startAutoPlay();
  }

  @override
  void dispose() {
    autoPlayTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  // NEW: mở chi tiết phim
  void openMovieDetail(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movieId: movie.id.toString()),
      ),
    );
  }

  // Load dữ liệu từ API
  Future<void> loadMoviesFromAPI() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      errorType = null;
    });

    try {
      final results = await Future.wait([
        MovieService.getAllMovies(),
        MovieService.getPopularMovies(),
        MovieService.getNowShowingMovies(),
      ]);

      if (!mounted) return;

      setState(() {
        allMovies = results[0];
        popularMovies = results[1];
        nowShowingMovies = results[2];
        isLoading = false;
      });
    } on MovieServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.message;
        errorType = e.type;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Xảy ra lỗi không xác định!';
        errorType = MovieErrorType.unknown;
      });
    }
  }

  // Getter filter phim theo tab
  List<Movie> get filteredMovies {
    switch (selectedTab) {
      case MovieStatus.nowShowing:
        return allMovies.where((m) => m.status == MovieStatus.nowShowing).toList();
      case MovieStatus.special:
        return allMovies.where((m) => m.status == MovieStatus.special).toList();
      case MovieStatus.comingSoon:
        return allMovies.where((m) => m.status == MovieStatus.comingSoon).toList();
    }
  }

  void startAutoPlay() {
    autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (pageController.hasClients && mounted) {
        final movies = filteredMovies;
        if (movies.isNotEmpty) {
          final nextPage = (currentBannerIndex + 1) % movies.length;
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  Widget buildErrorIcon() {
    IconData iconData;
    Color iconColor;

    switch (errorType) {
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
        break;
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

  String getErrorTitle() {
    switch (errorType) {
      case MovieErrorType.timeout:
        return 'Kết nối quá chậm';
      case MovieErrorType.noInternet:
        return 'Không có kết nối mạng';
      case MovieErrorType.serverError:
        return 'Lỗi máy chủ';
      default:
        return 'Xảy ra lỗi';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
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

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildErrorIcon(),
                const SizedBox(height: 24),
                Text(
                  getErrorTitle(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: loadMoviesFromAPI,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text(
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

    final displayMovies = filteredMovies;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadMoviesFromAPI,
          color: AppColors.accent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSearchBar(context),
                buildTabBar(),
                const SizedBox(height: 20),

                if (displayMovies.isNotEmpty) ...[
                  buildBannerCarousel(displayMovies),
                  buildDotsIndicator(displayMovies.length),
                  buildMovieInfo(displayMovies),
                ] else ...[
                  buildEmptyState(),
                ],

                buildSection(
                  context,
                  'Phổ Biến',
                  popularMovies,
                  Icons.local_fire_department,
                  AppColors.warning,
                ),
                buildSection(
                  context,
                  'Đang Chiếu',
                  nowShowingMovies,
                  Icons.play_circle_filled,
                  AppColors.chipNowShowing,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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

  Widget buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SearchScreen(movies: allMovies)),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.searchBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.searchIcon, size: 22),
              SizedBox(width: 12),
              Text(
                'Tìm kiếm phim...',
                style: TextStyle(color: AppColors.textHint, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          buildTab('Đang chiếu', MovieStatus.nowShowing),
          buildTab('Đặc biệt', MovieStatus.special),
          buildTab('Sắp chiếu', MovieStatus.comingSoon),
        ],
      ),
    );
  }

  Widget buildTab(String title, MovieStatus status) {
    final isSelected = selectedTab == status;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = status;
            currentBannerIndex = 0;
            if (pageController.hasClients) pageController.jumpToPage(0);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget buildBannerCarousel(List<Movie> movies) {
    return SizedBox(
      height: 380,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (index) => setState(() => currentBannerIndex = index),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double value = 1.0;
              if (pageController.position.haveDimensions) {
                value = (pageController.page! - index);
                value = (1 - value.abs() * 0.15).clamp(0.0, 1.0);
              }

              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * 380,
                  width: Curves.easeOut.transform(value) * 300,
                  child: child,
                ),
              );
            },
            child: MovieBanner(
              movie: movies[index],
              onTap: () => openMovieDetail(context, movies[index]),
            ),

          );
        },
      ),
    );
  }

  Widget buildDotsIndicator(int count) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: currentBannerIndex == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: currentBannerIndex == index ? AppColors.accent : AppColors.surface,
            ),
          );
        }),
      ),
    );
  }

  Widget buildMovieInfo(List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();

    final safeIndex = currentBannerIndex.clamp(0, movies.length - 1);
    final currentMovie = movies[safeIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            currentMovie.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            currentMovie.genre,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildInfoChip(Icons.star, currentMovie.rating.toString(), AppColors.accent),
              const SizedBox(width: 16),
              buildInfoChip(Icons.access_time, '${currentMovie.duration} phút', AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget buildSection(
    BuildContext context,
    String title,
    List<Movie> movies,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllMoviesScreen(
                        title: title,
                        movies: movies,
                        icon: icon,
                        iconColor: color,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),

        // NEW: ClipRect để shadow của card không vẽ “đè” lên header, giúp nút "Xem tất cả" bấm ổn định
        ClipRect(
          child: SizedBox(
            height: 210,
            child: movies.isEmpty
                ? const Center(
                    child: Text('Không có phim', style: TextStyle(color: AppColors.textHint)),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: MovieCard(
                          movie: movie,
                          onTap: () => openMovieDetail(context, movie), // NEW
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
