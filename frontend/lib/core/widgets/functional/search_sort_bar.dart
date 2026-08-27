import 'package:fahhhh/core/widgets/ui/app_dropdown.dart';
import 'package:fahhhh/core/widgets/ui/global_search_bar_widget.dart';
import 'package:flutter/material.dart';

/// Compact search pill + "Sort by" dropdown row used on department screens.
class SearchSortBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<String>? onSortChanged;
  final String? initialSort;

  const SearchSortBar({
    super.key,
    this.controller,
    this.onQueryChanged,
    this.onSortChanged,
    this.initialSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GlobalSearchBarWidget(
                  controller: controller,
                  onChanged: onQueryChanged,
                  height: 27,
                ),
              ),
              const SizedBox(width: 10),
              SortDropdown(
                onChanged: onSortChanged,
                initialSort: initialSort,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Deprecated: legacy SearchField replaced by GlobalSearchBarWidget.
typedef SearchField = GlobalSearchBarWidget;

/// White pill "Sort by" dropdown matching the design.
class SortDropdown extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String? initialSort;
  final List<String>? options;

  const SortDropdown({
    super.key,
    this.onChanged,
    this.initialSort,
    this.options,
  });

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  late String _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialSort ?? 'Sort by';
  }

  @override
  void didUpdateWidget(SortDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSort != null && widget.initialSort != _selectedOption) {
      _selectedOption = widget.initialSort!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options ?? ['Roll No', 'Highest', 'Lowest'];
    return AppDropdown<String>.filter(
      value: options.contains(_selectedOption) ? _selectedOption : null,
      hintText: _selectedOption,
      items: options.map((opt) => AppDropdownItem<String>(value: opt, label: opt)).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedOption = val;
          });
          widget.onChanged?.call(val);
        }
      },
    );
  }
}
