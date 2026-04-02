import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/record_strings.dart';

class RecordCreateTripScreen extends ConsumerStatefulWidget {
  const RecordCreateTripScreen({super.key});

  @override
  ConsumerState<RecordCreateTripScreen> createState() =>
      _RecordCreateTripScreenState();
}

class _RecordCreateTripScreenState
    extends ConsumerState<RecordCreateTripScreen> {
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _currentStep = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  Color _selectedColor = const Color(0xFF78B7FF);
  bool _saving = false;

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    final theme = Theme.of(context);
    final palette = context.atlasPalette;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AtlasBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            strings.text('create.title'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${strings.text('create.step')} ${_currentStep + 1} ${strings.text('create.of')} 3',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: palette.surfaceMuted,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Padding(
                    key: ValueKey(_currentStep),
                    padding: const EdgeInsets.all(24),
                    child: _buildStep(_currentStep, strings),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _currentStep -= 1),
                        child: Text(strings.text('create.back')),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _handlePrimaryAction,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _currentStep == 2
                                    ? strings.text('create.createJourney')
                                    : strings.text('create.continue'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int step, RecordStrings strings) {
    switch (step) {
      case 0:
        return _TripBasicsStep(
          strings: strings,
          cityController: _cityController,
          countryController: _countryController,
          startDate: _startDate,
          endDate: _endDate,
          onPickStartDate: () => _pickDate(isStart: true),
          onPickEndDate: () => _pickDate(isStart: false),
        );
      case 1:
        return _TripMoodStep(
          strings: strings,
          titleController: _titleController,
          descriptionController: _descriptionController,
          selectedColor: _selectedColor,
          onColorSelected: (color) => setState(() => _selectedColor = color),
        );
      case 2:
        return _TripReviewStep(
          strings: strings,
          city: _cityController.text.trim(),
          country: _countryController.text.trim(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          color: _selectedColor,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = (isStart ? _startDate : _endDate) ??
        _startDate ??
        now.add(const Duration(days: 7));
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (selected == null) return;
    setState(() {
      if (isStart) {
        _startDate = selected;
        if (_endDate != null && _endDate!.isBefore(selected)) {
          _endDate = selected.add(const Duration(days: 3));
        }
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _handlePrimaryAction() async {
    if (_currentStep == 0 && !_validateBasics()) return;
    if (_currentStep == 1 && !_validateMood()) return;
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
      return;
    }

    setState(() => _saving = true);
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final startDate = _startDate!;
    final endDate = _endDate!;
    final shortDateFormat = RecordStrings.of(context).dateFormat('MMM d');

    await ref.read(travelAppControllerProvider.notifier).createTrip(
          title: title,
          subtitle: description.isEmpty ? '$city, $country' : description,
          startDate: startDate,
          endDate: endDate,
          heroPlace: PlaceRef(
            countryCode: _countryCodeFor(country),
            countryName: country,
            cityName: city,
          ),
          coverHint:
              '${shortDateFormat.format(startDate)} • ${_colorMoodLabel(_selectedColor)}',
        );

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          RecordStrings.of(context).isKorean
              ? '여행이 저장되었습니다.'
              : 'Trip saved locally.',
        ),
      ),
    );
  }

  bool _validateBasics() {
    final strings = RecordStrings.of(context);
    if (_cityController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isKorean
                ? '도시, 국가, 시작일, 종료일을 모두 입력해 주세요.'
                : 'Enter the city, country, start date, and end date.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateMood() {
    final strings = RecordStrings.of(context);
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isKorean ? '여행 제목을 입력해 주세요.' : 'Enter a trip title.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  String _countryCodeFor(String countryName) {
    switch (countryName.trim().toLowerCase()) {
      case 'south korea':
      case 'korea':
      case '대한민국':
      case '한국':
        return 'KR';
      case 'japan':
      case '일본':
        return 'JP';
      case 'portugal':
        return 'PT';
      case 'france':
        return 'FR';
      case 'italy':
        return 'IT';
      case 'canada':
        return 'CA';
      case 'united states':
      case 'usa':
        return 'US';
      default:
        final cleaned =
            countryName.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
        return cleaned.length >= 2 ? cleaned.substring(0, 2) : 'XX';
    }
  }

  String _colorMoodLabel(Color color) {
    if (color == const Color(0xFFE07A5F)) return 'sunset warmth';
    if (color == const Color(0xFF49B884)) return 'forest route';
    if (color == const Color(0xFF8E7CFF)) return 'night pulse';
    if (color == const Color(0xFFF4C95D)) return 'sunlit paper';
    return 'sky orbit';
  }
}

class _TripBasicsStep extends StatelessWidget {
  const _TripBasicsStep({
    required this.strings,
    required this.cityController,
    required this.countryController,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
  });

  final RecordStrings strings;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AtlasPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.text('create.where'),
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(strings.text('create.previewNote'),
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          _InputLabel(label: strings.text('create.destination')),
          _InputField(
            controller: cityController,
            hint: strings.isKorean ? '예: 교토' : 'Example: Kyoto',
            icon: Icons.location_city_rounded,
          ),
          const SizedBox(height: 18),
          _InputLabel(label: strings.text('create.country')),
          _InputField(
            controller: countryController,
            hint: strings.isKorean ? '예: 일본' : 'Example: Japan',
            icon: Icons.public_rounded,
          ),
          const SizedBox(height: 24),
          _InputLabel(label: strings.text('create.when')),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: strings.text('create.startDate'),
                  value: startDate,
                  onTap: onPickStartDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: strings.text('create.endDate'),
                  value: endDate,
                  onTap: onPickEndDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripMoodStep extends StatelessWidget {
  const _TripMoodStep({
    required this.strings,
    required this.titleController,
    required this.descriptionController,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final RecordStrings strings;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AtlasPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.text('create.tripTitle'),
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 18),
          _InputField(
            controller: titleController,
            hint: strings.isKorean
                ? '예: 교토 비 오는 골목 산책'
                : 'Example: Kyoto alleys in spring rain',
            icon: Icons.draw_rounded,
          ),
          const SizedBox(height: 18),
          _InputLabel(label: strings.text('create.description')),
          _InputField(
            controller: descriptionController,
            hint: strings.text('create.descriptionPlaceholder'),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          _InputLabel(
            label: strings.isKorean ? '강조 색상' : 'Accent color',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              Color(0xFF78B7FF),
              Color(0xFFE07A5F),
              Color(0xFF49B884),
              Color(0xFF8E7CFF),
              Color(0xFFF4C95D),
            ].map((color) {
              return _ColorChoice(
                color: color,
                selectedColor: selectedColor,
                onTap: onColorSelected,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TripReviewStep extends StatelessWidget {
  const _TripReviewStep({
    required this.strings,
    required this.city,
    required this.country,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.color,
  });

  final RecordStrings strings;
  final String city;
  final String country;
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final longDateFormat = strings.dateFormat('MMM d, yyyy');
    final theme = Theme.of(context);
    return AtlasPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.text('create.review'),
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.92),
                  color.withValues(alpha: 0.58),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? strings.text('create.tripTitle') : title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$city, $country',
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                if (startDate != null && endDate != null)
                  Text(
                    '${longDateFormat.format(startDate!)} - ${longDateFormat.format(endDate!)}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.88)),
                  ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(strings.text('create.previewNote'),
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = RecordStrings.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.atlasPalette.surfaceMuted,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.atlasPalette.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              value == null
                  ? (strings.isKorean ? '선택' : 'Select')
                  : strings.dateFormat('MMM d, yyyy').format(value!),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selectedColor,
    required this.onTap,
  });

  final Color color;
  final Color selectedColor;
  final ValueChanged<Color> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = color == selectedColor;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: selected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
