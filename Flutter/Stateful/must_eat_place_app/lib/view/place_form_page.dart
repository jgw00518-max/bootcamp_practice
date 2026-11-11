import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../model/must_eat_place.dart';
import '../vm/must_eat_place_view_model.dart';
import 'place_location_picker_page.dart';

/// 맛집 추가와 수정에서 공통으로 사용하는 입력 화면이다.
class PlaceFormPage extends StatefulWidget {
  const PlaceFormPage({super.key, required this.viewModel, this.place});

  final MustEatPlaceViewModel viewModel;
  final MustEatPlace? place;

  @override
  State<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends State<PlaceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _addressController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _menuController;
  late final TextEditingController _estimateController;
  late String _selectedCategory;
  late double _rating;
  Uint8List? _imageBytes;
  bool _saving = false;
  bool _showRatingError = false;
  bool _showLocationError = false;

  bool get _isEditing => widget.place != null;

  /// DB 로딩 전 직접 연 테스트 화면에서는 기본 카테고리를 안전하게 사용한다.
  List<String> get _availableCategories => widget.viewModel.categories.isEmpty
      ? MustEatPlace.categories
      : widget.viewModel.categories;

  @override
  void initState() {
    super.initState();
    final place = widget.place;
    _latitudeController = TextEditingController(text: place?.lat.toString());
    _longitudeController = TextEditingController(text: place?.lng.toString());
    _addressController = TextEditingController(text: place?.address);
    _nameController = TextEditingController(text: place?.name);
    _phoneController = TextEditingController(text: place?.phone);
    _menuController = TextEditingController(text: place?.menu);
    _estimateController = TextEditingController(text: place?.estimate);
    _selectedCategory = place?.category ?? _availableCategories.first;
    _rating = place?.rating ?? 0;
    _imageBytes = place?.image;
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _menuController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  /// 갤러리에서 한 장을 선택해 SQLite에 저장할 바이트로 읽는다.
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (mounted) setState(() => _imageBytes = bytes);
  }

  String? _validateText(String? value) {
    if (value == null || value.trim().isEmpty) return '필수 입력 항목입니다.';
    return null;
  }

  /// 현재 수정 중인 맛집은 제외하고 동일한 이름이 이미 저장됐는지 확인합니다.
  String? _validateName(String? value) {
    final requiredError = _validateText(value);
    if (requiredError != null) return requiredError;
    final name = value!.trim().toLowerCase();
    final duplicated = widget.viewModel.places.any(
      (place) =>
          place.seq != widget.place?.seq &&
          place.name.trim().toLowerCase() == name,
    );
    return duplicated ? '이미 등록된 맛집 이름입니다.' : null;
  }

  /// 일반 전화번호와 지역번호를 포함한 국내 전화번호 형식을 확인합니다.
  String? _validatePhone(String? value) {
    final requiredError = _validateText(value);
    if (requiredError != null) return requiredError;
    final phone = value!.trim().replaceAll(' ', '');
    final pattern = RegExp(r'^(?:0\d{1,2}-?\d{3,4}-?\d{4}|\d{3,4}-\d{4})$');
    return pattern.hasMatch(phone) ? null : '전화번호 형식을 확인해 주세요.';
  }

  String? _validateCoordinate(String? value, double min, double max) {
    final coordinate = value == null ? null : double.tryParse(value.trim());
    if (coordinate == null) {
      return '숫자로 입력해 주세요.';
    }
    if (coordinate < min || coordinate > max) {
      return '$min 이상 $max 이하로 입력해 주세요.';
    }
    return null;
  }

