import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  final bool isPremium;
  const ManageSubscriptionScreen({super.key, required this.isPremium});

  @override
  State<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  late bool _isPremium;

  @override
  void initState() {
    super.initState();
    _isPremium = widget.isPremium;
  }

  Future<void> _restorePurchase() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restoring purchases...')),
    );
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock Result
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchases restored successfully!')),
      );
       // In real app, we would update state here if valid sub found
    }
  }

  Future<void> _openPremiumPlans() async {
    const url = 'https://myconnects.app';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // Open in external browser or in-app browser based on preference
      // User requested "modal popup inside app (headless browser component)" 
      // LaunchMode.inAppWebView provides this experience
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Could not open plans page.')),
        );
      }
    }
  }
  
  void _purchasePremium() {
    // Navigate to a payment screen or trigger in-app purchase flow
    // For now we simulate an upgrade for UX testing
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: const Text('Unlock all features for \$9.99/month?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC61C2C)),
            onPressed: () {
               Navigator.pop(ctx);
               setState(() => _isPremium = true);
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Welcome to Premium!')),
               );
            }, 
            child: const Text('Buy Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _cancelSubscription() {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure? You will lose access to Premium features at the end of the billing period.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
          TextButton(
            onPressed: () {
               Navigator.pop(ctx);
               setState(() => _isPremium = false);
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Subscription Cancelled.')),
               );
            }, 
            child: const Text('Confirm Cancellation', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _isPremium),
        ),
        title: const Text(
          'Manage Subscription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC61C2C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Header
            const Text(
              'Current Plan',
              style: TextStyle(
                color: Color(0xFF3F51B5), // Blue/Purple
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Current Plan Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildInfoRow('Plan', _isPremium ? 'Premium' : 'Free'),
                   const SizedBox(height: 8),
                   _buildInfoRow('Status', 'Active'),
                   const SizedBox(height: 8),
                   _buildInfoRow('Validity', _isPremium ? '20 Sep 2025' : '-'),
                   const SizedBox(height: 16),
                   Text(
                     _isPremium ? 'Enjoying Premium features' : 'Upgrade to unlock Premium features',
                     style: TextStyle(
                       color: Colors.grey[800],
                       fontSize: 14,
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Purchase Premium Plan (Only if Free)
            if (!_isPremium) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _purchasePremium,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC61C2C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                       Icon(Icons.workspace_premium, color: Colors.amber, size: 22),
                       SizedBox(width: 8),
                       Text(
                         'Purchase Premium Plan',
                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                       ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            
              Divider(thickness: 1, color: Colors.grey[200]),
              const SizedBox(height: 16),

              // Already a Premium Member?
              const Text(
                'Already a Premium Member?',
                style: TextStyle(
                  color: Color(0xFF3F51B5),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _restorePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC61C2C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Restore Purchase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              Divider(thickness: 1, color: Colors.grey[200]),
              const SizedBox(height: 16),
            ],

            // Explore Premium Plans
            Row(
              children: const [
                Icon(Icons.workspace_premium, color: Color(0xFF2E3E5C), size: 20), // Dark Blue Icon? Using Image Reference
                SizedBox(width: 8),
                Text(
                  'Explore Premium Plans',
                  style: TextStyle(
                    color: Color(0xFF3F51B5),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openPremiumPlans,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC61C2C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Explore Premium Plans', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
             const SizedBox(height: 24),

            // Cancel Subscription (Grey Button)
            if (_isPremium) ...[
               Divider(thickness: 1, color: Colors.grey[200]),
               const SizedBox(height: 16),
               SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cancelSubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600], // Grey
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Cancel Subscription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: [
          TextSpan(text: '$label : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: value, 
            style: const TextStyle(
              color: Color(0xFFC61C2C), // Red color for values
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}
