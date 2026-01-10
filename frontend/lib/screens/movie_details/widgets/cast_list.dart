import 'package:flutter/material.dart';

class ActorVm {
  final String name;
  final String role;
  final String? imageUrl;

  const ActorVm({
    required this.name,
    required this.role,
    this.imageUrl,
  });
}

class CastList extends StatelessWidget {
  final List<ActorVm> actors;
  const CastList({super.key, required this.actors});

  @override
  Widget build(BuildContext context) {
    if (actors.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: actors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final actor = actors[index];

          final name = actor.name.trim();
          final role = actor.role.trim();
          final imageUrl = (actor.imageUrl ?? '').trim();

          final fallbackUrl = name.isEmpty
              ? ''
              : 'https://ui-avatars.com/api/?background=222222&color=ffffff&name=${Uri.encodeComponent(name)}';

          final displayUrl = imageUrl.isNotEmpty ? imageUrl : fallbackUrl;

          return Column(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey.shade800,
                child: ClipOval(
                  child: displayUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white70)
                      : Image.network(
                          displayUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, color: Colors.white70),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 70,
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  role,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
