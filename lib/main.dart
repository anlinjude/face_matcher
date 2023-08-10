import 'package:face_matcher/face_matching_page.dart';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //Add this

   FaceCamera.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FaceMatchingPage(),
    );
  }
}
