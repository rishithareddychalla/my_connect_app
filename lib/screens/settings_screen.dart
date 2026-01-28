import 'package:flutter/material.dart';
import 'package:my_connect_app/screens/login_screen.dart';
import 'package:my_connect_app/screens/manage_subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State Variables
  bool _isPremium = false; // Toggle to test Free vs Premium behavior
  String _selectedRegion = 'India (+91)';
  String _sortConnectionBy = 'Newest First';
  
  // Feature Toggles
  bool _autoWhatsApp = false;
  bool _saveToContacts = false;
  bool _autoDetectCategory = false;
  bool _publicProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'App Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC61C2C),
        elevation: 0,
        actions: [
          // Hidden toggle for testing Free/Premium state
          IconButton(
            icon: Icon(_isPremium ? Icons.star : Icons.star_border, color: Colors.yellow),
            onPressed: () {
              setState(() {
                _isPremium = !_isPremium;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isPremium ? 'Switched to PREMIUM Mode' : 'Switched to FREE Mode')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Subscription
            _buildSectionHeader('MyConnects Subscription'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                   // Navigate to Subscription Management
                   final result = await Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => ManageSubscriptionScreen(isPremium: _isPremium),
                     ),
                   );

                   // Update state if returned (e.g., user upgraded or cancelled)
                   if (result != null && result is bool) {
                     setState(() {
                       _isPremium = result;
                     });
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC61C2C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Manage MyConnects Subscription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Default Region
            _buildSectionHeader('Default Region Settings'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRegion,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onChanged: (String? newValue) {
                    setState(() => _selectedRegion = newValue!);
                  },
                  items: <String>['India (+91)', 'USA (+1)', 'UK (+44)']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          if (value.contains('India')) const Icon(Icons.flag, color: Colors.orange, size: 20), // Placeholder flag
                          if (value.contains('India')) const SizedBox(width: 8),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Your Connections (Sort)
            _buildSectionHeader('Your Connections'),
            const SizedBox(height: 4),
            const Text('Sort Connections by', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortConnectionBy,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onChanged: (String? newValue) {
                    setState(() => _sortConnectionBy = newValue!);
                  },
                  items: <String>['Newest First', 'Oldest First', 'A-Z', 'Z-A']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Save Settings (Premium)
            Row(
              children: const [
                Icon(Icons.workspace_premium, color: Colors.amber, size: 20), // Crown
                SizedBox(width: 8),
                Text('When I Save a New Connection', style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            _buildToggleItem(
              'Automatically send my details to the new connection on WhatsApp.', 
              _autoWhatsApp, 
              (val) => setState(() => _autoWhatsApp = val)
            ),
            const SizedBox(height: 8),
            _buildToggleItem(
              'Save the new connection to my Phone Contacts.', 
              _saveToContacts, 
              (val) => setState(() => _saveToContacts = val)
            ),
            const SizedBox(height: 8),
            _buildToggleItem(
              'Try and auto-detect Business Category of my new connection.', 
              _autoDetectCategory, 
              (val) => setState(() => _autoDetectCategory = val)
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_isPremium) {
                    _showUpsellDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences Saved')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPremium ? const Color(0xFFC61C2C) : Colors.grey, // Red if premium, Grey if free
                  padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            
            // 5. Public Profile (Premium)
             Row(
              children: const [
                Icon(Icons.workspace_premium, color: Colors.amber, size: 20), // Crown
                SizedBox(width: 8),
                Text('Public Profile Settings', style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activate my Public Profile', style: TextStyle(color: Colors.grey)), // Grey text as per image somewhat
              value: _publicProfile,
              activeColor: const Color(0xFFC61C2C),
              onChanged: (val) {
                if (!_isPremium) {
                  _showUpsellDialog(context);
                } else {
                   if (val) {
                     _showPrivacyPolicyDialog(context).then((confirmed) {
                       if (confirmed == true) {
                         setState(() => _publicProfile = true);
                       }
                     });
                   } else {
                     setState(() => _publicProfile = false);
                   }
                }
              },
            ),
            if (_publicProfile)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'https://profile.myconnects.app/hemanth',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),

             const SizedBox(height: 24),

            // 6. Export Connections (Premium)
             Row(
              children: const [
                Icon(Icons.workspace_premium, color: Colors.amber, size: 20), // Crown
                SizedBox(width: 8),
                Text('Export Connections', style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Export all your connections to a comma separated file (CSV).', 
              style: TextStyle(color: Colors.grey, fontSize: 14)
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_isPremium) {
                    _showUpsellDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting CSV...')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPremium ? const Color(0xFF5C6BC0) : Colors.grey, // Blueish grey/purple if active? Image shows Dark Grey.
                  // Actually image shows grey button for Export if disabled? Or dark grey normally? 
                  // Let's use a nice Slate/BlueGrey for active state.
                  padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Export as CSV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
             const SizedBox(height: 24),

            // 7. MyConnects Account
             _buildSectionHeader('MyConnects Account'),
             const SizedBox(height: 16),
             SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showDeleteAccountDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC61C2C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Delete Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF3F51B5), // Royal Blue
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildToggleItem(String title, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Switch(
          value: value,
          activeColor: const Color(0xFFC61C2C),
          onChanged: (val) {
            if (!_isPremium) {
              _showUpsellDialog(context);
            } else {
              onChanged(val);
            }
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showUpsellDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go Premium', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFC61C2C), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Upgrade to MyConnects Premium to unlock:'),
            SizedBox(height: 10),
            ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('Auto WhatsApp Share'), visualDensity: VisualDensity.compact),
            ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('Save to Phone Contacts'), visualDensity: VisualDensity.compact),
            ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('AI Category Detection'), visualDensity: VisualDensity.compact),
            ListTile(leading: Icon(Icons.check, color: Colors.green), title: Text('CSV Export'), visualDensity: VisualDensity.compact),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating to Subscription Page...')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC61C2C)),
            child: const Text('Upgrade Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPrivacyPolicyDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield, color: Color(0xFFC61C2C), size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const Text(
              'I agree - for Activating Public Profile.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC61C2C)),
            child: const Text('I Agree', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever, color: Color(0xFFC61C2C), size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const Text(
              'Deleting your account will permanently remove your profile and all synced connections. This cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Perform delete, then navigate to login
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted.')));
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC61C2C)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
