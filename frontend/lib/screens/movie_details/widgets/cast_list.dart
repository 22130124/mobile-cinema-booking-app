import 'package:flutter/material.dart';
import 'package:frontend/config/app_colors.dart';
import 'package:frontend/model/movie_details.dart';

class CastList extends StatelessWidget {
  final List<ActorModel> actors;
  const CastList({super.key, required this.actors});

  @override
  Widget build(BuildContext context) {
    if (actors.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.surface,
                  backgroundImage: (actor.imageURL != null &&
                          actor.imageURL!.isNotEmpty)
                      ? NetworkImage(actor.imageURL!)
                      : null,
                  child: (actor.imageURL == null || actor.imageURL!.isEmpty)
                      ? const Icon(Icons.person, color: AppColors.textPrimary)
                      : null,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    actor.name ?? '',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    actor.role ?? '',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
