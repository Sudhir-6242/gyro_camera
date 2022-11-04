// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// Future<void> main() async {
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//     cameras = await availableCameras();
//     print(cameras[0]);
//   } on CameraException catch (e) {
//     print(' Error in fetchin the cameras.');
//   }
//   runApp(const MyApp());
// }

// List<CameraDescription> cameras = [];

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: CameraScreen(),
//     );
//   }
// }

// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? controller;
//   bool isCameraStarted = false;

//   Future<void> onSelectedCamera(CameraDescription cameraDescription) async {
//     final previousController = controller;
//     final CameraController newControlller = CameraController(
//         cameraDescription, ResolutionPreset.high,
//         imageFormatGroup: ImageFormatGroup.jpeg);
//     await previousController?.dispose();
//     if (mounted) {
//       setState(() {
//         controller = newControlller;
//       });
//     }
//     newControlller.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//     try {
//       await newControlller.initialize();
//     } on CameraException catch (e) {
//       print('cannot open camera');
//     }

//     if (mounted) {
//       setState(() {
//         isCameraStarted = controller!.value.isInitialized;
//       });
//     }
//   }

//   @override
//   void initState() {
//     onSelectedCamera(cameras[0]);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isCameraStarted
//           ? AspectRatio(
//               aspectRatio: 1 / controller!.value.aspectRatio,
//               child: controller!.buildPreview(),
//             )
//           : Container(),
//     );
//   }
// }