  /// 직접 입력한 좌표를 초기값으로 전달하고 지도 선택 결과를 입력란에 반영한다.
  Future<void> _pickLocationOnMap() async {
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    final hasValidLocation =
        latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;

    final selectedLocation = await Navigator.push<SelectedPlaceLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceLocationPickerPage(
          viewModel: widget.viewModel,
          initialLocation: hasValidLocation
              ? LatLng(latitude, longitude)
              : null,
          initialAddress: _addressController.text,
        ),
      ),
    );
    if (selectedLocation == null || !mounted) return;

    setState(() {
      _latitudeController.text = selectedLocation.point.latitude
          .toStringAsFixed(6);
      _longitudeController.text = selectedLocation.point.longitude
          .toStringAsFixed(6);
      _addressController.text = selectedLocation.address;
      _showLocationError = false;
    });
  }

  /// 입력값을 모델로 변환해 ViewModel에 추가 또는 수정을 요청한다.
  Future<void> _save() async {
    final formIsValid = _formKey.currentState!.validate();
    final ratingIsMissing = _rating == 0;
    final locationIsMissing =
        _validateCoordinate(_latitudeController.text, -90, 90) != null ||
        _validateCoordinate(_longitudeController.text, -180, 180) != null;
    if (!formIsValid || ratingIsMissing || locationIsMissing) {
      setState(() {
        _showRatingError = ratingIsMissing;
        _showLocationError = locationIsMissing;
      });
      return;
    }

    setState(() => _saving = true);
    final oldPlace = widget.place;
    final place = MustEatPlace(
      seq: oldPlace?.seq,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      phone: _phoneController.text.trim(),
      menu: _menuController.text.trim(),
      lat: double.parse(_latitudeController.text.trim()),
      lng: double.parse(_longitudeController.text.trim()),
      address: _addressController.text.trim(),
      image: _imageBytes,
      estimate: _estimateController.text.trim(),
      initDate: oldPlace?.initDate ?? DateTime.now(),
      isFavorite: oldPlace?.isFavorite ?? false,
      rating: _rating,
    );

    try {
      if (_isEditing) {
        await widget.viewModel.updatePlace(place);
      } else {
        await widget.viewModel.addPlace(place);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장하지 못했습니다: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '맛집 수정' : '맛집 추가')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: FilledButton.icon(
            key: const Key('save_place_button'),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_saving ? '저장 중...' : (_isEditing ? '수정' : '저장')),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            key: const Key('place_form_scroll'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionTitle(
                  icon: Icons.add_a_photo_outlined,
                  title: '맛집 사진',
                  description: '기억하기 좋은 대표 사진을 등록해 주세요.',
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 210,
                    alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: _imageBytes == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 52,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              const Text('아직 선택한 사진이 없어요'),
                            ],
                          )
                        : Image.memory(
                            _imageBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: FilledButton.tonalIcon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('이미지 가져오기'),
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle(
                  icon: Icons.storefront_outlined,
                  title: '기본 정보',
                  description: '이름과 분류, 연락처를 입력해 주세요.',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const Key('name_field'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '이름 *'),
                  validator: _validateName,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('category_dropdown'),
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: '분류 *'),
                  items: _availableCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (category) {
                    if (category != null) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('phone_field'),
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: '전화번호 *'),
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 28),
                const _SectionTitle(
                  icon: Icons.location_on_outlined,
                  title: '위치',
                  description: '지도에서 맛집 위치를 선택해 주세요.',
                ),
                const SizedBox(height: 14),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const Key('address_field'),
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                          textInputAction: TextInputAction.done,
                          maxLength: 100,
                          validator: _validateText,
                          decoration: const InputDecoration(
                            labelText: '선택된 주소 *',
                            hintText: '지도에서 위치를 선택해 주세요.',
                            helperText: '주소가 부정확하면 직접 수정할 수 있습니다.',
                            counterText: '',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        if (_showLocationError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '지도에서 위치를 선택해 주세요.',
                              key: const Key('location_error'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const Key('map_location_picker_button'),
                          onPressed: _pickLocationOnMap,
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: Text(_isEditing ? '지도에서 위치 변경' : '지도에서 위치 선택'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle(
                  icon: Icons.rate_review_outlined,
                  title: '나의 기록',
                  description: '다시 방문할 때 기억할 내용을 남겨 보세요.',
                ),
                const SizedBox(height: 14),
                if (_isEditing)
                  TextFormField(
                    controller: _menuController,
                    decoration: const InputDecoration(
                      labelText: '메뉴',
                      hintText: '대표 메뉴나 가격 등을 입력해 주세요.',
                      counterText: '',
                    ),
                    maxLength: 100,
                    maxLines: 3,
                  ),
                if (_isEditing) const SizedBox(height: 12),
                _RatingInput(
                  rating: _rating,
                  errorText: _showRatingError ? '별점을 선택해 주세요.' : null,
                  onChanged: (rating) => setState(() {
                    _rating = rating;
                    _showRatingError = false;
                  }),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _estimateController,
                  decoration: const InputDecoration(
                    labelText: '평가',
                    counterText: '',
                  ),
                  maxLength: 50,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 입력 항목을 의미 단위로 구분해 긴 폼의 흐름을 쉽게 파악하게 한다.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 추가와 수정 화면에서 1.0~5.0 별점을 0.5 단위로 선택하게 한다.
class _RatingInput extends StatelessWidget {
  const _RatingInput({
    required this.rating,
    required this.onChanged,
    this.errorText,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final displayValue = rating == 0 ? 1.0 : rating;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: errorText == null
              ? Theme.of(context).colorScheme.outlineVariant
              : Theme.of(context).colorScheme.error,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('별점', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                rating == 0 ? '미등록' : rating.toStringAsFixed(1),
                key: const Key('rating_value'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final IconData icon;
              if (rating >= starValue) {
                icon = Icons.star_rounded;
              } else if (rating >= starValue - 0.5) {
                icon = Icons.star_half_rounded;
              } else {
                icon = Icons.star_outline_rounded;
              }
              return Icon(icon, color: const Color(0xFFF4A825), size: 30);
            }),
          ),
          Slider(
            key: const Key('rating_slider'),
            value: displayValue,
            min: 1,
            max: 5,
            divisions: 8,
            label: displayValue.toStringAsFixed(1),
            onChanged: onChanged,
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                errorText!,
                key: const Key('rating_error'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
