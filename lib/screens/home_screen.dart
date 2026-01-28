import 'package:flutter/material.dart';
import 'package:my_connect_app/screens/edit_profile_screen.dart';
import 'package:my_connect_app/screens/view_connections_screen.dart';
import 'package:my_connect_app/screens/add_connection_screen.dart';
import 'package:my_connect_app/screens/contact_details_screen.dart';
import 'package:my_connect_app/screens/scan_connection_screen.dart';
import 'package:my_connect_app/screens/share_profile_screen.dart';
import 'package:my_connect_app/screens/settings_screen.dart';
import 'package:my_connect_app/screens/meetings_screen.dart';
import 'package:my_connect_app/screens/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock Data for Recent Connections
  final List<Map<String, String>> _recentConnections = [
    {
      'name': 'Noel John',
      'role': 'Interior Designer',
      'image': 'assets/noel.png', // Placeholder, will handle missing asset gracefully
    },
    {
      'name': 'Maya Lin',
      'role': 'Architect',
      'image': 'assets/maya.png',
    },
    {
      'name': 'Sarah Lee',
      'role': 'Graphic Designer',
      'image': 'assets/sarah.png',
    },
    {
      'name': 'Raj Patel',
      'role': 'UI/UX Designer',
      'image': 'assets/raj.png',
    },
    {
      'name': 'Emma Watson',
      'role': 'Product Designer',
      'image': 'assets/emma.png',
    },
  ];

  void _showAppMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 0, 0), // Adjust position top-right
      items: [
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: const [
              Icon(Icons.settings_outlined, color: Colors.grey),
              SizedBox(width: 10),
              Text('App Settings'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'about',
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.red),
              SizedBox(width: 10),
              Text('About'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Sign Out'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'settings') {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => const SettingsScreen()),
         );
      } else if (value == 'about') {
         _launchAboutUrl();
      } else if (value == 'logout') {
         _showSignOutDialog(context);
      }
    });
  }

  Future<void> _launchAboutUrl() async {
    const url = 'https://myconnects.app/about';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open About page')));
       }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.logout, color: Color(0xFFC61C2C)),
            ),
            const SizedBox(height: 16),
            const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const Text(
              'Are you sure you want to sign out?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('No', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Navigate to Login and clear stack
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC61C2C),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Yes', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFC61C2C), // Red
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'MyConnects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () {
              _showAppMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. My Details Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Profile Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            image: const DecorationImage(
                              // Using a placeholder network image or asset if available
                              // For valid UI, we use a fallback icon if image fails
                              image: NetworkImage('https://i.pravatar.cc/150?img=11'), 
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Name and Phone
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Hemanth Sharma',
                                style: TextStyle(
                                  color: Color(0xFFC61C2C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '+91 99805 18424',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit Icon
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFFC61C2C)),
                          onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                             );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // 3. Stats Card (Total Connections)
                  GestureDetector(
                    onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => const ViewConnectionsScreen()),
                       );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                '1244',
                                style: TextStyle(
                                  color: Color(0xFFC61C2C),
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Padding(
                                padding: EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  'CONNECTIONS',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Search Bar (Clickable)
                  GestureDetector(
                    onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => const ViewConnectionsScreen(focusSearch: true)),
                       );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            'Search Connections',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Recent Connections',
                      style: TextStyle(
                        color: Color(0xFF3F51B5), // Blue/Purple from image
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 5. Recent Connections List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentConnections.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _recentConnections[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 12}'),
                        ),
                        title: Text(
                          item['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item['role']!,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                        onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => ContactDetailsScreen(
                                 name: item['name']!,
                                 phone: '+91 98765 43210', // Mock data for existing list
                                 businessName: 'Creative Studio', // Mock data
                                 category: item['role'],
                                 notes: 'Met at the design conference. Discussed potential collaboration.',
                                 email: 'contact@example.com',
                                 website: 'www.example.com',
                                 // Note: We are not passing 'image' as File here since these are network images
                                 // The ContactDetailsScreen handles null image by showing a fallback network image
                                 // For a real app, we'd refactor ContactDetailsScreen to accept ImageProvider or URL
                               ),
                             ),
                           );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20), // Bottom padding before nav bar
                ],
              ),
            ),
          ),

          // 7. Custom Bottom Nav Bar
          Container(
            color: const Color(0xFF3F51B5), // Royal Blue
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.contacts, 'VIEW', () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const ViewConnectionsScreen()),
                   );
                }),
            
                _buildNavItem(Icons.share, 'SHARE', () {
                   showDialog(
                     context: context,
                     builder: (context) => AlertDialog(
                       title: const Text('Public Profile'),
                       content: const Text('Do you want to make the scanner public?'),
                       actions: [
                         TextButton(
                           onPressed: () {
                             Navigator.pop(context);
                             Navigator.push(
                               context, 
                               MaterialPageRoute(builder: (context) => const ShareProfileScreen(isPublic: false)),
                             );
                           },
                           child: const Text('No'),
                         ),
                         TextButton(
                           onPressed: () {
                             Navigator.pop(context);
                             Navigator.push(
                               context, 
                               MaterialPageRoute(builder: (context) => const ShareProfileScreen(isPublic: true)),
                             );
                           },
                           child: const Text('Yes'),
                         ),
                       ],
                     ),
                   );
                }),
                _buildNavItem(Icons.qr_code_scanner, 'SCAN', () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const ScanConnectionScreen()),
                   );
                }),
                _buildNavItem(Icons.person_add, 'ADD', () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const AddConnectionScreen()),
                   );
                }),
                _buildNavItem(Icons.calendar_today, 'MEETINGS', () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const MeetingsScreen()),
                   );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label Clicked')));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
