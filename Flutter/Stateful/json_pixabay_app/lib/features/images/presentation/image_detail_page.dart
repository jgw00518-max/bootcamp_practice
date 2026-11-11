import 'package:flutter/material.dart';
import 'package:json_pixabay_app/features/images/data/image_action_service.dart';
import 'package:json_pixabay_app/features/images/data/local_image_repository.dart';
import 'package:json_pixabay_app/features/images/domain/pixabay_image.dart';
import 'package:photo_view/photo_view.dart';

/// 확대 가능한 원본 이미지와 작성자·통계·기기 동작을 제공한다.
class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({
    super.key,
    required this.image,
    this.actionService,
    this.localRepository,
  });
  final PixabayImage image;
  final ImageActionService? actionService;
  final LocalImageRepository? localRepository;
  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  late final ImageActionService _actionService;
  late final LocalImageRepository _localRepository;
  bool _isSaving = false;
  bool _isFavorite = false;
  @override
  void initState() {
    super.initState();
    _actionService = widget.actionService ?? ImageActionService();
    _localRepository = widget.localRepository ?? LocalImageRepository();
    _loadFavoriteState();
  }

  /// 화면 진입 시 저장된 즐겨찾기 상태를 아이콘에 반영한다.
  Future<void> _loadFavoriteState() async {
    final isFavorite = await _localRepository.isFavorite(widget.image.id);
    if (mounted) setState(() => _isFavorite = isFavorite);
  }

  /// 이미지를 즐겨찾기에 추가하거나 해제한다.
  Future<void> _toggleFavorite() async {
    final isFavorite = await _localRepository.toggleFavorite(widget.image);
    if (!mounted) return;
    setState(() => _isFavorite = isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Added to favorites.' : 'Removed from favorites.',
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    setState(() => _isSaving = true);
    try {
      await _actionService.saveToGallery(widget.image);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진 갤러리에 저장했습니다.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지 저장에 실패했습니다.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.image.tags),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          tooltip: 'Favorite',
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: '공유',
          onPressed: () => _actionService.shareUrl(widget.image),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: PhotoView(
            imageProvider: NetworkImage(widget.image.largeImageUrl),
            enableRotation: true,
            loadingBuilder: (context, event) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Text('이미지를 표시할 수 없습니다.')),
          ),
        ),
        _ImageInfo(image: widget.image),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveImage,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              label: Text(_isSaving ? '저장 중...' : '갤러리에 저장'),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Pixabay가 제공하는 작성자와 인기도 통계를 상세 화면 하단에 표시한다.
class _ImageInfo extends StatelessWidget {
  const _ImageInfo({required this.image});
  final PixabayImage image;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(image.userName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(
              icon: Icons.favorite_border,
              label: '좋아요',
              value: image.likes,
            ),
            _Stat(
              icon: Icons.visibility_outlined,
              label: '조회',
              value: image.views,
            ),
            _Stat(
              icon: Icons.download_outlined,
              label: '다운로드',
              value: image.downloads,
            ),
          ],
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon),
      Text('$value'),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}
