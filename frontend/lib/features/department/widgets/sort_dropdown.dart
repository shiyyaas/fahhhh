import 'package:flutter/material.dart';

import '../../../core/theme_data/app_colors.dart';
import '../../../core/theme_data/app_radius.dart';
import '../../../core/theme_data/app_text_styles.dart';

/// White pill dropdown for compact list filtering / sorting.
///
/// Reference design.md §6 ("Dropdowns and controls should support default,
/// hover, pressed, selected, disabled, and error states") and §7
/// ("short feedback transitions around 150–250ms").
///
/// The closed pill shows [value] (falling back to [placeholder]) and the
/// overlay lists [options]. Selection is reported through [onChanged]; the
/// parent may feed the chosen label back via [value] to keep it controlled.
class SortDropdown extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  /// Label rendered on the closed pill. Falls back to [placeholder].
  final String? value;

  /// Label shown when no option is currently selected.
  final String placeholder;

  /// Options rendered in the overlay.
  final List<String> options;

  /// Fixed pill width. Defaults to 120.
  final double width;

  const SortDropdown({
    super.key,
    this.onChanged,
    this.value,
    this.placeholder = 'Sort by',
    this.options = const ['Roll No', 'Highest', 'Lowest'],
    this.width = 120,
  });

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();
  late String _selectedOption;
  bool _isOpen = false;

  String get _label => widget.value ?? widget.placeholder;

  @override
  void initState() {
    super.initState();
    _selectedOption = _label;
  }

  @override
  void didUpdateWidget(covariant SortDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedOption = _label;
    }
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.show();
    } else {
      _controller.hide();
    }
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _controller.hide();
  }

  void _select(String option) {
    setState(() => _selectedOption = option);
    _close();
    widget.onChanged?.call(option);
  }

  @override
  Widget build(BuildContext context) {
    final bool isOpen = _isOpen;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          return Stack(
            children: [
              // Tap-outside barrier so the menu can always be dismissed.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                ),
              ),
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomCenter,
                followerAnchor: Alignment.topCenter,
                offset: const Offset(0, 4),
                child: _OptionsMenu(
                  options: widget.options,
                  selected: _selectedOption,
                  width: widget.width,
                  onSelect: _select,
                ),
              ),
            ],
          );
        },
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 36,
            width: widget.width,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isOpen
                    ? AppColors.primary
                    : AppColors.outline.withValues(alpha: 0.15),
                width: isOpen ? 1.5 : 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sfPRO.copyWith(
                      fontSize: 13.0,
                      color: isOpen ? AppColors.primary : AppColors.headingText,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isOpen ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating option list anchored below the pill.
class _OptionsMenu extends StatelessWidget {
  final List<String> options;
  final String selected;
  final double width;
  final ValueChanged<String> onSelect;

  const _OptionsMenu({
    required this.options,
    required this.selected,
    required this.width,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < options.length; i++)
              _OptionTile(
                label: options[i],
                isSelected: options[i] == selected,
                isLast: i == options.length - 1,
                onTap: () => onSelect(options[i]),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.secondary.withValues(alpha: 0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          height: 36,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: AppColors.outline.withValues(alpha: 0.08),
                    ),
                  ),
          ),
          child: Text(
            label,
            style: AppTextStyles.sfPRO.copyWith(
              fontSize: 12.5,
              color: isSelected ? AppColors.primary : AppColors.headingText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
