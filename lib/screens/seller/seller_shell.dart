import 'package:flutter/material.dart';

import '../shared/placeholder_panel.dart';

/// Seller shell with the role-specific bottom navigation:
/// Dashboard (stats) - Manage Products - Orders/Leads - Chats/Calls - Profile
class SellerShell extends StatefulWidget {
  const SellerShell({super.key});

  @override
  State<SellerShell> createState() => _SellerShellState();
}

class _SellerShellState extends State<SellerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const PlaceholderPanel(
        title: 'Seller Dashboard',
        description:
            'Live sales stats, conversion analytics and lead-credit balance - populated from /api/v1/sellers/:id/analytics/conversions and credits.',
      ),
      const PlaceholderPanel(
        title: 'Manage Products',
        description:
            'Your catalog listings: create, edit and publish products - populated from /api/v1/products and /api/v1/catalogs/items.',
      ),
      const PlaceholderPanel(
        title: 'Orders & Leads',
        description:
            'Matched RFQ leads, unlocking and order management - populated from /api/v1/sellers/:id/leads/matched and /api/v1/leads.',
      ),
      const PlaceholderPanel(
        title: 'Chats & Calls',
        description:
            'Buyer conversations, quotes, voice bridge and Meet sessions - populated from /api/v1/messages and Twilio/Meet routes.',
      ),
      const PlaceholderPanel(
        title: 'Profile',
        description:
            'Company profile, KYC, staff and subscription - synced with the existing seller routes.',
      ),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.leaderboard_outlined), selectedIcon: Icon(Icons.leaderboard), label: 'Leads'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
