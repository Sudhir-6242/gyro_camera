import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CustomWidget extends StatefulWidget {
  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  // List<double>? accelerometer;

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    // final gyroscope =
    //     _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    // final userAccelerometer = _userAccelerometerValues
    //     ?.map((double v) => v.toStringAsFixed(1))
    //     .toList();

    return Container(
      width: 393,
      height: 393,
      child: CustomPaint(
        painter: MyPainter(
          double.parse(accelerometer![0]),
          double.parse(accelerometer[1]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  double x1;
  double y1;
  MyPainter(
    this.x1,
    this.y1,
  );
  //         <-- CustomPainter class
  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.polygon;
    final points = [
      // Offset(0, -x1 * 4 + 0),
      // Offset(300, x1 * 4 + 0),
      // Offset(300, -x1 * 4 + 300),
      // Offset(0, x1 * 4 + 300),
      // Offset(0, -x1 * 4 + 0),

      Offset(0, x1.isNegative ? 0 : -x1 * 10 + 0),
      Offset(393, x1.isNegative ? x1 * 10 + 0 : 0),
      Offset(393, x1.isNegative ? -x1 * 10 + 393 : 393),
      Offset(0, x1.isNegative ? 393 : x1 * 10 + 393),
      Offset(0, x1.isNegative ? 0 : -x1 * 10 + 0),
      // Offset(0, x1.isNegative ? -x1 * 4 + 0 : 0),
      // Offset(300, x1.isNegative ? 0 : x1 * 4 + 0),
      // Offset(300, x1.isNegative ? 300 : -x1 * 4 + 300),
      // Offset(0, x1.isNegative ? x1 * 4 + 300 : 300),
      // Offset(0, x1.isNegative ? -x1 * 4 + 0 : 0),
    ];

    final paint = Paint()
      ..color = Color(0xff2783B4)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;

    canvas.drawPoints(pointMode, points, paint);
    // <-- Insert your painting code here.
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
