import 'package:flutter/material.dart';
import '../../theme_data/app_text_styles.dart';

/// Functional design categories for dropdown components across the application.
enum AppDropdownVariant {
  /// Standard form input selection (e.g. assigned subject/class in dialogs).
  formInput,

  /// Contextual menu for sorting or switching views (e.g. Sort by, filter options).
  filter,

  /// Context-sensitive action menu popover (e.g. More actions, context options).
  actionMenu,
}

/// Item configuration for [AppDropdown].
class AppDropdownItem<T> {
  final T value;
  final String label;
  final Widget? icon;
  final bool isDestructive;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
  });
}

/// Consolidated, standardized base dropdown widget following the design system.
class AppDropdown<T> extends StatefulWidget {
  final AppDropdownVariant variant;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;

  // Customization & Form Input fields
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  // Custom trigger child for actionMenu variant
  final Widget? child;

  // Styling properties
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;

  const AppDropdown({
    super.key,
    required this.variant,
    required this.items,
    this.value,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.child,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  /// Factory constructor for Navigation/Filter dropdown variant (pill style).
  factory AppDropdown.filter({
    Key? key,
    T? value,
    required List<AppDropdownItem<T>> items,
    ValueChanged<T?>? onChanged,
    String? hintText,
    double? width = 115,
    double height = 27,
  }) {
    return AppDropdown<T>(
      key: key,
      variant: AppDropdownVariant.filter,
      value: value,
      items: items,
      onChanged: onChanged,
      hintText: hintText,
      width: width,
      height: height,
    );
  }

  /// Factory constructor for Form Input dropdown variant.
  factory AppDropdown.formInput({
    Key? key,
    T? value,
    required List<AppDropdownItem<T>> items,
    required ValueChanged<T?>? onChanged,
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    String? Function(T?)? validator,
  }) {
    return AppDropdown<T>(
      key: key,
      variant: AppDropdownVariant.formInput,
      value: value,
      items: items,
      onChanged: onChanged,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      validator: validator,
    );
  }

  /// Factory constructor for Action Menu popover variant.
  factory AppDropdown.actionMenu({
    Key? key,
    required List<AppDropdownItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required Widget child,
  }) {
    return AppDropdown<T>(
      key: key,
      variant: AppDropdownVariant.actionMenu,
      items: items,
      onChanged: onChanged,
      child: child,
    );
  }

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case AppDropdownVariant.formInput:
        return _buildFormInput(context);
      case AppDropdownVariant.filter:
        return _buildFilter(context);
      case AppDropdownVariant.actionMenu:
        return _buildActionMenu(context);
    }
  }

  Widget _buildFormInput(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: Color(0xFF635959),
      ),
      style: AppTextStyles.sfPRO.copyWith(
        fontSize: 14,
        color: const Color(0xFF373737),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelText: widget.labelText,
        hintText: widget.hintText,
        labelStyle: AppTextStyles.sfPRO.copyWith(
          fontSize: 14,
          color: const Color(0xFF635959),
        ),
        hintStyle: AppTextStyles.sfPRO.copyWith(
          fontSize: 14,
          color: const Color(0xFF8E8E93),
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20, color: const Color(0xFF136BB3))
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF136BB3),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFBA4545),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFBA4545),
            width: 1.5,
          ),
        ),
      ),
      items: widget.items.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                item.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                item.label,
                style: AppTextStyles.sfPRO.copyWith(
                  fontSize: 14,
                  color: item.isDestructive ? Colors.red : const Color(0xFF373737),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: widget.onChanged,
    );
  }

  Widget _buildFilter(BuildContext context) {
    final selectedItem = widget.items.cast<AppDropdownItem<T>?>().firstWhere(
          (item) => item?.value == widget.value,
          orElse: () => null,
        );
    final displayLabel = selectedItem?.label ?? widget.hintText ?? 'Sort by';

    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 4),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: widget.width ?? 115,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black, width: 0.3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isFirst = index == 0;
                    final isLast = index == widget.items.length - 1;

                    return GestureDetector(
                      onTap: () {
                        widget.onChanged?.call(item.value);
                        _overlayController.toggle();
                      },
                      child: Container(
                        height: 28,
                        width: double.infinity,
                        alignment: widget.alignment,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                    color: Colors.black,
                                    width: 0.3,
                                  ),
                                ),
                          borderRadius: BorderRadius.vertical(
                            top: isFirst ? const Radius.circular(16) : Radius.zero,
                            bottom: isLast ? const Radius.circular(16) : Radius.zero,
                          ),
                        ),
                        child: Text(
                          item.label,
                          style: AppTextStyles.sfPRO.copyWith(
                            fontSize: 12.5,
                            color: item.isDestructive ? Colors.red : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
        child: GestureDetector(
          onTap: _overlayController.toggle,
          child: Container(
            height: widget.height ?? 27,
            width: widget.width ?? 115,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2292),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 3.1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    displayLabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sfPRO.copyWith(
                      fontSize: 15.6,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: PopupMenuButton<T>(
        offset: const Offset(0, 42),
        padding: EdgeInsets.zero,
        onSelected: (val) => widget.onChanged?.call(val),
        itemBuilder: (context) {
          final List<PopupMenuEntry<T>> entries = [];
          for (int i = 0; i < widget.items.length; i++) {
            if (i > 0) {
              entries.add(const PopupMenuDivider(height: 1));
            }
            final item = widget.items[i];
            entries.add(
              PopupMenuItem<T>(
                value: item.value,
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.icon != null) ...[
                        item.icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: item.isDestructive
                              ? Colors.red
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return entries;
        },
        child: widget.child,
      ),
    );
  }
}
