import 'package:flutter/material.dart';
import 'package:my_connect_app/screens/registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Wait for 2 seconds (or simulated load time)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RegistrationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Red Section with Wavy Bottom
          Expanded(
            flex: 3, // Takes 75% of space effectively if 3:1 ratio
            child: ClipPath(
              clipper: WavyBottomClipper(),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFC61C2C), // Red color
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     // App Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('assets/icon.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 20),
                    // App Name
                    const Text(
                      'MyConnects',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Tagline
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'The fastest way\nto strengthen\nbusiness\ncontacts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                     const SizedBox(height: 30),
                     // URL
                    const Text(
                      'www.myconnects.app',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom White Section with Logo
          Expanded(
            flex: 1, // Takes remaining space
            child: Container(
              width: double.infinity,
              color: Colors.white, // Explicit white background
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spindigo Logo
                  SizedBox(
                    width: 200,
                    height: 80,
                    child: Image.asset('assets/spindigo.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 10),
                  // Footer URL
                  const Text(
                    'www.spindigo.design',
                    style: TextStyle(
                      color: Colors.black, // Dark color for text on white
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavyBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // The wave height
    double waveHeight = 20.0;
    
    // Start at top-left
    path.lineTo(0, size.height - waveHeight);

    // Calculate the width of one wave. We want about 6-7 waves across based on the image.
    double waveWidth = size.width / 7;

    for (double i = 0; i < size.width; i += waveWidth) {
      // Create a quadratic bezier curve for each wave
      // The control point is halfway across the wave, and DOWN by waveHeight (to create the "bump")
      // The end point is at the end of the wave, back at the base height
      path.relativeQuadraticBezierTo(
        waveWidth / 2, waveHeight, // Control point
        waveWidth, 0               // End point
      );
    }

    // Continue to bottom-right (which is actually just the width, keeping the wave bottom)
    // Then go up to top-right
    path.lineTo(size.width, 0);
    // Close back to top-left
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
