import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Design system
import 'package:fahhhh/core/theme_data/app_colors.dart';

/// Attendance chart matching Figma node 2180:18428.
///
/// Features:
/// - Exact Figma layout: 350x212 card, top header with "Average Attendance : XX%",
///   horizontal box divider line, and 1w / 1m / All filter pill.
/// - Smooth cubic spline curve passing through 7 days (Sun..Sat) with vertical & horizontal grid lines.
/// - Fluid entrance animation and smooth morphing animation when switching filters.
/// - Interactive touch scrubbing / tap tooltip showing day and percentage.
class AttendanceChart extends StatefulWidget {
  final int initialFilterIndex;
  final ValueChanged<int>? onFilterChanged;
  final Map<int, List<double>>? customData;
  final Map<int, int>? customAverages;
  final double height;
  final EdgeInsetsGeometry? margin;

  const AttendanceChart({
    super.key,
    this.initialFilterIndex = 1, // Default to 1m (Figma design)
    this.onFilterChanged,
    this.customData,
    this.customAverages,
    this.height = 212,
    this.margin,
  });

  // Default data sets calibrated to the 10..40 scale shown on the Figma Y-axis
  // 1m values produce the exact twin-peak curve seen in the Figma screenshot
  static const Map<int, List<double>> defaultData = {
    0: [24.0, 32.0, 28.0, 36.0, 38.0, 30.0, 34.0], // 1w
    1: [18.0, 34.0, 21.0, 15.0, 34.0, 22.0, 25.5], // 1m (Figma default)
    2: [22.0, 29.0, 31.0, 26.0, 33.0, 28.0, 31.5], // All
  };

  static const Map<int, int> defaultAverages = {
    0: 84, // 1w
    1: 80, // 1m (Figma design)
    2: 78, // All
  };

  @override
  State<AttendanceChart> createState() => _AttendanceChartState();
}

class _AttendanceChartState extends State<AttendanceChart>
    with TickerProviderStateMixin {
  late int _selectedFilter;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;

  late AnimationController _morphController;
  late Animation<double> _morphAnimation;

  late List<double> _previousValues;
  late List<double> _currentValues;
  late List<double> _targetValues;

  late int _previousAverage;
  late int _targetAverage;

  int? _activeTouchIndex;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilterIndex;

    final initialList = _getDataForFilter(_selectedFilter);
    _previousValues = List<double>.from(initialList);
    _currentValues = List<double>.from(initialList);
    _targetValues = List<double>.from(initialList);

    final avg = _getAverageForFilter(_selectedFilter);
    _previousAverage = avg;
    _targetAverage = avg;

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    )..addListener(() {
        setState(() {
          final t = _morphAnimation.value;
          for (int i = 0; i < _currentValues.length; i++) {
            _currentValues[i] = ui.lerpDouble(
                  _previousValues[i],
                  _targetValues[i],
                  t,
                ) ??
                _targetValues[i];
          }
        });
      });

    _revealController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  List<double> _getDataForFilter(int filterIndex) {
    if (widget.customData != null &&
        widget.customData!.containsKey(filterIndex)) {
      return widget.customData![filterIndex]!;
    }
    return AttendanceChart.defaultData[filterIndex] ??
        AttendanceChart.defaultData[1]!;
  }

  int _getAverageForFilter(int filterIndex) {
    if (widget.customAverages != null &&
        widget.customAverages!.containsKey(filterIndex)) {
      return widget.customAverages![filterIndex]!;
    }
    return AttendanceChart.defaultAverages[filterIndex] ?? 80;
  }

  void _onSelectFilter(int index) {
    if (_selectedFilter == index) return;

    final newTarget = _getDataForFilter(index);
    final newAvg = _getAverageForFilter(index);

    setState(() {
      _selectedFilter = index;
      _previousValues = List<double>.from(_currentValues);
      _targetValues = List<double>.from(newTarget);
      _previousAverage = _displayedAverage;
      _targetAverage = newAvg;
      _activeTouchIndex = null;
    });

    widget.onFilterChanged?.call(index);
    _morphController.forward(from: 0.0);
  }

  int get _displayedAverage {
    if (!_morphController.isAnimating) {
      return _targetAverage;
    }
    final t = _morphAnimation.value;
    return (_previousAverage + (_targetAverage - _previousAverage) * t).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row (Average Attendance + Filter)
          SizedBox(
            height: 31.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _gradientText('Average Attendance :'),
                  const SizedBox(width: 5),
                  _gradientText(
                    '$_displayedAverage%',
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  _FilterPill(
                    selectedIndex: _selectedFilter,
                    onSelected: _onSelectFilter,
                  ),
                ],
              ),
            ),
          ),

          // Box horizontal divider line
          Container(
            height: 1,
            color: Colors.black,
          ),

          // Chart Plot Area
          Expanded(
            child: AnimatedBuilder(
              animation: _revealAnimation,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final chartSize = Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onTapDown: (details) =>
                          _handleTouch(details.localPosition, chartSize),
                      onHorizontalDragUpdate: (details) =>
                          _handleTouch(details.localPosition, chartSize),
                      onTapUp: (_) => _clearTouchWithDelay(),
                      onHorizontalDragEnd: (_) => _clearTouchWithDelay(),
                      child: CustomPaint(
                        size: chartSize,
                        painter: _AttendanceSplineChartPainter(
                          values: _currentValues,
                          revealProgress: _revealAnimation.value,
                          activeIndex: _activeTouchIndex,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset localPos, Size size) {
    // Chart plot geometry constants
    const plotLeft = 24.0;
    final plotRight = size.width - 12.0;
    final plotWidth = plotRight - plotLeft;

    if (localPos.dx < plotLeft - 10 || localPos.dx > plotRight + 10) {
      setState(() => _activeTouchIndex = null);
      return;
    }

    final double step = plotWidth / (_currentValues.length - 1);
    final double relativeX = (localPos.dx - plotLeft).clamp(0.0, plotWidth);
    final int nearestIndex = (relativeX / step).round().clamp(0, _currentValues.length - 1);

    setState(() {
      _activeTouchIndex = nearestIndex;
    });
  }

  void _clearTouchWithDelay() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _activeTouchIndex != null) {
        setState(() => _activeTouchIndex = null);
      }
    });
  }
}

