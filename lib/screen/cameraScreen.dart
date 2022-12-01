import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:custom_camera_app/main.dart';
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

  // height width for portrait
  double w = 0, h = 0;
  //height width for landscape
  double height = 0, width = 0;
  //axiz for rotation
  double x = 0, y = 0, z = 0;
  // angle for rotation
  double angle1 = 0, angle2 = 0, angle = 0;
  double screenWidth = 0, screenHeight = 0;
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
    onSelectedCamera(cameras[0]);
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        screenHeight = MediaQuery.of(context).size.height;
        screenWidth = MediaQuery.of(context).size.width;
        x = double.parse(event.x.toStringAsFixed(3));
        y = double.parse(event.y.toStringAsFixed(3));

        // angle
        angle1 = double.parse((750 * (x) / (90)).toStringAsFixed(1));
        angle2 = double.parse((750 * (y) / (90)).toStringAsFixed(1));
        //----------------------------------------------------------------------------------------------
        // //dynamic height width 👇
        // //landscape dynamic height👇
        // height = angle2.isNegative
        //     ? screenHeight * 0.70 +
        //         (((screenHeight * 0.70 - (screenHeight * 0.70 * 0.65)) / 82) *
        //             2 *
        //             (angle2))
        //     : screenHeight * 0.70 -
        //         (((screenHeight * 0.70 - (screenHeight * 0.70 * 0.65)) / 82) *
        //             2 *
        //             (angle2));
        // //landscape dynamic width👇
        // width = angle2.isNegative
        //     ? screenWidth * 0.95 +
        //         (((screenWidth * 0.95 - (screenWidth * 0.95 * 0.65)) / 82) *
        //             3 *
        //             (angle2))
        //     : screenWidth * 0.95 -
        //         (((screenWidth * 0.95 - (screenWidth * 0.95 * 0.65)) / 82) *
        //             3 *
        //             (angle2));
        // //portrait dynamic height👇
        // h = angle1.isNegative
        //     ? screenHeight * 0.84 +
        //         (((screenHeight * 0.84 - (screenHeight * 0.84 * 0.52)) / 82) *
        //             (angle1))
        //     : screenHeight * 0.84 -
        //         (((screenHeight * 0.84 - (screenHeight * 0.84 * 0.52)) / 82) *
        //             (angle1));
        // //portrait dynamic width👇
        // w = angle1.isNegative
        //     ? screenWidth * 0.89 +
        //         ((screenWidth * 0.89 - (screenWidth * 0.89 * 0.50) / 82) *
        //             (angle1))
        //     : screenWidth * 0.89 -
        //         ((screenWidth * 0.89 - (screenWidth * 0.89 * 0.50) / 82) *
        //             (angle1));
//----------------------------------------------------------------------------------------------
        //static height width 👇
        //landscape static  height👇
        height = angle2.isNegative
            ? screenHeight + (1 * 5.8 * (angle2))
            : screenHeight - (1 * 5.8 * (angle2));
        //landscape static  width👇
        width = angle2.isNegative
            ? screenWidth * 0.90 + (3.07 * 5.8 * (angle2))
            : screenWidth * 0.90 - (3.07 * 5.8 * (angle2));
        //portrait  static height👇
        h = angle1.isNegative
            ? screenHeight * 0.90 + (4.86 * (angle1))
            : screenHeight * 0.90 - (4.86 * (angle1));
        //portrait  static width👇
        w = angle1.isNegative
            ? screenWidth + (4.3 * (angle1))
            : screenWidth - (4.3 * (angle1));

//----------------------------------------------------------------------------------------------
        print(angle);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isCameraStarted
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        child: controller!.buildPreview(),
                      ),
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                            Colors.black54, BlendMode.srcOut),
                        child: Stack(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? (angle2.isNegative
                                          ? -angle2 * 0.010
                                          : angle2 *
                                              0.010) //landscape angle of rotation
                                      : (angle1.isNegative
                                          ? angle1 * 0.010
                                          : 0.010 *
                                              angle1), //portrait angle of rotation
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).orientation ==
                                                Orientation.landscape
                                            ? (height <= screenHeight * 0.35
                                                ? screenHeight * 0.35
                                                : height) //landscape height
                                            : (h <= screenHeight * 0.45
                                                ? screenHeight * 0.45
                                                : h), //portrait height
                                    width: MediaQuery.of(context).orientation ==
                                            Orientation.landscape
                                        ? (width <= screenWidth * 0.35
                                            ? screenWidth * 0.35
                                            : width) //landscape width
                                        : (w <= screenWidth * 0.5
                                            ? screenWidth * 0.5
                                            : w), //portrait width
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(0)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.rotate(
                        angle: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? -angle2 * 0.010 //landscape angle of rotation
                            : (angle1.isNegative
                                ? angle1 * 0.010
                                : 0.010 * angle1), //portrait angle of rotation
                        child: Center(
                          child: Container(
                            //static h/w👇
                            height: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? (height <= screenHeight * 0.35
                                    ? screenHeight * 0.35
                                    : height) //landscape height
                                : (h <= screenHeight * 0.45
                                    ? screenHeight * 0.45
                                    : h), //portrait height
                            width: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? (width <= screenWidth * 0.35
                                    ? screenWidth * 0.35
                                    : width) //landscape width
                                : (w <= screenWidth * 0.5
                                    ? screenWidth * 0.5
                                    : w), //portrait width
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 3, color: Colors.orange)),
                          ),
                        ),
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
                            ]),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              showzoom = !showzoom;
                              showev = false;
                            });
                          },
                          icon: Icon(
                            Icons.zoom_in,
                            size: 50,
                          )),
                    ),
                    InkWell(
                        onTap: () async {
                          XFile? rawImage = await click();
                          imageFile = File(rawImage!.path);
                          int currentUnix =
                              DateTime.now().millisecondsSinceEpoch;
                          final directory =
                              await getApplicationDocumentsDirectory();
                          String fileFormat = imageFile!.path.split('.').last;
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
                            color: Colors.black,
                          ),
                        )),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.white, width: 2),
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
              ],
            )
          : Container(),
    );
  }
}
