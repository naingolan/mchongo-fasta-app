import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/location_picker.dart';
import 'package:mobile/widgets/mf_components.dart';
import 'package:mobile/widgets/mf_google_map.dart';

class PostedTask {
  const PostedTask({
    required this.category,
    required this.title,
    required this.details,
    required this.area,
    required this.whenLabel,
    required this.budgetTzs,
    required this.latitude,
    required this.longitude,
    this.landmark = '',
  });

  final String category;
  final String title;
  final String details;
  final String area;
  final String whenLabel;
  final int budgetTzs;
  final double latitude;
  final double longitude;
  final String landmark;
}

/// Multi-step employer flow: category → details → place/time → budget → review.
class PostTaskFlowScreen extends StatefulWidget {
  const PostTaskFlowScreen({super.key, this.onPosted});

  final ValueChanged<PostedTask>? onPosted;

  @override
  State<PostTaskFlowScreen> createState() => _PostTaskFlowScreenState();
}

class _PostTaskFlowScreenState extends State<PostTaskFlowScreen> {
  int _step = 0;

  String? _category;
  final _title = TextEditingController();
  final _details = TextEditingController();
  final _budget = TextEditingController();
  final _landmark = TextEditingController();

  TaskLocation? _location;
  String _when = 'Today';

  static const _categories = [
    ('Domestic', Icons.cleaning_services_outlined),
    ('Logistics', Icons.local_shipping_outlined),
    ('Care', Icons.favorite_border_rounded),
    ('Technical', Icons.handyman_outlined),
  ];

  static const _whenOptions = [
    'Today',
    'Tomorrow',
    'This week',
    'Flexible',
  ];

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _budget.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step -= 1);
  }

  void _close() => Navigator.of(context).maybePop();

  void _next() => setState(() => _step += 1);

  int get _budgetValue {
    final raw = _budget.text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _submit() async {
    final location = _location;
    if (location == null) return;

    final task = PostedTask(
      category: _category ?? 'Domestic',
      title: _title.text.trim().isEmpty
          ? 'New short-term task'
          : _title.text.trim(),
      details: _details.text.trim(),
      area: location.areaLabel,
      whenLabel: _when,
      budgetTzs: _budgetValue,
      latitude: location.latitude,
      longitude: location.longitude,
      landmark: _landmark.text.trim(),
    );

    widget.onPosted?.call(task);

    await showMfSuccessDialog(
      context: context,
      title: 'Task posted',
      message:
          '“${task.title}” is live. Verified workers nearby can now apply.',
      actionLabel: 'Done',
      onDone: () => Navigator.of(context).pop(task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              MfScreenHeader(onBack: _back, onClose: _close),
              const SizedBox(height: 8),
              _StepProgress(current: _step, total: 5),
              const SizedBox(height: 18),
              Expanded(child: _buildStep()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _CategoryStep(
          categories: _categories,
          selected: _category,
          onSelect: (value) {
            setState(() => _category = value);
            _next();
          },
        );
      case 1:
        return _DetailsStep(
          title: _title,
          details: _details,
          onContinue: () {
            if (_title.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add a task title to continue.')),
              );
              return;
            }
            _next();
          },
        );
      case 2:
        return _PlaceTimeStep(
          whenOptions: _whenOptions,
          location: _location,
          landmark: _landmark,
          when: _when,
          onLocation: (value) => setState(() => _location = value),
          onWhen: (value) => setState(() => _when = value),
          onContinue: () {
            if (_location == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pin the exact location on the map to continue.'),
                ),
              );
              return;
            }
            _next();
          },
        );
      case 3:
        return _BudgetStep(
          controller: _budget,
          onContinue: () {
            if (_budgetValue <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a budget in TZS.')),
              );
              return;
            }
            _next();
          },
        );
      default:
        return _ReviewStep(
          category: _category ?? 'Domestic',
          title: _title.text.trim(),
          details: _details.text.trim(),
          location: _location!,
          landmark: _landmark.text.trim(),
          when: _when,
          budgetTzs: _budgetValue,
          onPost: _submit,
        );
    }
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? MfColors.primary : MfColors.line,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<(String, IconData)> categories;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What kind of task?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose a category so we can match the right verified workers.',
          style: TextStyle(color: MfColors.muted, height: 1.45),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: categories.map((item) {
              final (name, icon) = item;
              final isSelected = selected == name;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Material(
                color: isSelected
                    ? (isDark ? MfColors.primaryDark : const Color(0xFFEEF2FF))
                    : (isDark ? MfColors.surfaceDarkElevated : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  onTap: () => onSelect(name),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? MfColors.primarySoft : MfColors.primary)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          icon,
                          color: isSelected
                              ? (isDark ? Colors.white : MfColors.primary)
                              : (isDark ? MfColors.primarySoft : MfColors.primary),
                          size: 28,
                        ),
                        const Spacer(),
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: isDark ? Colors.white : MfColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.title,
    required this.details,
    required this.onContinue,
  });

  final TextEditingController title;
  final TextEditingController details;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe the task',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Be clear about what you need so workers can apply confidently.',
          style: TextStyle(color: MfColors.muted, height: 1.45),
        ),
        const SizedBox(height: 24),
        MfTextField(
          controller: title,
          label: 'Task title',
          hintText: 'e.g. Clean a 3 bedroom house',
          icon: Icons.title_outlined,
        ),
        const SizedBox(height: 14),
        const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: details,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Tools needed, access notes, expected outcome…',
          ),
        ),
        const Spacer(),
        MfPrimaryButton(label: 'Continue', onPressed: onContinue),
      ],
    );
  }
}

