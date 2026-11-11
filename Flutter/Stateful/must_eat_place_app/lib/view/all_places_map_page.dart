import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../model/must_eat_place.dart';
import '../vm/must_eat_place_view_model.dart';
import 'place_detail_sheet.dart';

/// 저장된 모든 맛집과 현재 위치를 한 지도에서 보여준다.
class AllPlacesMapPage extends StatefulWidget {
  const AllPlacesMapPage({
    super.key,
    required this.viewModel,
    this.embedded = false,
  });

  final MustEatPlaceViewModel viewModel;
  final bool embedded;

  @override
  State<AllPlacesMapPage> createState() => _AllPlacesMapPageState();
}

class _AllPlacesMapPageState extends State<AllPlacesMapPage> {
  static const LatLng _seoulCityHall = LatLng(37.5665, 126.9780);

  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  MustEatPlace? _selectedPlace;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    final cachedLocation = widget.viewModel.currentLocation;
    if (cachedLocation != null) {
      _currentLocation = LatLng(
        cachedLocation.latitude,
        cachedLocation.longitude,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitAllPlaces();
      _findCurrentLocation(showError: false);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// 모든 맛집 마커가 화면 안에 들어오도록 지도 범위를 조절한다.
  void _fitAllPlaces() {
    final points = widget.viewModel.places
        .map((place) => LatLng(place.lat, place.lng))
        .toList();
    if (points.isEmpty) {
      _mapController.move(_currentLocation ?? _seoulCityHall, 12);
    } else if (points.length == 1) {
      _mapController.move(points.first, 15);
    } else {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(48),
        ),
      );
    }
  }

  /// 현재 위치를 파란 마커로 표시하고 요청 시 지도 중심도 이동한다.
  Future<void> _findCurrentLocation({required bool showError}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final location = await widget.viewModel.findCurrentLocation();
      if (!mounted) return;
      final point = LatLng(location.latitude, location.longitude);
      setState(() {
        _currentLocation = point;
        _locating = false;
      });
      if (showError) _mapController.move(point, 16);
    } catch (error) {
      if (!mounted) return;
      setState(() => _locating = false);
      if (showError) {
        final message = error
            .toString()
            .replaceFirst('Bad state: ', '')
            .replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  /// 선택한 마커의 기존 상세 화면을 ModalBottomSheet로 재사용한다.
  Future<void> _showPlaceDetail(MustEatPlace place) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (context) => FractionallySizedBox(
        key: const Key('map_place_detail_sheet'),
        heightFactor: 0.92,
        child: PlaceDetailSheet(
          place: place,
          distanceLabel: widget.viewModel.distanceLabel(place),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = widget.viewModel.places;
    final initialCenter = places.isEmpty
        ? _currentLocation ?? _seoulCityHall
        : LatLng(places.first.lat, places.first.lng);

    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: const Text('전체 맛집 지도')),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              key: const Key('all_places_map'),
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.must_eat_place_app',
                ),
                MarkerLayer(markers: _buildMarkers(context)),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 14),
                  ],
                ),
                child: Text(
                  '저장한 맛집 ${places.length}곳',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: _selectedPlace == null ? 20 : 154,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  IconButton.filledTonal(
                    key: const Key('fit_all_places_button'),
                    onPressed: _fitAllPlaces,
                    tooltip: '전체 맛집 보기',
                    icon: const Icon(Icons.center_focus_strong_rounded),
                  ),
                  const SizedBox(height: 10),
                  IconButton.filled(
                    key: const Key('map_current_location_button'),
                    onPressed: _locating
                        ? null
                        : () => _findCurrentLocation(showError: true),
                    tooltip: '내 위치로 이동',
                    icon: _locating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedPlace case final place?)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: _PlaceMarkerPreview(
                  place: place,
                  distanceLabel: widget.viewModel.distanceLabel(place),
                  onTap: () => _showPlaceDetail(place),
                  onClose: () => setState(() => _selectedPlace = null),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 카테고리별 맛집 핀과 파란색 현재 위치 마커를 생성한다.
  List<Marker> _buildMarkers(BuildContext context) {
    return [
      ...widget.viewModel.places.map(
        (place) => Marker(
          key: Key('place_marker_${place.seq}'),
          point: LatLng(place.lat, place.lng),
          width: 52,
          height: 52,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlace = place),
            child: Icon(
              Icons.location_pin,
              color: _selectedPlace?.seq == place.seq
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.primary,
              size: 46,
            ),
          ),
        ),
      ),
      if (_currentLocation != null)
        Marker(
          key: const Key('all_map_current_location_marker'),
          point: _currentLocation!,
          width: 42,
          height: 42,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 17,
              height: 17,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 3)],
              ),
            ),
          ),
        ),
    ];
  }
}

/// 선택한 지도 마커의 핵심 정보를 상세 화면보다 먼저 간단히 보여줍니다.
class _PlaceMarkerPreview extends StatelessWidget {
  const _PlaceMarkerPreview({
    required this.place,
    required this.distanceLabel,
    required this.onTap,
    required this.onClose,
  });

  final MustEatPlace place;
  final String? distanceLabel;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('map_marker_preview'),
      margin: EdgeInsets.zero,
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('map_marker_preview_detail'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _PreviewInfo(
                          icon: Icons.restaurant_menu_rounded,
                          label: place.category,
                        ),
                        _PreviewInfo(
                          icon: Icons.star_rounded,
                          label: place.rating == 0
                              ? '별점 미등록'
                              : place.rating.toStringAsFixed(1),
                          iconColor: const Color(0xFFF4A825),
                        ),
                        _PreviewInfo(
                          icon: Icons.near_me_outlined,
                          label: distanceLabel ?? '거리 정보 없음',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('close_map_marker_preview'),
                onPressed: onClose,
                tooltip: '미리보기 닫기',
                icon: const Icon(Icons.close_rounded),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewInfo extends StatelessWidget {
  const _PreviewInfo({required this.icon, required this.label, this.iconColor});

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
