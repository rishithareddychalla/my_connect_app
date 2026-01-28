import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_connect_app/screens/add_connection_screen.dart';
import 'package:my_connect_app/screens/contact_details_screen.dart';

class ScanConnectionScreen extends StatefulWidget {
  const ScanConnectionScreen({super.key});

  @override
  State<ScanConnectionScreen> createState() => _ScanConnectionScreenState();
}

class _ScanConnectionScreenState extends State<ScanConnectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isBusinessCardMode = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isBusinessCardMode = _tabController.index == 1;
      });
      if (_isBusinessCardMode) {
        _scannerController.stop();
      } else {
        _scannerController.start();
      }
    });

    // Check permissions
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.camera.request();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onQRDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!;
        // Assuming QR contains VCard or encoded JSON. 
        // For this demo, we'll parse a simple format: "Name|Business|Phone" OR valid VCard
        // Or just navigate with what we found.
        
        debugPrint('QR Code Found: $code');
        _scannerController.stop(); // Stop scanning once found
        
        String name = "QR Scanned User";
        String phone = "";
        String? businessName;
        String? category;
        String? email;
        String? website;

        try {
          final Uri uri = Uri.parse(code);
          if (uri.scheme == 'myconnects' && uri.host == 'add') {
             name = uri.queryParameters['name'] ?? name;
             phone = uri.queryParameters['phone'] ?? phone;
             businessName = uri.queryParameters['company'];
             category = uri.queryParameters['role'];
             email = uri.queryParameters['email'];
             website = uri.queryParameters['website'];
          }
        } catch (e) {
          debugPrint('Error parsing QR: $e');
        }
        
        _navigateToAddConnection(
          name: name, 
          phone: phone, 
          businessName: businessName,
          category: category,
          email: email,
          website: website
        );
        break; 
      }
    }
  }

  Future<void> _captureBusinessCard() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        final InputImage inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer();
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        
        String extractedText = recognizedText.text;
        
        // Simple Heuristic Extraction (Mock-ish)
        String name = "";
        String phone = "";
        String email = "";
        
        // Very basic parsing attempt
        List<String> lines = extractedText.split('\n');
        if (lines.isNotEmpty) name = lines[0]; // Assume first line is Name
        
        RegExp phoneRegex = RegExp(r'(\d{10}|\+91\s?\d{10})');
        RegExp emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

        var phoneMatch = phoneRegex.firstMatch(extractedText);
        if (phoneMatch != null) phone = phoneMatch.group(0) ?? "";

        var emailMatch = emailRegex.firstMatch(extractedText);
        if (emailMatch != null) email = emailMatch.group(0) ?? "";

        textRecognizer.close();

        _navigateToAddConnection(
          name: name.isNotEmpty ? name : "Scanned Card",
          phone: phone,
          email: email,
          businessName: lines.length > 1 ? lines[1] : null
        );
      }
    } catch (e) {
      debugPrint('Error scanning card: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to scan card')));
    }
  }

  void _navigateToAddConnection({
    String? name, 
    String? phone, 
    String? businessName, 
    String? email,
    String? category,
    String? website,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailsScreen(
          name: name ?? "Scanned User",
          phone: phone ?? "",
          businessName: businessName,
          category: category,
          email: email,
          website: website,
          // note: we don't have an image from QR, so it will use default
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View
          if (!_isBusinessCardMode)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onQRDetected,
            )
          else 
            Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Align Business Card within frame',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),

          // Overlay Frame
          Center(
             child: Container(
               width: 300,
               height: _isBusinessCardMode ? 180 : 300, // Rectangle for card, Square for QR
               decoration: BoxDecoration(
                 border: Border.all(color: Colors.red, width: 3),
                 borderRadius: BorderRadius.circular(12),
               ),
             ),
          ),

          // Top Bar (Back & Flash)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                if (!_isBusinessCardMode)
                IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: _scannerController,
                    builder: (context, state, child) {
                       return Icon(
                         state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                         color: Colors.white, size: 30
                       );
                    },
                  ),
                  onPressed: () => _scannerController.toggleTorch(),
                ),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isBusinessCardMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: GestureDetector(
                        onTap: _captureBusinessCard,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 4),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                        ),
                      ),
                    ),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFC61C2C),
                    indicatorWeight: 4,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                       Tab(text: "QR Code"),
                       Tab(text: "Business Card"),
                    ],
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
