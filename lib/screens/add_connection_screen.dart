import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_connect_app/screens/contact_details_screen.dart';

class AddConnectionScreen extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialBusinessName;
  final String? initialCategory;
  final String? initialWebsite;
  final String? initialEmail;

  const AddConnectionScreen({
    super.key, 
    this.initialName,
    this.initialPhone,
    this.initialBusinessName,
    this.initialCategory,
    this.initialWebsite,
    this.initialEmail,
  });

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  final TextEditingController _notesController = TextEditingController();
  late TextEditingController _websiteController;
  late TextEditingController _emailController;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String? _selectedCategory;
  String? _phoneNumber;
  File? _capturedImage;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _businessNameController = TextEditingController(text: widget.initialBusinessName);
    _websiteController = TextEditingController(text: widget.initialWebsite);
    _emailController = TextEditingController(text: widget.initialEmail);
    _selectedCategory = widget.initialCategory;
    
    // Ensure the initial category exists in the list to avoid DropdownButton crash
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      if (!_businessCategories.contains(_selectedCategory)) {
        _businessCategories.insert(0, _selectedCategory!); // Add scanned category to top
      }
    } 
  }
  
  // Toggles
  bool _sendDetailsOnWhatsApp = true;
  bool _saveToPhoneContacts = true;
  bool _scheduleMeeting = false;

  // Mock Categories
  final List<String> _businessCategories = [
    'Technology',
    'Design',
    'Marketing',
    'Finance',
    'Healthcare',
    'Real Estate',
    'Retail',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _notesController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    var status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (status.isGranted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.camera);
        if (image != null && mounted) {
           setState(() {
             _capturedImage = File(image.path);
           });
        }
      } catch (e) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveConnection() async {
    if (_formKey.currentState!.validate()) {
       // Mock Save Logic
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Connection Added Successfully!'), backgroundColor: Colors.green),
       );

       if (_sendDetailsOnWhatsApp && _phoneNumber != null) {
          await _launchWhatsApp();
       }

       if (mounted) {
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(
             builder: (context) => ContactDetailsScreen(
               name: _nameController.text,
               phone: _phoneNumber!,
               businessName: _businessNameController.text,
               category: _selectedCategory,
               notes: _notesController.text,
               website: _websiteController.text,
               email: _emailController.text,
               image: _capturedImage,
             ),
           ),
         );
       }
    }
  }

  Future<void> _launchWhatsApp() async {
    final String myName = "Hemanth Sharma"; // Logged-in user
    final String connectionName = _nameController.text;
    final String todayDate = DateTime.now().toLocal().toString().split(' ')[0]; // YYYY-MM-DD
    
    // Construct Message
    String message = "Hi $connectionName,\n\n"
        "$myName here. We met on $todayDate. This is my phone number. Happy to connect with you and speak more.\n\n"
        "Here are my details -\n\n"
        "My business name: SK Creations\n" // Mock Data
        "My business category: Fashion Designer\n" // Mock Data
        "My website: https://www.spindigo.design\n"
        "My email: hemanth@example.com\n";

    if (_scheduleMeeting && _dateController.text.isNotEmpty && _timeController.text.isNotEmpty) {
      message += "\nLet’s try to connect on ${_dateController.text}, ${_timeController.text}.\n";
    }

    message += "\nThank you!";

    final Uri whatsappUrl = Uri.parse("whatsapp://send?phone=$_phoneNumber&text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for android or if standard scheme fails, sometimes web link works better but app is preferred
        debugPrint('Could not launch WhatsApp');
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add a Connection',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC61C2C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              _buildTextField(
                controller: _nameController,
                hintText: 'Name',
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 15),

              // Phone
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone (WhatsApp)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                initialCountryCode: 'IN',
                initialValue: widget.initialPhone, // Best effort pre-fill
                onChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 15),

              // Business Name
              _buildTextField(
                controller: _businessNameController,
                hintText: 'Business Name (Optional)',
              ),
              const SizedBox(height: 15),

              // Business Category
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   border: Border.all(color: Colors.grey),
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: DropdownButtonHideUnderline(
                   child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Business Category (Optional)'),
                    value: _selectedCategory,
                    items: _businessCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                 ),
              ),
              const SizedBox(height: 15),

               // Notes (Text + Mic Mock)
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                   _buildTextField(
                    controller: _notesController,
                    hintText: 'Notes (Optional)',
                    maxLines: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.mic, color: Colors.red),
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recording Voice Note... (Mock)')));
                      },
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 15),

              // Website
              _buildTextField(
                controller: _websiteController,
                hintText: 'Website (Optional)',
              ),
               const SizedBox(height: 15),

              // Email
              _buildTextField(
                controller: _emailController,
                hintText: 'Email (Optional)',
                validator: (value) => (value != null && value.isNotEmpty && !value.contains('@')) ? 'Invalid Email' : null,
              ),
               const SizedBox(height: 20),

              // Photo Section
              if (_capturedImage != null)
                 Row(
                   children: [
                     Expanded(
                       child: OutlinedButton.icon(
                        key: const Key('retake_photo_button'),
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt, color: Colors.indigo),
                        label: const Text('Retake Photo'),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          backgroundColor: Colors.white,
                        ),
                      ),
                     ),
                     const SizedBox(width: 10),
                     Container(
                       width: 50,
                       height: 50,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(8),
                         image: DecorationImage(
                           image: FileImage(_capturedImage!),
                           fit: BoxFit.cover
                         )
                       ),
                     )
                   ],
                 )
              else
              OutlinedButton.icon(
                key: const Key('take_photo_button'),
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt, color: Colors.indigo),
                label: const Text('Take Photo (Optional)'),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Toggles
              _buildSwitchTile('Send my details on WhatsApp', _sendDetailsOnWhatsApp, (val) => setState(() => _sendDetailsOnWhatsApp = val)),
              _buildSwitchTile('Save to my Phone Contacts', _saveToPhoneContacts, (val) => setState(() => _saveToPhoneContacts = val)),
              _buildSwitchTile('Schedule meeting', _scheduleMeeting, (val) => setState(() => _scheduleMeeting = val)),

              // Conditional Meeting Fields
              if (_scheduleMeeting) ...[
                 const SizedBox(height: 10),
                 Row(
                   children: [
                     Expanded(
                       child: GestureDetector(
                         onTap: () => _selectDate(context),
                         child: AbsorbPointer(
                           child: TextFormField(
                             controller: _dateController,
                             decoration: const InputDecoration(
                               hintText: 'Date',
                               filled: true,
                               fillColor: Colors.white,
                               border: OutlineInputBorder(),
                               suffixIcon: Icon(Icons.calendar_today, color: Colors.red),
                             ),
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(width: 10),
                     Expanded(
                       child: GestureDetector(
                         onTap: () => _selectTime(context),
                         child: AbsorbPointer(
                           child: TextFormField(
                             controller: _timeController,
                             decoration: const InputDecoration(
                               hintText: 'Time',
                               filled: true,
                               fillColor: Colors.white,
                               border: OutlineInputBorder(),
                               suffixIcon: Icon(Icons.access_time, color: Colors.red),
                             ),
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
              ],


              const SizedBox(height: 30),

              // Add Connection Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC61C2C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Connection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.indigo,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
