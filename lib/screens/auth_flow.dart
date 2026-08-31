import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/models/user_role.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/mf_components.dart';

/// Phone → OTP → setup checklist. Tanzania-only for now.
/// Notification / Face ID live in Profile settings, not here.
class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({
    super.key,
    required this.homeBuilder,
    this.role = UserRole.worker,
  });

  final WidgetBuilder homeBuilder;
  final UserRole role;

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  int _step = 0;

  final _phone = TextEditingController(text: '+255 ');

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step -= 1);
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: widget.homeBuilder),
    );
  }

  void _next() => setState(() => _step += 1);

  Future<void> _finish() async {
    await showMfSuccessDialog(
      context: context,
      title: widget.role == UserRole.employer
          ? 'Great, your employer account is ready'
          : 'Great, your worker account is ready',
      message: widget.role == UserRole.employer
          ? 'You can now post tasks, review verified workers, and pay securely.'
          : 'You can now apply for mchongo nearby and get paid securely.',
      onDone: _goHome,
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
              MfScreenHeader(onBack: _back, onClose: _goHome),
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
        return _PhoneStep(
          controller: _phone,
          onContinue: _next,
        );
      case 1:
        return _OtpStep(
          phone: _phone.text.trim(),
          onVerified: _next,
          onResend: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent again to your phone.')),
            );
          },
        );
      default:
        return _SetupStep(
          role: widget.role,
          onContinue: _finish,
        );
    }
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.controller,
    required this.onContinue,
  });

  final TextEditingController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What’s your number?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'We’ll send an SMS code to verify your account. Works on Vodacom, Tigo, Airtel, and Halotel.',
          style: TextStyle(
            color: isDark ? MfColors.mutedDark : MfColors.muted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        MfTextField(
          controller: controller,
          label: 'Phone number',
          hintText: '+255 712 345 678',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const Spacer(),
        MfPrimaryButton(label: 'Continue', onPressed: onContinue),
      ],
    );
  }
}

class _OtpStep extends StatefulWidget {
  const _OtpStep({
    required this.phone,
    required this.onVerified,
    required this.onResend,
  });

  final String phone;
  final VoidCallback onVerified;
  final VoidCallback onResend;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  static const _length = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());
    for (final node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != _length) {
      setState(() => _error = 'Enter the 6-digit code sent to your phone.');
      return;
    }
    setState(() => _error = null);
    widget.onVerified();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.phone.isEmpty ? 'your number' : widget.phone;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter the OTP',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: isDark ? MfColors.mutedDark : MfColors.muted,
              height: 1.45,
            ),
            children: [
              const TextSpan(text: 'We sent a 6-digit code to '),
              TextSpan(
                text: phone,
                style: TextStyle(
                  color: isDark ? Colors.white : MfColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: List.generate(_length, (index) {
            final isFocused = _focusNodes[index].hasFocus;
            final hasValue = _controllers[index].text.isNotEmpty;
            final borderColor = isFocused
                ? MfColors.primary
                : hasValue
                    ? (isDark ? MfColors.primarySoft : MfColors.primary)
                    : (isDark ? MfColors.lineDark : const Color(0xFFE2E8F0));
            final bgColor = isDark ? MfColors.surfaceDarkElevated : Colors.white;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < _length - 1 ? 8.0 : 0.0,
                ),
                height: 56,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: (isFocused || hasValue) ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isFocused
                          ? MfColors.primary.withValues(alpha: 0.18)
                          : (isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : MfColors.ink.withValues(alpha: 0.04)),
                      blurRadius: isFocused ? 10 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : MfColors.ink,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      counterText: '',
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (value) {
                      if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      _onChanged(index, value);
                    },
                  ),
                ),
              ),
            );
          }),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 18),
        TextButton(
          onPressed: widget.onResend,
          child: const Text(
            'Resend code',
            style: TextStyle(
              color: MfColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
        MfPrimaryButton(label: 'Verify OTP', onPressed: _verify),
      ],
    );
  }
}

class _SetupStep extends StatefulWidget {
  const _SetupStep({
    required this.role,
    required this.onContinue,
  });

  final UserRole role;
  final VoidCallback onContinue;

  @override
  State<_SetupStep> createState() => _SetupStepState();
}

class _SetupStepState extends State<_SetupStep> {
  final _nameController = TextEditingController();
  final _nidaController = TextEditingController();
  String _selectedArea = 'Mikocheni';
  final Set<String> _selectedCategories = {'Domestic'};
  String? _error;

  static const _areas = [
    'Mikocheni',
    'Masaki',
    'Kariakoo',
    'Sinza',
    'Kinondoni',
    'Posta',
    'Mbezi Beach',
    'Tabata',
  ];

  static const _categories = [
    'Domestic',
    'Logistics',
    'Care',
    'Technical',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nidaController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }
    if (_selectedCategories.isEmpty) {
      setState(() => _error = 'Please select at least one work category.');
      return;
    }
    setState(() => _error = null);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final isWorker = widget.role == UserRole.worker;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Text(
                isWorker ? 'Set up your profile' : 'Set up employer profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                isWorker
                    ? 'Enter your name, area in Dar, and the work categories you specialize in.'
                    : 'Enter your name or business name, primary location, and services needed.',
                style: TextStyle(
                  color: isDark ? MfColors.mutedDark : MfColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              MfTextField(
                controller: _nameController,
                label: isWorker ? 'Full Name' : 'Business or Full Name',
                hintText: isWorker ? 'e.g. Asha Mwinyi' : 'e.g. Masaki Logistics Ltd',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              Text(
                'Primary Area in Dar',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : MfColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _areas.map((area) {
                  final isSelected = _selectedArea == area;
                  return ChoiceChip(
                    label: Text(area),
                    selected: isSelected,
                    checkmarkColor: Colors.white,
                    selectedColor: MfColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : MfColors.ink),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedArea = area);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              Text(
                isWorker ? 'Work Categories' : 'Services Needed',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : MfColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategories.contains(cat);
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    checkmarkColor: Colors.white,
                    selectedColor: MfColors.primary,
                    backgroundColor: isDark
                        ? MfColors.surfaceDarkElevated
                        : const Color(0xFFF3F4F6),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : MfColors.ink),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(cat);
                        } else {
                          if (_selectedCategories.length > 1) {
                            _selectedCategories.remove(cat);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              MfTextField(
                controller: _nidaController,
                label: 'National ID / NIDA (Optional)',
                hintText: '19901234-12345-00001-12',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
        const SizedBox(height: 12),
        MfPrimaryButton(
          label: 'Complete Setup',
          onPressed: _submit,
        ),
      ],
    );
  }
}
