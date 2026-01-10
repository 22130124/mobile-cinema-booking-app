import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerDialog extends StatefulWidget {
  final String videoId;
  const TrailerDialog({super.key, required this.videoId});

  @override
  State<TrailerDialog> createState() => _TrailerDialogState();
}

class _TrailerDialogState extends State<TrailerDialog> {
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();

    // Web: mở ngoài bằng browser/app YouTube cho ổn định.
    // Mobile (Android/iOS): phát inline bằng youtube_player_flutter.
    if (!kIsWeb) {
      _ytController = YoutubePlayerController(
        initialVideoId: widget.videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watchUrl = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');

    if (kIsWeb) {
      return AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Trailer', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Trên web, trailer sẽ được mở ở tab mới để ổn định hơn.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await launchUrl(watchUrl, mode: LaunchMode.externalApplication);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Mở trailer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      );
    }

    final controller = _ytController;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.deepOrange,
              onReady: () {},
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