class _PlaceTimeStep extends StatelessWidget {
  const _PlaceTimeStep({
    required this.whenOptions,
    required this.location,
    required this.landmark,
    required this.when,
    required this.onLocation,
    required this.onWhen,
    required this.onContinue,
  });

  final List<String> whenOptions;
  final TaskLocation? location;
  final TextEditingController landmark;
  final String when;
  final ValueChanged<TaskLocation> onLocation;
  final ValueChanged<String> onWhen;
  final VoidCallback onContinue;

  Future<void> _pickLocation(BuildContext context) async {
    final picked = await showLocationPicker(
      context: context,
      initial: location,
    );
    if (picked != null) onLocation(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Where and when?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pin the exact spot — a neighbourhood name alone isn’t enough for workers to find you.',
                  style: TextStyle(color: MfColors.muted, height: 1.45),
                ),
                const SizedBox(height: 16),
                _LocationCard(
                  location: location,
                  onPick: () => _pickLocation(context),
                ),
                const SizedBox(height: 14),
                MfTextField(
                  controller: landmark,
                  label: 'Landmark / access notes',
                  hintText: 'e.g. Blue gate near Total petrol',
                  icon: Icons.signpost_outlined,
                ),
                const SizedBox(height: 18),
                const Text(
                  'When',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...whenOptions.map((item) {
                  return MfRadioRow(
                    label: item,
                    selected: when == item,
                    onTap: () => onWhen(item),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        MfPrimaryButton(label: 'Continue', onPressed: onContinue),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.onPick,
  });

  final TaskLocation? location;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final hasPin = location != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: hasPin
                      ? MfGoogleMap(
                          initialTarget: location!.position,
                          initialZoom: 15,
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          markers: {
                            Marker(
                              markerId: const MarkerId('task'),
                              position: location!.position,
                            ),
                          },
                        )
                      : Container(
                          color: isDark ? MfColors.surfaceDarkElevated : const Color(0xFFE8EEF9),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                color: isDark ? MfColors.primarySoft : MfColors.primary,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap Set pin to open Google Maps',
                                style: TextStyle(
                                  color: isDark ? MfColors.mutedDark : MfColors.muted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasPin ? location!.areaLabel : 'No pin yet',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasPin
                              ? location!.shortCoords
                              : 'Use GPS or drop a pin on the map',
                          style: TextStyle(
                            color: isDark ? MfColors.mutedDark : MfColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onPick,
                    icon: Icon(
                      hasPin
                          ? Icons.edit_location_alt_outlined
                          : Icons.add_location_alt_outlined,
                    ),
                    label: Text(hasPin ? 'Adjust' : 'Set pin'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetStep extends StatelessWidget {
  const _BudgetStep({
    required this.controller,
    required this.onContinue,
  });

  final TextEditingController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set your budget',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Offer a fair amount in TZS. Workers see this before they apply.',
          style: TextStyle(color: MfColors.muted, height: 1.45),
        ),
        const SizedBox(height: 28),
        MfTextField(
          controller: controller,
          label: 'Budget (TZS)',
          hintText: '35000',
          icon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['15000', '35000', '50000', '95000'].map((amount) {
            return ActionChip(
              label: Text('TZS $amount'),
              onPressed: () => controller.text = amount,
            );
          }).toList(),
        ),
        const Spacer(),
        MfPrimaryButton(label: 'Continue', onPressed: onContinue),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.category,
    required this.title,
    required this.details,
    required this.location,
    required this.landmark,
    required this.when,
    required this.budgetTzs,
    required this.onPost,
  });

  final String category;
  final String title;
  final String details;
  final TaskLocation location;
  final String landmark;
  final String when;
  final int budgetTzs;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review and post',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Confirm the details, then match verified workers nearby.',
          style: TextStyle(color: MfColors.muted, height: 1.45),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReviewLine(label: 'Category', value: category),
                    _ReviewLine(label: 'Title', value: title),
                    if (details.isNotEmpty)
                      _ReviewLine(label: 'Details', value: details),
                    _ReviewLine(
                      label: 'Location',
                      value:
                          '${location.areaLabel}\n${location.shortCoords}',
                    ),
                    if (landmark.isNotEmpty)
                      _ReviewLine(label: 'Landmark', value: landmark),
                    _ReviewLine(label: 'When', value: when),
                    _ReviewLine(
                      label: 'Budget',
                      value: 'TZS ${budgetTzs.toLocaleString()}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        MfPrimaryButton(label: 'Post task', onPressed: onPost),
      ],
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: MfColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
          ),
        ],
      ),
    );
  }
}

extension on int {
  String toLocaleString() {
    final digits = toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      buf.write(digits[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
