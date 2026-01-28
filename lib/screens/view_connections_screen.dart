import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewConnectionsScreen extends StatefulWidget {
  final bool focusSearch;
  const ViewConnectionsScreen({super.key, this.focusSearch = false});

  @override
  State<ViewConnectionsScreen> createState() => _ViewConnectionsScreenState();
}

class _ViewConnectionsScreenState extends State<ViewConnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _nameFilterController = TextEditingController();
  final TextEditingController _categoryFilterController = TextEditingController();
  bool _isFilterVisible = false;
  DateTimeRange? _dateRange;
  String _sortBy = 'A-Z'; // Options: A-Z, Z-A, Newest, Oldest

  // Mock Data for Connections
  final List<Map<String, dynamic>> _connections = [
    {
      'name': 'Aadhav',
      'role': 'Interior Designer',
      'company': 'Decor Space',
      'date': DateTime(2025, 6, 15),
      'image': 'assets/aadhav.png',
    },
    {
      'name': 'Aarav',
      'role': 'Architect',
      'company': 'Build Right',
      'date': DateTime(2025, 5, 20),
      'image': 'assets/aarav.png',
    },
    {
      'name': 'Aayan',
      'role': 'Graphic Designer',
      'company': 'Pixel Perfect',
      'date': DateTime(2025, 7, 10),
      'image': 'assets/aayan.png',
    },
    {
      'name': 'Bharat',
      'role': 'UI/UX Designer',
      'company': 'Design Hub',
      'date': DateTime(2025, 8, 05),
      'image': 'assets/bharat.png',
    },
    {
      'name': 'Bhuvan',
      'role': 'Product Designer',
      'company': 'InnoCreate',
      'date': DateTime(2025, 4, 12),
      'image': 'assets/bhuvan.png',
    },
    {
      'name': 'Bushan',
      'role': 'Industrial Designer',
      'company': 'Mech Works',
      'date': DateTime(2025, 6, 25),
      'image': 'assets/bushan.png',
    },
    {
      'name': 'Chandran',
      'role': 'Industrial Designer',
      'company': 'Factory X',
      'date': DateTime(2025, 5, 30),
      'image': 'assets/chandran.png',
    },
    {
      'name': 'Chaitanya',
      'role': 'Industrial Designer',
      'company': 'Create Lab',
      'date': DateTime(2025, 7, 01),
      'image': 'assets/chaitanya.png',
    },
    {
      'name': 'Devansh',
      'role': 'Industrial Designer',
      'company': 'Indus Design',
      'date': DateTime(2025, 8, 15),
      'image': 'assets/devansh.png',
    },
    {
      'name': 'Girish',
      'role': 'Graphic Designer',
      'company': 'Artistic flow',
      'date': DateTime(2025, 6, 05),
      'image': 'assets/girish.png',
    },
  ];

  List<Map<String, dynamic>> _filteredConnections = [];

  @override
  void initState() {
    super.initState();
    _applyFilters(); // Initial sort and filter
    
    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      });
    }
    
    // Listeners for real-time updates
    _searchController.addListener(_applyFilters);
    _nameFilterController.addListener(_applyFilters);
    _categoryFilterController.addListener(_applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final nameFilter = _nameFilterController.text.toLowerCase();
    final categoryFilter = _categoryFilterController.text.toLowerCase();

    setState(() {
      _filteredConnections = _connections.where((item) {
        final name = (item['name'] as String).toLowerCase();
        final role = (item['role'] as String).toLowerCase();
        final company = (item['company'] as String).toLowerCase();
        final date = item['date'] as DateTime;

        // Global Search Bar
        bool matchesQuery = name.contains(query) || role.contains(query) || company.contains(query);
        
        // Advanced Filters
        bool matchesName = name.contains(nameFilter) || company.contains(nameFilter);
        bool matchesCategory = role.contains(categoryFilter);
        
        bool matchesDate = true;
        if (_dateRange != null) {
          matchesDate = date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) && 
                        date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
        }

        return matchesQuery && matchesName && matchesCategory && matchesDate;
      }).toList();

      // Sort Results
      _sortConnections();
    });
  }

  void _sortConnections() {
    switch (_sortBy) {
      case 'A-Z':
        _filteredConnections.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case 'Z-A':
        _filteredConnections.sort((a, b) => (b['name'] as String).compareTo(a['name'] as String));
        break;
      case 'Newest First':
        _filteredConnections.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        break;
      case 'Oldest First':
        _filteredConnections.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _nameFilterController.dispose();
    _categoryFilterController.dispose();
    super.dispose();
  }

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
          'View',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFilterVisible ? Icons.filter_alt : Icons.filter_alt_outlined, 
              color: Colors.white
            ),
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
          ),
        ],
        backgroundColor: const Color(0xFFC61C2C),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             decoration: const BoxDecoration(
               color: Colors.white,
               border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
             ),
             child: TextField(
               controller: _searchController,
               focusNode: _searchFocusNode,
               decoration: InputDecoration(
                 hintText: 'Search in your connections here...',
                 hintStyle: const TextStyle(color: Colors.grey),
                 border: InputBorder.none,
                 suffixIcon: const Icon(Icons.search, color: Color(0xFF3F51B5)), // Blueish
               ),
             ),
          ),

          // Filter Panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isFilterVisible ? 280 : 0,
            color: Colors.grey[50], // Light grey background
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   // Name/Business Name
                   TextField(
                     controller: _nameFilterController,
                     decoration: const InputDecoration(
                       labelText: 'Name, Business Name',
                       border: OutlineInputBorder(),
                       isDense: true,
                     ),
                   ),
                   const SizedBox(height: 10),
                   // Business Category
                   TextField(
                     controller: _categoryFilterController,
                     decoration: const InputDecoration(
                       labelText: 'Business Category',
                       border: OutlineInputBorder(),
                       isDense: true,
                     ),
                   ),
                   const SizedBox(height: 10),
                   // Date Filter
                   GestureDetector(
                     onTap: () async {
                       final DateTimeRange? picked = await showDateRangePicker(
                         context: context,
                         firstDate: DateTime(2020),
                         lastDate: DateTime(2030),
                         initialDateRange: _dateRange,
                         builder: (context, child) {
                             return Theme(
                               data: Theme.of(context).copyWith(
                                 colorScheme: const ColorScheme.light(
                                   primary: Color(0xFFC61C2C), // Red highlight
                                   onPrimary: Colors.white, 
                                   surface: Colors.white, 
                                   onSurface: Colors.black,
                                 ),
                               ),
                               child: child!,
                             );
                         },
                       );
                       if (picked != null) {
                         setState(() {
                           _dateRange = picked;
                           _applyFilters();
                         });
                       }
                     },
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.grey),
                         borderRadius: BorderRadius.circular(4),
                         color: Colors.white,
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             _dateRange == null 
                               ? 'Select Date Range' 
                               : '${_dateRange!.start.toLocal().toString().split(' ')[0]} - ${_dateRange!.end.toLocal().toString().split(' ')[0]}',
                             style: TextStyle(color: _dateRange == null ? Colors.grey[700] : Colors.black),
                           ),
                           const Icon(Icons.calendar_today, size: 20, color: Color(0xFFC61C2C)),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(height: 10),
                   // Sort By
                    DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: const InputDecoration(
                        labelText: 'Sort By',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortBy = newValue;
                            _applyFilters();
                          });
                        }
                      },
                      items: <String>['A-Z', 'Z-A', 'Newest First', 'Oldest First']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          // Connections List
          Expanded(
            child: ListView.separated(
              itemCount: _filteredConnections.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 70), // Indent separator like standard lists
              itemBuilder: (context, index) {
                final item = _filteredConnections[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${item['name']}'),
                  ),
                  title: Text(
                    item['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    item['role']!,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) async {
                       // Mock Phone Number & Profile Link since data is limited
                       final String phoneNumber = "9876543210"; 
                       final String profileLink = "https://myconnects.app/profile/${item['name']}";

                       switch (value) {
                         case 'call':
                           final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
                           if (await canLaunchUrl(launchUri)) {
                             await launchUrl(launchUri);
                           }
                           break;
                         case 'whatsapp':
                           final Uri whatsappUrl = Uri.parse("whatsapp://send?phone=$phoneNumber");
                           if (await canLaunchUrl(whatsappUrl)) {
                             await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                           }
                           break;
                         case 'share':
                           final Uri shareUrl = Uri.parse("whatsapp://send?text=${Uri.encodeComponent("Check out this profile: $profileLink")}");
                            if (await canLaunchUrl(shareUrl)) {
                             await launchUrl(shareUrl, mode: LaunchMode.externalApplication);
                           }
                           break;
                         case 'schedule':
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule Meeting Clicked')));
                           break;
                       }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'call',
                        child: ListTile(
                          leading: Icon(Icons.phone, color: Color(0xFFC61C2C)),
                          title: Text('Phone Call'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'whatsapp',
                        child: ListTile(
                          leading: Icon(Icons.message, color: Colors.green), // WhatsApp Color or Red as per design
                          title: Text('WhatsApp Message'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: ListTile(
                          leading: Icon(Icons.share, color: Color(0xFFC61C2C)),
                          title: Text('Share on WhatsApp'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'schedule',
                        child: ListTile(
                          leading: Icon(Icons.calendar_today, color: Color(0xFFC61C2C)),
                          title: Text('Schedule Meeting'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
