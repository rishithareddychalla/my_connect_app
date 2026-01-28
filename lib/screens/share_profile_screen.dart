import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareProfileScreen extends StatelessWidget {
  final bool isPublic;
  final String username = "hemanth_sharma"; // Mock username

  const ShareProfileScreen({super.key, required this.isPublic});

  String get _publicLink => "https://profile.myconnects.app/$username";

  Future<void> _launchLink() async {
    final Uri url = Uri.parse(_publicLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareOnWhatsApp() async {
    // Construct VCard or Link Message
    String message = "Here is my contact profile on MyConnects:\n\n";
    // If private, we might send VCard data explicitly or a deep link if supported
    // For now, assume a deep link pattern similar to public profile but meant for app opening
    message += "https://myconnects.app/connect/$username";
    
    final Uri whatsappUrl = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Encode details in the QR code so the scanner can parse them
    // Using a custom scheme or just a list of parameters
    final String richData = "myconnects://add?"
        "name=${Uri.encodeComponent("Hemanth Sharma")}&"
        "phone=${Uri.encodeComponent("+919876543210")}&"
        "company=${Uri.encodeComponent("SK Creations")}&"
        "role=${Uri.encodeComponent("Fashion Designer")}&"
        "email=${Uri.encodeComponent("hemanth@example.com")}&"
        "website=${Uri.encodeComponent("www.spindigo.design")}";

    final String qrData = richData; // Use this for both for now to ensure scanning works inside the app

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Share My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC61C2C),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            const Text(
              'Ask your business friend to scan\nthis QR code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // QR Code Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220,
                // You can add an embedded image/logo in the center if supported/desired
                // embeddedImage: const AssetImage('assets/images/logo.png'),
                // embeddedImageStyle: QrEmbeddedImageStyle(size: const Size(40, 40)),
              ),
            ),
            
            const SizedBox(height: 40),

            // Variable Footer
            if (isPublic) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.grey.shade300)
                ),
                child: GestureDetector(
                  onTap: _launchLink,
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: _publicLink));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link Copied')));
                  },
                  child: Text(
                    _publicLink,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87, 
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                 "Tap to open • Long press to copy",
                 style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ] else ...[
               SizedBox(
                 width: double.infinity,
                 height: 50,
                 child: ElevatedButton.icon(
                   onPressed: _shareOnWhatsApp,
                   icon: const Icon(Icons.share, color: Colors.white),
                   label: const Text("Share on WhatsApp"),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.green, // WhatsApp Color
                     foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                 ),
               ),
            ],

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
