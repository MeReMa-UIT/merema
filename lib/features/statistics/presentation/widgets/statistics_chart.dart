import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class StatisticsChart extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final double height;
  final Function(Map<String, dynamic>)? onPointTap;
  final bool showLabelsOnXAxis;
  final String? xAxisKey;
  final String? timeUnit;

  const StatisticsChart({
    super.key,
    required this.title,
    required this.data,
    this.height = 300,
    this.onPointTap,
    this.showLabelsOnXAxis = false,
    this.xAxisKey,
    this.timeUnit,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyChart();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: AppPallete.darkGrayColor,
              ),
              SizedBox(height: 8),
              Text(
                'No data available',
                style: TextStyle(
                  color: AppPallete.darkGrayColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final nonZeroData = data.where((point) => (point['y'] as num) > 0).toList();

    if (nonZeroData.isEmpty) {
      return _buildEmptyChart();
    }

    final maxY = nonZeroData.fold<double>(
      0,
      (max, point) => (point['y'] as num).toDouble() > max
          ? (point['y'] as num).toDouble()
          : max,
    );

    if (maxY == 0) {
      return _buildEmptyChart();
    }

    if (nonZeroData.length > 4) {
      final chartWidth = nonZeroData.length * 120.0;
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: height,
            child: _buildChartPainter(nonZeroData, maxY, Size(chartWidth, height)),
          ),
        ),
      );
    }

    return Center(
      child: _buildChartPainter(nonZeroData, maxY, Size.infinite),
    );
  }

  Widget _buildChartPainter(List<Map<String, dynamic>> chartData, double maxY, Size size) {
    if (onPointTap != null) {
      return GestureDetector(
        onTapDown: (details) => _handleTap(details, chartData, maxY, size),
        child: CustomPaint(
          size: size,
          painter: _ChartPainter(
            data: chartData,
            maxY: maxY,
            showLabelsOnXAxis: showLabelsOnXAxis,
            xAxisKey: xAxisKey,
            timeUnit: timeUnit,
          ),
        ),
      );
    }

    return CustomPaint(
      size: size,
      painter: _ChartPainter(
        data: chartData,
        maxY: maxY,
        showLabelsOnXAxis: showLabelsOnXAxis,
        xAxisKey: xAxisKey,
        timeUnit: timeUnit,
      ),
    );
  }

  void _handleTap(TapDownDetails details, List<Map<String, dynamic>> chartData, double maxY, Size size) {
    final localPosition = details.localPosition;
    const leftMargin = 20.0;
    final actualWidth = size.width == double.infinity ? 300.0 : size.width;
    final chartWidth = actualWidth - leftMargin;
    
    final barWidth = showLabelsOnXAxis
        ? (chartWidth / chartData.length) * 0.6
        : chartWidth / (chartData.length * 1.5);
    
    for (int i = 0; i < chartData.length; i++) {
      final barCenterX = leftMargin + (i + 0.5) * (chartWidth / chartData.length);
      final barLeft = barCenterX - barWidth / 2;
      final barRight = barCenterX + barWidth / 2;
      
      if (localPosition.dx >= barLeft && localPosition.dx <= barRight) {
        onPointTap!(chartData[i]);
        return;
      }
    }
  }
}

class _ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxY;
  final bool showLabelsOnXAxis;
  final String? xAxisKey;
  final String? timeUnit;

  _ChartPainter({
    required this.data,
    required this.maxY,
    this.showLabelsOnXAxis = false,
    this.xAxisKey,
    this.timeUnit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppPallete.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppPallete.primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = AppPallete.primaryColor
      ..style = PaintingStyle.fill;

    final chartHeight = showLabelsOnXAxis ? size.height - 80 : size.height - 20;
    const leftMargin = 20.0;
    final chartWidth = size.width - leftMargin;

    _drawAxes(canvas, Size(chartWidth, chartHeight), leftMargin);

    final points = <Offset>[];
    final barWidth = showLabelsOnXAxis
        ? (chartWidth / data.length) * 0.6
        : chartWidth / (data.length * 1.5);

    for (int i = 0; i < data.length; i++) {
      final x = leftMargin + (i + 0.5) * (chartWidth / data.length);
      final y = chartHeight -
          ((data[i]['y'] as num).toDouble() / maxY) * (chartHeight * 0.85);
      points.add(Offset(x, y));
    }

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final rect = Rect.fromLTWH(
        point.dx - barWidth / 2,
        point.dy,
        barWidth,
        chartHeight - point.dy,
      );
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, paint..style = PaintingStyle.stroke);
    }

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    _drawValueLabels(canvas, points, chartHeight);

    if (showLabelsOnXAxis && xAxisKey != null) {
      _drawXAxisLabels(canvas, Size(size.width, chartHeight), leftMargin);
    }

    if (!showLabelsOnXAxis && points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint..strokeWidth = 2);
    }
  }

  void _drawValueLabels(
      Canvas canvas, List<Offset> points, double chartHeight) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final value = (data[i]['y'] as num).toString();

      textPainter.text = TextSpan(
        text: value,
        style: const TextStyle(
          color: AppPallete.textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, point.dy - 20),
      );
    }
  }

  void _drawXAxisLabels(Canvas canvas, Size size, double leftMargin) {
    if (xAxisKey == null) return;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < data.length; i++) {
      final x =
          leftMargin + (i + 0.5) * ((size.width - leftMargin) / data.length);
      final label = _formatAxisLabel(data[i][xAxisKey].toString());

      canvas.save();
      canvas.translate(x, size.height + 10);
      canvas.rotate(-0.524);

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: AppPallete.darkGrayColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));

      canvas.restore();
    }
  }

  String _formatAxisLabel(String label) {
    if (timeUnit == null) return label;

    try {
      final dateTime = DateTime.parse(label);

      switch (timeUnit) {
        case 'week':
        case 'month':
          return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
        case 'year':
          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];
          return months[dateTime.month - 1];
        default:
          return label;
      }
    } catch (e) {
      return label;
    }
  }

  void _drawAxes(Canvas canvas, Size size, double leftMargin) {
    final axisPaint = Paint()
      ..color = AppPallete.darkGrayColor
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(leftMargin, size.height),
      Offset(size.width + leftMargin, size.height),
      axisPaint,
    );

    final gridPaint = Paint()
      ..color = AppPallete.darkGrayColor.withOpacity(0.1)
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 5; i++) {
      final y = size.height * (i / 6);
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width + leftMargin, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