/// Gradient text shader matching Figma's gradient fill
Widget _gradientText(String text, {FontWeight fontWeight = FontWeight.w400}) {
  return ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.black, AppColors.textSecondary],
    ).createShader(bounds),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12.8,
        fontWeight: fontWeight,
        color: Colors.white,
      ),
    ),
  );
}

/// Filter pill: 1w | 1m | All
class _FilterPill extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FilterPill({
    required this.selectedIndex,
    required this.onSelected,
  });

  static const List<String> _options = ['1w', '1m', 'All'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_options.length, (index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 25,
              height: 15,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC7C7C7) : Colors.transparent,
                border: isSelected
                    ? Border.all(color: const Color(0xFF7C7C7C), width: 0.5)
                    : null,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: _gradientFilterText(
                _options[index],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _gradientFilterText(String text, {FontWeight fontWeight = FontWeight.w400}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, AppColors.textSecondary],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11.5,
          fontWeight: fontWeight,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}

/// Custom painter rendering the chart grid, smooth spline curve, volumetric
/// area gradient, and active interactive tooltip.
class _AttendanceSplineChartPainter extends CustomPainter {
  final List<double> values;
  final double revealProgress;
  final int? activeIndex;

  _AttendanceSplineChartPainter({
    required this.values,
    required this.revealProgress,
    this.activeIndex,
  });

  static const List<String> _xLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  static const List<String> _yLabels = ['40', '30', '20', '10'];

  static const double _minValue = 10.0;
  static const double _maxValue = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // Layout metrics
    const double plotLeft = 24.0;
    final double plotRight = size.width - 12.0;
    const double plotTop = 16.0;
    final double plotBottom = size.height - 24.0;
    final double plotWidth = plotRight - plotLeft;
    final double plotHeight = plotBottom - plotTop;

    final gridPaint = Paint()
      ..color = const Color(0xFFE6E6E6)
      ..strokeWidth = 0.98;

    final yLabelStyle = GoogleFonts.inter(
      fontSize: 9.8,
      color: const Color(0xFFA3A3A3),
      fontWeight: FontWeight.normal,
    );

    // 1. Draw Horizontal Grid Lines and Y-Axis Labels (40, 30, 20, 10)
    for (int i = 0; i < _yLabels.length; i++) {
      final double y = plotTop + (plotHeight * i / (_yLabels.length - 1));

      // Horizontal grid line across the plot
      canvas.drawLine(
        Offset(plotLeft, y),
        Offset(plotRight, y),
        gridPaint,
      );

      // Y-axis label (aligned left)
      final tp = _textPainter(_yLabels[i], yLabelStyle);
      tp.paint(
        canvas,
        Offset(plotLeft - tp.width - 4, y - tp.height / 2),
      );
    }

    // 2. Draw Vertical Grid Lines & X-Axis Labels (Sun..Sat)
    final double xStep = plotWidth / (values.length - 1);
    for (int i = 0; i < values.length; i++) {
      final double x = plotLeft + i * xStep;

      // Vertical grid line
      canvas.drawLine(
        Offset(x, plotTop),
        Offset(x, plotBottom),
        gridPaint,
      );

      // X-axis day label (centered under vertical line)
      if (i < _xLabels.length) {
        final tp = _textPainter(_xLabels[i], yLabelStyle);
        tp.paint(
          canvas,
          Offset(x - tp.width / 2, plotBottom + 6),
        );
      }
    }

    // 3. Compute Points for the Spline
    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = plotLeft + i * xStep;
      // Animate entry from baseline up to value
      final double animatedVal = _minValue + (values[i] - _minValue) * revealProgress;
      final double y = _yForValue(animatedVal, plotTop, plotBottom);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // 4. Construct Smooth Catmull-Rom Cubic Spline Path
    final Path splinePath = _buildSplinePath(points);

    // 5. Construct Area Path for Gradient Fill
    final Path areaPath = Path.from(splinePath)
      ..lineTo(points.last.dx, plotBottom)
      ..lineTo(points.first.dx, plotBottom)
      ..close();

    // Soft blur shadow glow pass beneath the curve (matching Figma's gaussian blur filter)
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2E6EFD).withValues(alpha: 0.22 * revealProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawPath(areaPath, glowPaint);

    // Vertical gradient fill
    final areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2E6EFD).withValues(alpha: 0.60 * revealProgress),
          AppColors.gradientTop.withValues(alpha: 0.40 * revealProgress),
          AppColors.gradientBottom.withValues(alpha: 0.15 * revealProgress),
          AppColors.gradientBottom.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(plotLeft, plotTop, plotWidth, plotHeight));
    canvas.drawPath(areaPath, areaPaint);

    // 6. Draw Stroke along the Spline Curve with Gradient
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.96
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gradientTop,
          AppColors.gradientBottom,
        ],
      ).createShader(Rect.fromLTWH(plotLeft, plotTop, plotWidth, plotHeight));

    canvas.drawPath(splinePath, strokePaint);

    // 7. Interactive Touch / Scrub Indicator and Tooltip
    if (activeIndex != null && activeIndex! >= 0 && activeIndex! < points.length) {
      _drawTouchIndicator(
        canvas,
        points[activeIndex!],
        plotTop,
        plotBottom,
        _xLabels[activeIndex!],
        values[activeIndex!],
      );
    }
  }

  /// Converts a data value on [10..40] scale into Y canvas coordinate
  double _yForValue(double val, double plotTop, double plotBottom) {
    final double clamped = val.clamp(_minValue, _maxValue);
    final double ratio = (clamped - _minValue) / (_maxValue - _minValue);
    return plotBottom - (ratio * (plotBottom - plotTop));
  }

  /// Builds a smooth Catmull-Rom spline converting tangents into Cubic Bezier curves
  Path _buildSplinePath(List<Offset> pts) {
    final Path path = Path();
    if (pts.isEmpty) return path;

    path.moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 1) return path;

    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i < pts.length - 2 ? pts[i + 2] : p2;

      // Catmull-Rom tangent calculation
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 5.5,
        p1.dy + (p2.dy - p0.dy) / 5.5,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 5.5,
        p2.dy - (p3.dy - p1.dy) / 5.5,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    return path;
  }

  /// Draws active vertical guideline, dot, and floating tooltip badge
  void _drawTouchIndicator(
    Canvas canvas,
    Offset point,
    double plotTop,
    double plotBottom,
    String dayLabel,
    double value,
  ) {
    // 1. Subtle vertical dashed indicator line
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    double curY = plotTop;
    const dashHeight = 4.0;
    const dashGap = 3.0;
    while (curY < plotBottom) {
      canvas.drawLine(
        Offset(point.dx, curY),
        Offset(point.dx, (curY + dashHeight).clamp(plotTop, plotBottom)),
        linePaint,
      );
      curY += dashHeight + dashGap;
    }

    // 2. Active point circle (white ring + primary blue center)
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(point, 5.0, ringPaint);
    canvas.drawCircle(point, 3.5, dotPaint);

    // 3. Compact tooltip badge
    final tooltipText = '$dayLabel: ${value.toStringAsFixed(1)}';
    final textPainter = _textPainter(
      tooltipText,
      GoogleFonts.inter(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );

    const horizontalPadding = 6.0;
    const verticalPadding = 3.0;
    final badgeWidth = textPainter.width + horizontalPadding * 2;
    final badgeHeight = textPainter.height + verticalPadding * 2;

    // Position badge above the point (or below if too close to top)
    double badgeY = point.dy - badgeHeight - 8;
    if (badgeY < plotTop - 4) {
      badgeY = point.dy + 8;
    }
    final double badgeX = (point.dx - badgeWidth / 2).clamp(24.0, 320.0);

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, badgeWidth, badgeHeight),
      const Radius.circular(4),
    );

    final badgeBgPaint = Paint()
      ..color = AppColors.navBar
      ..style = PaintingStyle.fill;
    canvas.drawRRect(badgeRect, badgeBgPaint);

    textPainter.paint(
      canvas,
      Offset(badgeX + horizontalPadding, badgeY + verticalPadding),
    );
  }

  TextPainter _textPainter(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp;
  }

  @override
  bool shouldRepaint(covariant _AttendanceSplineChartPainter oldDelegate) {
    return oldDelegate.revealProgress != revealProgress ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.values != values;
  }
}
