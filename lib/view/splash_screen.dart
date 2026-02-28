import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../config/routes/routes_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // Initialize video
    _videoController = VideoPlayerController.asset("assets/videos/lab_video.mp4")
      ..initialize().then((_) {
        _videoController.play();
        _videoController.setLooping(true);
        setState(() {});
      });

    // Delay navigation after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background video
          _videoController.value.isInitialized
              ? FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController.value.size.width,
              height: _videoController.value.size.height,
              child: VideoPlayer(_videoController),
            ),
          )
              : Container(color: Colors.black),

          // Centered logo (static)
          Center(
            child: Image.asset(
              'assets/images/img_6.png',
              height: 250,
              width: 250,
            ),
          ),
        ],
      ),
    );
  }
}
