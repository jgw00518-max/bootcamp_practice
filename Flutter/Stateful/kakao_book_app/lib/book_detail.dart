import 'package:flutter/material.dart';
import 'package:kakao_book_app/favorite_repository.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({
    super.key,
    required this.book,
    this.repository = const FavoriteRepository(),
  });

  /// The selected Kakao book document whose full information is displayed.
  final Map<String, dynamic> book;
  final FavoriteRepository repository;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  /// Loads the locally stored favorite state for the selected book.
  Future<void> _loadFavorite() async {
    final isFavorite = await widget.repository.isFavorite(widget.book);
    if (mounted) setState(() => _isFavorite = isFavorite);
  }

  /// Saves or removes the selected book from local favorites.
  Future<void> _toggleFavorite() async {
    final isFavorite = await widget.repository.toggle(widget.book);
    if (mounted) setState(() => _isFavorite = isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final thumbnail = widget.book['thumbnail'] as String? ?? '';
    final dateTime = widget.book['datetime'] as String? ?? '';
    final publishedDate = dateTime.length >= 10
        ? dateTime.substring(0, 10)
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('\u{CC45} \u{C0C1}\u{C138}'),
        actions: [
          IconButton(
            key: const Key('favoriteToggleButton'),
            onPressed: _toggleFavorite,
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 180,
                height: 260,
                child: thumbnail.isEmpty
                    ? const ColoredBox(color: Color(0xffe9e0ee))
                    : Image.network(
                        thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: Color(0xffe9e0ee)),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.book['title'] as String? ??
                  '\u{C81C}\u{BAA9} \u{C5C6}\u{C74C}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: '\u{CD9C}\u{D310}\u{C0AC}',
              value: widget.book['publisher'] as String? ?? '-',
            ),
            _DetailRow(label: '\u{CD9C}\u{AC04}\u{C77C}', value: publishedDate),
            _DetailRow(
              label: 'ISBN',
              value: widget.book['isbn'] as String? ?? '-',
            ),
            const SizedBox(height: 16),
            Text(
              '\u{C18C}\u{AC1C}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(widget.book['contents'] as String? ?? '-'),
            const SizedBox(height: 24),
            Text(
              '\u{AD6C}\u{B9E4} \u{B9C1}\u{D06C}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(widget.book['url'] as String? ?? '-'),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
