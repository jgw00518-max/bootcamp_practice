import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../vm/must_eat_place_view_model.dart';

/// 위치 선택 결과로 전달되는 좌표와 주소입니다.
class SelectedPlaceLocation {
  const SelectedPlaceLocation({required this.point, required this.address});

  final LatLng point;
  final String address;
}

/// 주소 검색 또는 지도 터치로 맛집의 위치를 선택하는 화면입니다.
class PlaceLocationPickerPage extends StatefulWidget {
  const PlaceLocationPickerPage({
    super.key,
    required this.viewModel,
    this.initialLocation,
    this.initialAddress = '',
  });

  final MustEatPlaceViewModel viewModel;
  final LatLng? initialLocation;
  final String initialAddress;

  @override
  State<PlaceLocationPickerPage> createState() =>
      _PlaceLocationPickerPageState();
}

class _PlaceLocationPickerPageState extends State<PlaceLocationPickerPage> {
  static const LatLng _seoulCityHall = LatLng(37.5665, 126.9780);
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();
  late LatLng? _selectedLocation;
  LatLng? _currentLocation;
  late String _selectedAddress;
  bool _locating = true;
  bool _resolvingAddress = false;
  String? _addressError;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedAddress = widget.initialAddress;
    _addressController.text = widget.initialAddress;
    final cached = widget.viewModel.currentLocation;
    if (cached != null) {
      _currentLocation = LatLng(cached.latitude, cached.longitude);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToCurrentLocation(
        showError: true,
        refresh: cached == null,
        moveMap: widget.initialLocation == null,
      );
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// 현재 위치 마커를 갱신하며, 추가 화면 또는 버튼 요청일 때만 지도를 이동합니다.
  Future<void> _moveToCurrentLocation({
    required bool showError,
    bool refresh = true,
    bool moveMap = true,
  }) async {
    if (mounted) setState(() => _locating = true);
    try {
      final location = await widget.viewModel.findCurrentLocation(
        refresh: refresh,
      );
      if (!mounted) return;
      final point = LatLng(location.latitude, location.longitude);
      setState(() {
        _currentLocation = point;
        _locating = false;
      });
      if (moveMap) _mapController.move(point, 16);
    } catch (error) {
      if (!mounted) return;
      setState(() => _locating = false);
      if (showError) _showError(error, offerSettings: true);
    }
  }

  /// 주소 검색 결과의 좌표로 지도를 이동하고 선택 위치를 갱신합니다.
  Future<void> _searchAddress() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _resolvingAddress = true;
      _addressError = null;
    });
    try {
      final result = await widget.viewModel.findLocationByAddress(
        _addressController.text,
      );
      if (!mounted) return;
      final point = LatLng(result.location.latitude, result.location.longitude);
      setState(() {
        _selectedLocation = point;
        _selectedAddress = result.address;
        _addressController.text = result.address;
        _resolvingAddress = false;
      });
      _mapController.move(point, 16);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _resolvingAddress = false;
        _addressError = _errorMessage(error);
      });
    }
  }

  /// 지도에서 선택한 좌표를 주소로 변환해 선택 결과에 함께 저장합니다.
  Future<void> _selectMapPoint(LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _selectedAddress = '';
      _resolvingAddress = true;
    });
    try {
      final address = await widget.viewModel.findAddress(
        point.latitude,
        point.longitude,
      );
      if (!mounted || _selectedLocation != point) return;
      setState(() {
        _selectedAddress = address;
        _addressController.text = address;
        _resolvingAddress = false;
      });
    } catch (error) {
      if (!mounted || _selectedLocation != point) return;
      setState(() => _resolvingAddress = false);
      _showError(error);
    }
  }

  void _showError(Object error, {bool offerSettings = false}) {
    final message = _errorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: offerSettings
            ? SnackBarAction(
                label: '설정',
                onPressed: () => Geolocator.openAppSettings(),
              )
            : null,
      ),
    );
  }

  String _errorMessage(Object error) => error
      .toString()
      .replaceFirst('Bad state: ', '')
      .replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    final center = widget.initialLocation ?? _currentLocation ?? _seoulCityHall;
    return Scaffold(
      appBar: AppBar(title: const Text('지도에서 위치 선택')),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom:
                    widget.initialLocation != null || _currentLocation != null
                    ? 16
                    : 12,
                onTap: (_, point) => _selectMapPoint(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.must_eat_place_app',
                ),
                MarkerLayer(markers: _buildMarkers()),
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
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('address_search_field'),
                              controller: _addressController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _searchAddress(),
                              decoration: const InputDecoration(
                                hintText: '주소를 검색해 주세요',
                                prefixIcon: Icon(Icons.search_rounded),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            key: const Key('address_search_button'),
                            onPressed: _resolvingAddress
                                ? null
                                : _searchAddress,
                            tooltip: '주소 검색',
                            icon: _resolvingAddress
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward_rounded),
                          ),
                        ],
                      ),
                      if (_addressError != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _addressError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextButton(
                              key: const Key('retry_address_search_button'),
                              onPressed: _searchAddress,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 88,
            child: SafeArea(
              top: false,
              child: IconButton.filled(
                key: const Key('current_location_button'),
                onPressed: _locating
                    ? null
                    : () => _moveToCurrentLocation(showError: true),
                tooltip: '내 위치로 이동',
                icon: _locating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: FilledButton.icon(
                key: const Key('confirm_location_button'),
                onPressed: _selectedLocation == null || _resolvingAddress
                    ? null
                    : () => Navigator.pop(
                        context,
                        SelectedPlaceLocation(
                          point: _selectedLocation!,
                          address: _selectedAddress,
                        ),
                      ),
                icon: const Icon(Icons.check),
                label: Text(_resolvingAddress ? '주소 확인 중...' : '이 위치로 설정'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 현재 위치와 선택 위치를 파란 점과 빨간 핀으로 구분합니다.
  List<Marker> _buildMarkers() => [
    if (_currentLocation != null)
      Marker(
        key: const Key('current_location_marker'),
        point: _currentLocation!,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 3)],
            ),
          ),
        ),
      ),
    if (_selectedLocation != null)
      Marker(
        key: const Key('selected_location_marker'),
        point: _selectedLocation!,
        width: 56,
        height: 56,
        child: Icon(
          Icons.location_pin,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
      ),
  ];
}
