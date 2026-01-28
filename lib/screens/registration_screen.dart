import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_connect_app/screens/verification_screen.dart';
import 'package:my_connect_app/screens/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // State variables
  String? _selectedCategory;
  File? _profileImage;
  bool _isPrivacyChecked = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _phoneNumber;
  
  // Constants
  final List<String> _businessCategories = [
    'Technology',
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

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImageFromSource(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImageFromSource(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // For gallery, android 13+ needs photos, older needs storage.
      // However, image_picker mostly handles this. Let's try basic request or skipping perms for gallery if image_picker handles it.
      // But standard practice with permission_handler:
      if (Platform.isAndroid) {
        // Simple check for now, or just let image_picker handle it which is safer if we don't know SDK ver easily.
        // Let's rely on image_picker to request perms for gallery as it's cleaner.
        // For camera, we explicitly request because of the previous crash needing it.
        status = PermissionStatus.granted; 
      } else {
        status = await Permission.photos.request();
      }
    }

    if (source == ImageSource.camera && status.isDenied) {
       // Only block if explicitly denied for camera
       return;
    }

    if (source == ImageSource.camera && status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null && mounted) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is the Privacy Policy.\n\n'
            '1. We collect minimal data.\n'
            '2. Your data is secure.\n'
            '3. We do not sell your data.\n'
            '...\n'
            '(Full privacy policy text would go here)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'These are the Terms & Conditions.\n\n'
            '1. By using this app, you agree to...\n'
            '2. User responsibilities...\n'
            '3. App usage rules...\n'
            '...\n'
            '(Full terms text would go here)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_isPrivacyChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Privacy Policy and Terms & Conditions to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Proceed to Verification Step
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data...')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VerificationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            color: const Color(0xFFC61C2C), // Red color
            child: const Center(
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to MyConnects!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Example blue
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please setup your profile to begin using MyConnects.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Your Name',
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 15),

                    // Phone Number
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      initialCountryCode: 'IN', // Default region
                      onChanged: (phone) {
                         _phoneNumber = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Business Name
                    _buildTextField(
                      controller: _businessNameController,
                      hintText: 'Your Business Name',
                      validator: (value) => value!.isEmpty ? 'Please enter business name' : null,
                    ),
                    const SizedBox(height: 15),

                    // Business Category
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Your Business Category',
                        filled: true,
                        fillColor: Colors.white,
                      ),
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
                      validator: (value) => value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 15),

                    // Email Id
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email Id',
                      validator: (value) {
                         if (value == null || value.isEmpty) return 'Please enter email';
                         if (!value.contains('@')) return 'Invalid email';
                         return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Website Link
                    _buildTextField(
                      controller: _websiteController,
                      hintText: 'Your Company Website Link',
                      // Optional field logic if needed, otherwise required per prompt
                      validator: (value) => value!.isEmpty ? 'Please enter website' : null,
                    ),
                    const SizedBox(height: 15),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      isPassword: true,
                      toggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) => value!.length < 6 ? 'Password too short' : null,
                    ),
                    const SizedBox(height: 15),

                    // Confirm Password
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      isPassword: true,
                      toggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // Profile Picture Section
                    const Text('Your Profile Picture', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Capture Photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Terms & Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isPrivacyChecked,
                          onChanged: (value) {
                            setState(() {
                              _isPrivacyChecked = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(color: Colors.red, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()..onTap = _showPrivacyPolicy,
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: const TextStyle(color: Colors.red, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()..onTap = _showTermsConditions,
                                ),
                                const TextSpan(text: ' of Spindigo Designs LLP.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isPrivacyChecked ? _submitForm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC61C2C), // Red color
                          disabledBackgroundColor: Colors.grey[300], // Grey if disabled
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Color(0xFFC61C2C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      controller.clear();
                      setState((){});
                    },
                  ) 
                : null,
      ),
      onChanged: (_) => setState((){}), // Rebuild to toggle clear icon
      validator: validator,
    );
  }
}
