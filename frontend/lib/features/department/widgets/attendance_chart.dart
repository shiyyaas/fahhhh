import 'package:flutter/material.dart';

//Design
import 'package:fahhhh/core/theme_data/app_colors.dart';

/// Attendance chart card: "Average Attendance : 80%" header, a 1w / 1m / All
/// filter pill and a weekly line graph with Sun..Sat / 10..40 axis values.
class AttendanceChart extends StatelessWidget {
  const AttendanceChart({super.key});

  static const List<double> _weeklyValues = [72, 76, 74, 80, 83, 78, 85];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 212,
      margin: const EdgeInsets.symmetric(horizontal: 26),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
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
          Row(
            children: [
              _gradientText('Average Attendance :'),
              const SizedBox(width: 6),
              _gradientText('80%', fontWeight: FontWeight.bold),
              const Spacer(),
              const _FilterPill(),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: _LineChartPainter(values: _weeklyValues),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _gradientText(String text, {FontWeight fontWeight = FontWeight.w400}) {
  return ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.black, Color(0xFF666666)],
    ).createShader(bounds),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.8,
        fontWeight: fontWeight,
        color: Colors.white,
      ),
    ),
  );
}

class _FilterPill extends StatefulWidget {
  const _FilterPill();

  @override
  State<_FilterPill> createState() => _FilterPillState();
}

class _FilterPillState extends State<_FilterPill> {
  final List<String> _options = ['1w', '1m', 'All'];
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_options.length, (index) {
          final bool isSelected = index == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = index),
            child: Container(
              width: 25,
              height: 15,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFC7C7C7) : Colors.transparent,
                border: isSelected
                    ? Border.all(color: const Color(0xFF7C7C7C), width: 0.5)
                    : null,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: _gradientText(_options[index], fontWeight: FontWeight.w500),
            ),
          );
        }),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;

  _LineChartPainter({required this.values});

  static const List<String> _xLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const List<String> _yLabels = ['40', '30', '20', '10'];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i < _yLabels.length; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    const labelStyle = TextStyle(fontSize: 9.8, color: Color(0xFFA3A3A3));

    // Y axis values (right aligned to the left edge)
    for (int i = 0; i < _yLabels.length; i++) {
      final tp = _textPainter(_yLabels[i], labelStyle);
      tp.paint(
        canvas,
        Offset(
          2,
          size.height * i / 3 - tp.height / 2,
        ),
      );
    }

    // X axis values (centered under each day)
    for (int i = 0; i < values.length; i++) {
      final x = _xPosition(i, size.width);
      final tp = _textPainter(_xLabels[i], labelStyle);
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - tp.height));
    }

    // Line chart clipped to the plot area
    final plotTop = 0.0;
    final plotBottom = size.height - 12;

    // Area fill under the line
    final path = Path();
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.primary;

    for (int i = 0; i < values.length; i++) {
      final x = _xPosition(i, size.width);
      final y = _yPosition(values[i], plotTop, plotBottom);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Dots on each data point
    final dotPaint = Paint()..color = AppColors.primary;
    for (int i = 0; i < values.length; i++) {
      final x = _xPosition(i, size.width);
      final y = _yPosition(values[i], plotTop, plotBottom);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  double _xPosition(int index, double width) {
    return width * index / (values.length - 1);
  }

  double _yPosition(double value, double top, double bottom) {
    final range = bottom - top;
    return bottom - (value / 100) * range;
  }

  TextPainter _textPainter(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp;
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

