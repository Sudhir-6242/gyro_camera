import 'dart:io';

import 'package:custom_camera_app/main.dart';
// import 'package:custom_camera_app/screen/widget/custom_widget.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:sensors_plus/sensors_plus.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isCameraStarted = false;
  File? imageFile;
  bool showev = false;
  bool showzoom = false;
  double maxzoom = 1.0;
  double minzoom = 1.0;
  double currentZoom = 1.0;
  double minev = 1.0;
  double maxev = 1.0;
  double currentev = 1.0;
  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  // List<double>? accelerometer;

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  Future<void> onSelectedCamera(CameraDescription cameraDescription) async {
    final previousController = controller;
    final CameraController newControlller = CameraController(
        cameraDescription, ResolutionPreset.ultraHigh,
        imageFormatGroup: ImageFormatGroup.jpeg);
    await previousController?.dispose();
    if (mounted) {
      setState(() {
        controller = newControlller;
      });
    }
    newControlller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    try {
      await newControlller.initialize();
    } on CameraException catch (e) {
      print('cannot open camera');
    }
    newControlller.getMinZoomLevel().then((value) => minzoom = value);
    newControlller.getMaxZoomLevel().then((value) => maxzoom = value);
    newControlller.getMinExposureOffset().then((value) => minev = value);
    newControlller.getMaxExposureOffset().then((value) => maxev = value);
    if (mounted) {
      setState(() {
        isCameraStarted = controller!.value.isInitialized;
      });
    }
  }

  Future<XFile?> click() async {
    final CameraController? newCameracontroller = controller;
    if (newCameracontroller!.value.isTakingPicture) {
      return null;
    }
    try {
      XFile picture = await newCameracontroller.takePicture();
      print('clicked');
      return picture;
    } on CameraException catch (e) {
      print('can\'t capture picture');
    }
  }

  @override
  void initState() {
    super.initState();
    onSelectedCamera(cameras[1]);
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

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    return Scaffold(
      body: isCameraStarted
          ? Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1 / controller!.value.aspectRatio,
                  child: Stack(
                      // fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        controller!.buildPreview(),
                        Container(
                          width: 393,
                          height: 393,
                          child: CustomPaint(
                            painter: MyPainter(
                              double.parse(accelerometer![0]),
                              double.parse(accelerometer[1]),
                            ),
                          ),
                        )
                      ]),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        showzoom
                            ? Slider(
                                value: currentZoom,
                                min: minzoom,
                                max: maxzoom,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    currentZoom = value;
                                    print(currentZoom);
                                  });
                                  await controller?.setZoomLevel(value);
                                },
                              )
                            : Container(),
                        showev
                            ? Slider(
                                value: currentev,
                                min: minev,
                                max: maxev,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    currentev = value;
                                    print(currentev);
                                  });
                                  await controller?.setExposureOffset(value);
                                },
                              )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    showzoom = !showzoom;
                                    showev = false;
                                  });
                                },
                                child: Text(
                                  'Zoom',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    showev = !showev;
                                    showzoom = false;
                                  });
                                },
                                child: Text(
                                  'EV',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                            ),
                            InkWell(
                                onTap: () async {
                                  XFile? rawImage = await click();
                                  imageFile = File(rawImage!.path);
                                  int currentUnix =
                                      DateTime.now().millisecondsSinceEpoch;
                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  String fileFormat =
                                      imageFile!.path.split('.').last;
                                  await imageFile!.copy(
                                    '${directory.path}/$currentUnix.$fileFormat',
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Icon(
                                    Icons.circle_outlined,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                )),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10.0),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                image: imageFile != null
                                    ? DecorationImage(
                                        image: FileImage(imageFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            )
                          ],
                        ),
                      ]),
                )
              ],
            )
          : Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
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
