import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers (Pre-filled with mock data)
  final TextEditingController _nameController = TextEditingController(text: "Hemanth Sharma");
  final TextEditingController _businessNameController = TextEditingController(text: "Spindigo Designs LLP");
  final TextEditingController _websiteController = TextEditingController(text: "https://www.spindigo.design");
  final TextEditingController _emailController = TextEditingController(text: "example@gmail.com");

  String? _selectedCategory = "Web Design & Development";
  String? _phoneNumber = "9980518424"; 
  File? _profileImage; // Ideally fetched from network/local, using null (placeholder) for now
  
  // Mock Categories
  final List<String> _businessCategories = [
    'Technology',
    'Web Design & Development',
    'Retail',
    'Consulting',
    'Healthcare',
    'Education',
    'Finance',
    'Marketing',
    'Manufacturing',
    'Real Estate',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
      // Logic similar to RegistrationScreen but focused on Camera for "Recapture" 
      // or we can offer both. "Recapture" usually implies Camera.
      // Let's assume Camera based on "Recapture".
      
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
              _profileImage = File(image.path);
            });
          }
        } catch (e) {
          debugPrint('Error picking image: $e');
        }
      }
  }

  void _removePhoto() {
    setState(() {
      _profileImage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo removed')));
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Mock Save Logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes Saved Successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit My Profile',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name
              _buildTextField(
                controller: _nameController,
                hintText: 'Full Name',
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 15),

              // Phone Number
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                initialCountryCode: 'IN',
                initialValue: _phoneNumber, // Pre-fill does not always work perfectly with package updates but helps
                onChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 15),

              // Business Name
              _buildTextField(
                controller: _businessNameController,
                hintText: 'Business Name',
                validator: (value) => value!.isEmpty ? 'Business Name is required' : null,
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

              // Website
              _buildTextField(
                controller: _websiteController,
                hintText: 'Website URL',
              ),
               const SizedBox(height: 15),

              // Email
              _buildTextField(
                controller: _emailController,
                hintText: 'Email Id',
                validator: (value) => (value != null && value.contains('@')) ? null : 'Invalid Email',
              ),
              
              const SizedBox(height: 30),
              
              // Profile Picture Section
              const Text(
                'My Profile Picture',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null 
                      ? FileImage(_profileImage!) 
                      : const NetworkImage('https://i.pravatar.cc/150?img=11') as ImageProvider, // Default/Current Image
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt, color: Colors.blue),
                          label: const Text('Recapture Photo', style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _removePhoto,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Remove Photo', style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                             minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC61C2C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
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
  }) {
    return TextFormField(
      controller: controller,
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
}
