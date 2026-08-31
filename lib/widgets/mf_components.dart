import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/tab_icons.dart';

/// Shared MchongoFasta UI primitives from the design system.
class MfCircleIconButton extends StatelessWidget {
  const MfCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final button = Material(
      color: isDark ? MfColors.surfaceDarkElevated : const Color(0xFFF3F4F6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white : MfColors.ink,
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class MfScreenHeader extends StatelessWidget {
  const MfScreenHeader({
    super.key,
    this.onBack,
    this.onClose,
  });

  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          MfCircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: onBack,
          )
        else
          const SizedBox(width: 40),
        const Spacer(),
        if (onClose != null)
          MfCircleIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Close',
            onPressed: onClose,
          )
        else
          const SizedBox(width: 40),
      ],
    );
  }
}

class MfPrimaryButton extends StatelessWidget {
  const MfPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class MfSecondaryButton extends StatelessWidget {
  const MfSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor:
              isDark ? MfColors.surfaceDarkElevated : const Color(0xFFF3F4F6),
          foregroundColor: isDark ? Colors.white : MfColors.ink,
        ),
        child: Text(label),
      ),
    );
  }
}

class MfTextField extends StatefulWidget {
  const MfTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.inputFormatters,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  @override
  State<MfTextField> createState() => _MfTextFieldState();
}

class _MfTextFieldState extends State<MfTextField> {
  late FocusNode _focusNode;
  bool _internalFocusNode = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocusNode = true;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_internalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : MfColors.ink;
    final mutedColor = isDark ? MfColors.mutedDark : MfColors.muted;
    final borderColor = _isFocused
        ? MfColors.primary
        : (isDark ? MfColors.lineDark : const Color(0xFFE2E8F0));
    final bgColor = isDark ? MfColors.surfaceDarkElevated : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: fgColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? MfColors.primary.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : MfColors.ink.withValues(alpha: 0.04)),
                blurRadius: _isFocused ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: fgColor,
            ),
            decoration: InputDecoration(
              filled: false,
              hintText: widget.hintText,
              hintStyle: TextStyle(color: mutedColor, fontWeight: FontWeight.normal),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: widget.icon == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          widget.icon,
                          color: _isFocused
                              ? MfColors.primary
                              : mutedColor,
                          size: 22,
                        ),
                        Container(
                          width: 1,
                          height: 22,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: _isFocused
                              ? MfColors.primary.withValues(alpha: 0.3)
                              : (isDark ? MfColors.lineDark : MfColors.line),
                        ),
                      ],
                    ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              suffixIcon: widget.suffix,
            ),
          ),
        ),
      ],
    );
  }
}

class MfSearchField extends StatelessWidget {
  const MfSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? Colors.white : MfColors.ink,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? MfColors.mutedDark : MfColors.muted,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: isDark ? MfColors.mutedDark : MfColors.muted,
        ),
      ),
    );
  }
}

class MfToggleRow extends StatelessWidget {
  const MfToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? MfColors.mutedDark : MfColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeTrackColor: MfColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class MfRadioRow extends StatelessWidget {
  const MfRadioRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedLine = isDark ? MfColors.lineDark : MfColors.line;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? MfColors.primary : unselectedLine,
            ),
          ],
        ),
      ),
    );
  }
}

class MfChecklistRow extends StatelessWidget {
  const MfChecklistRow({
    super.key,
    required this.label,
    required this.done,
    this.onTap,
  });

  final String label;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doneColor = isDark ? Colors.white : MfColors.ink;
    final undoneColor = isDark ? MfColors.mutedDark : MfColors.muted;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: done
                  ? MfColors.primary
                  : (isDark ? MfColors.lineDark : const Color(0xFFD1D5DB)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: done ? doneColor : undoneColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? MfColors.mutedDark : MfColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class MfSettingsRow extends StatelessWidget {
  const MfSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark
                    ? MfColors.surfaceDarkElevated
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isDark ? MfColors.primarySoft : MfColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isDark ? MfColors.mutedDark : MfColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.edit_outlined,
                  color: isDark ? MfColors.mutedDark : MfColors.muted,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}

class MfBalanceCard extends StatelessWidget {
  const MfBalanceCard({
    super.key,
    required this.title,
    required this.balance,
    required this.incomeLabel,
    required this.incomeValue,
    required this.spendLabel,
    required this.spendValue,
    this.dark = false,
  });

  final String title;
  final String balance;
  final String incomeLabel;
  final String incomeValue;
  final String spendLabel;
  final String spendValue;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = dark
        ? const [MfColors.primaryDark, Color(0xFF0F1B3D)]
        : const [MfColors.primary, MfColors.primarySoft];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _metric(incomeLabel, incomeValue),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white24,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _metric(spendLabel, spendValue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Future<void> showMfSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  String actionLabel = 'Done',
  Widget? customIcon,
  VoidCallback? onDone,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? MfColors.surfaceDarkElevated
                      : const Color(0xFFE3EDFF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? MfColors.primarySoft.withValues(alpha: 0.35)
                        : const Color(0xFFBFD5FF),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: customIcon ?? const MfWorkerRatingManIcon(size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? MfColors.mutedDark : MfColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              MfPrimaryButton(
                label: actionLabel,
                onPressed: () {
                  Navigator.of(context).pop();
                  onDone?.call();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
    this.onDark = false,
  }) : assert(icon != null || customIcon != null);

  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final bgColor = onDark
        ? Colors.white.withValues(alpha: 0.16)
        : isDarkTheme
            ? MfColors.surfaceDarkElevated
            : const Color(0xFFEEF2FF);

    final fgColor = onDark
        ? Colors.white
        : isDarkTheme
            ? MfColors.primarySoft
            : MfColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customIcon ??
              Icon(
                icon,
                size: 15,
                color: fgColor,
              ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


