import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../theme/app_theme.dart';

class TutorialsScreen extends StatefulWidget {
  final bool isPortuguese;
  const TutorialsScreen({super.key, required this.isPortuguese});

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  int _activeLesson = 0;

  final List<Map<String, String>> _lessons = [
    {
      'module': 'MÓDULO 01 • PREPARAÇÃO',
      'title': 'Ordem Correta do Skincare Diurno',
      'desc': 'Entenda a densidade molecular: da textura mais fluida à mais densa para absorção máxima.',
      'duration': '03:45 min',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    },
    {
      'module': 'MÓDULO 02 • GLOWFRIDGE IoT',
      'title': 'Conservação Térmica de Ativos',
      'desc': 'Como manter séruns entre 4°C e 8°C evita oxidação da Vitamina C.',
      'duration': '04:12 min',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initPlayer(_lessons[0]['url']!);
  }

  Future<void> _initPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController.initialize();
    _chewieController?.dispose();
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _lessons[_activeLesson];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text('Área de Aulas', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: const Color(0xFF0F172A),
            child: _chewieController != null && _videoController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        ),
        const SizedBox(height: 14),
        Text(current['title']!, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(current['desc']!, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
