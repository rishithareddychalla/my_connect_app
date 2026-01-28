import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailsScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String? businessName;
  final String? category;
  final String? notes;
  final String? website;
  final String? email;
  final File? image;

  const ContactDetailsScreen({
    super.key,
    required this.name,
    required this.phone,
    this.businessName,
    this.category,
    this.notes,
    this.website,
    this.email,
    this.image,
  });

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  bool _showSuccessToast = true;

  @override
  void initState() {
    super.initState();
    // Hide success toast after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessToast = false;
        });
      }
    });
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: widget.phone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _messageOnWhatsApp() async {
    // Opens chat with the specific connection
    final Uri whatsappUrl = Uri.parse("whatsapp://send?phone=${widget.phone}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  Future<void> _shareOnWhatsApp() async {
    // Shares the profile details via WhatsApp (opens contact picker)
    final String text = 
      "Here’s my business contact info via MyConnects:\n\n"
      "Name: ${widget.name}\n"
      "Phone: ${widget.phone}\n"
      "${widget.businessName != null ? 'Company: ${widget.businessName}\n' : ''}"
      "${widget.category != null ? 'Role: ${widget.category}\n' : ''}"
      "${widget.email != null ? 'Email: ${widget.email}\n' : ''}"
      "${widget.website != null ? 'Website: ${widget.website}\n' : ''}"
      "\nSent via MyConnects App.";
    
    final Uri whatsappUrl = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
       // Fallback to system share if WhatsApp specific fails or preferred
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp Share')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC61C2C),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                       const SizedBox(height: 10),
                       // Profile Image
                       Container(
                         width: 120,
                         height: 120,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.white, width: 4),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.grey.withOpacity(0.2),
                               blurRadius: 10,
                               spreadRadius: 2,
                             )
                           ],
                           image: DecorationImage(
                             image: widget.image != null 
                              ? FileImage(widget.image!) as ImageProvider
                              : const NetworkImage('https://i.pravatar.cc/300?img=11'), // Fallback
                             fit: BoxFit.cover,
                           ),
                         ),
                       ),
                       const SizedBox(height: 30),

                       // Details Cards
                       _buildDetailCard('NAME', widget.name),
                       _buildDetailCard(
                         'PHONE (WHATSAPP)', 
                         widget.phone, 
                         isPhone: true
                       ),
                       if (widget.businessName != null && widget.businessName!.isNotEmpty)
                         _buildDetailCard('COMPANY NAME', widget.businessName!),
                       if (widget.category != null && widget.category!.isNotEmpty)
                         _buildDetailCard('BUSINESS CATEGORY', widget.category!),
                       
                       // Notes with Mock Player
                       if (widget.notes != null && widget.notes!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('App Design Discussion', style: TextStyle(color: Colors.grey, fontSize: 12)), // Title for notes? Or simulate logic
                              const SizedBox(height: 8),
                              // Mock Audio Player UI
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.volume_up, size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(child: Container(height: 2, color: Colors.grey[400])), // Waveform placeholder
                                    const SizedBox(width: 8),
                                    const Icon(Icons.play_circle_fill, color: Colors.red),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(widget.notes!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),

                       if (widget.website != null && widget.website!.isNotEmpty)
                         _buildDetailCard('WEBSITE', widget.website!),
                       if (widget.email != null && widget.email!.isNotEmpty)
                         _buildDetailCard('EMAIL', widget.email!),
                       
                       // Saved On
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SAVED ON', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                DateTime.now().toLocal().toString().split(' ')[0], // Todo: format properly
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Bar
              Container(
                color: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.share, 'SHARE ON\nWHATSAPP', _shareOnWhatsApp),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _buildActionButton(Icons.phone, 'PHONE\nCALL', _makePhoneCall),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _buildActionButton(Icons.message, 'WHATSAPP\nMESSAGE', _messageOnWhatsApp),
                  ],
                ),
              ),
            ],
          ),

          // Success Toast Overlay
          if (_showSuccessToast)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        'Connection Added Successfully',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, {bool isPhone = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              if (isPhone)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                  },
                  child: const Icon(Icons.copy, size: 18, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
