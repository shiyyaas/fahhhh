import 'package:fahhhh/core/theme_data/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Compact search pill + "Sort by" dropdown row used on department screens.
class SearchSortBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onQueryChanged;

  const SearchSortBar({super.key, this.controller, this.onQueryChanged});

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
                child: SearchField(
                  controller: controller,
                  onChanged: onQueryChanged,
                ),
              ),
              const SizedBox(width: 10),
              const SortDropdown(),
            ],
          ),
        ],
      ),
    );
  }
}

/// White pill search field matching the design's search bar.
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchField({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 3.6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: const Color(0xFF373737),
        style: AppTextStyles.sfPRO.copyWith(
          fontSize: 13.5,
          color: const Color(0xFF373737),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: Color(0xFF373737),
          ),
          hintText: 'Search',
          hintStyle: AppTextStyles.sfPRO.copyWith(
            fontSize: 13.5,
            color: const Color(0xFF373737),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

/// White pill "Sort by" dropdown matching the design.
class SortDropdown extends StatefulWidget {
  const SortDropdown({super.key});

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  final OverlayPortalController _controller = OverlayPortalController();
  final _link = LayerLink();
  String _selectedOption = 'Sort by';
  final List<String> _options = ['Roll No', 'Highest', 'Lowest'];

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 4),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 115,
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
                  children: _options.map((option) {
                    final isFirst = option == _options.first;
                    final isLast = option == _options.last;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedOption = option;
                        });
                        _controller.toggle();
                      },
                      child: Container(
                        height: 26,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: isLast ? null : const Border(bottom: BorderSide(color: Colors.black, width: 0.3)),
                          borderRadius: BorderRadius.vertical(
                            top: isFirst ? const Radius.circular(16) : Radius.zero,
                            bottom: isLast ? const Radius.circular(16) : Radius.zero,
                          ),
                        ),
                        child: Text(
                          option,
                          style: AppTextStyles.sfPRO.copyWith(
                            fontSize: 12.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
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
          onTap: _controller.toggle,
          child: Container(
            height: 27,
            width: 115,
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
                    _selectedOption,
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
}
