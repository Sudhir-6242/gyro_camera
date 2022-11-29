import 'package:flutter/material.dart';
import 'screen/cameraScreen.dart';
import 'package:camera/camera.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    print(cameras[0]);
  } on CameraException catch (e) {
    print(' Error in fetchin the cameras. $e');
  }
  runApp(const MyApp());
}

List<CameraDescription> cameras = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}
