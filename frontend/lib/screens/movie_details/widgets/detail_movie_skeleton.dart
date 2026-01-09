import 'package:flutter/material.dart';
import 'package:frontend/config/app_colors.dart';

class DetailMovieSkeleton extends StatelessWidget {
  const DetailMovieSkeleton({super.key});

  Widget _buildSkeletonLine({double width = double.infinity, double height = 16}) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSkeletonCircle({double size = 50}) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Poster skeleton
            Container(
              width: double.infinity,
              height: 400,
              color: AppColors.backgroundCard,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  _buildSkeletonLine(width: 200, height: 24),
                  _buildSkeletonLine(width: 150, height: 16),
                  const SizedBox(height: 16),
                  // Description skeleton
                  _buildSkeletonLine(),
                  _buildSkeletonLine(),
                  _buildSkeletonLine(width: MediaQuery.of(context).size.width * 0.7),
                  const SizedBox(height: 24),
                  // Cast skeleton
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            _buildSkeletonCircle(size: 50),
                            const SizedBox(height: 8),
                            _buildSkeletonLine(width: 50, height: 12),
                            _buildSkeletonLine(width: 40, height: 10),
                          ],
                        );
                      },
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
