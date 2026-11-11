import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../model/must_eat_place.dart';

/// 선택한 맛집의 지도와 상세 정보를 ModalBottomSheet 안에 표시한다.
class PlaceDetailSheet extends StatelessWidget {
  const PlaceDetailSheet({super.key, required this.place, this.distanceLabel});

  final MustEatPlace place;
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) {
    final location = LatLng(place.lat, place.lng);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD8CCC5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: '닫기',
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              key: const Key('detail_scroll'),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    key: const Key('detail_map'),
                    height: 260,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: location,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.example.must_eat_place_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: location,
                              width: 56,
                              height: 56,
                              child: Icon(
                                Icons.location_pin,
                                color: Theme.of(context).colorScheme.primary,
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                        const RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution('OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (place.isFavorite)
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF4A825),
                        size: 30,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: const Icon(Icons.local_dining_outlined, size: 18),
                    label: Text(place.category),
                    side: BorderSide.none,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                _RatingSummary(rating: place.rating),
                ListTile(
                  key: const Key('detail_address'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('주소'),
                  subtitle: Text(
                    place.address.trim().isEmpty
                        ? '등록된 주소가 없습니다.'
                        : place.address,
                  ),
                ),
                if (distanceLabel != null)
                  ListTile(
                    key: const Key('detail_distance'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.near_me_outlined),
                    title: const Text('현재 위치에서'),
                    subtitle: Text(distanceLabel!),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('전화번호'),
                  subtitle: Text(place.phone),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 200,
                    child: place.image == null
                        ? Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            alignment: Alignment.center,
                            child: const Icon(Icons.restaurant, size: 64),
                          )
                        : Image.memory(
                            place.image!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                _DetailSection(
                  icon: Icons.restaurant_menu,
                  title: '메뉴',
                  content: place.menu.trim().isEmpty
                      ? '등록된 메뉴가 없습니다.'
                      : place.menu,
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  icon: Icons.rate_review_outlined,
                  title: '평가',
                  content: place.estimate.trim().isEmpty
                      ? '등록된 평가가 없습니다.'
                      : place.estimate,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('등록일'),
                  subtitle: Text(_formatDate(place.initDate)),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('call_place_button'),
                      // 외부 전화 앱을 연결할 때 실제 동작으로 교체합니다.
                      onPressed: () {},
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('전화 걸기'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('directions_button'),
                      // 외부 지도 앱을 연결할 때 실제 동작으로 교체합니다.
                      onPressed: () {},
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text('길찾기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }
}

/// 상세 화면에서 저장된 별점과 5개의 별 상태를 함께 보여준다.
class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ...List.generate(5, (index) {
              final starValue = index + 1;
              final IconData icon;
              if (rating >= starValue) {
                icon = Icons.star_rounded;
              } else if (rating >= starValue - 0.5) {
                icon = Icons.star_half_rounded;
              } else {
                icon = Icons.star_outline_rounded;
              }
              return Icon(icon, color: const Color(0xFFF4A825), size: 24);
            }),
            const Spacer(),
            Text(
              rating == 0 ? '별점 없음' : rating.toStringAsFixed(1),
              key: const Key('detail_rating'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

/// 메뉴와 평가처럼 여러 줄이 가능한 상세 정보를 카드로 표시한다.
class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 21,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
