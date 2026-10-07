import 'package:flutter/material.dart';

import '../shared/placeholder_panel.dart';

/// Buyer shell with the role-specific bottom navigation:
/// Home/Explore - Search/Categories - My Orders/Cart - Chats/Calls - Profile
class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const PlaceholderPanel(
        title: 'Home & Explore',
        description:
            'Industrial product feed, verified sellers and live RFQ discovery - populated from /api/v1/products and /api/v1/sellers.',
      ),
      const PlaceholderPanel(
        title: 'Search & Categories',
        description:
            'Full catalog search with categories and similar-product suggestions - populated from /api/v1/catalogs/items.',
      ),
      const PlaceholderPanel(
        title: 'My Orders & RFQs',
        description:
            'Your B2B orders, proforma/tax invoices and cart - populated from the existing commerce routes (PI -> UTR -> TI).',
      ),
      const PlaceholderPanel(
        title: 'Chats & Calls',
        description:
            'Direct chat, voice call bridge and Google Meet sessions with sellers - populated from /api/v1/messages and the Twilio/Meet routes.',
      ),
      const PlaceholderPanel(
        title: 'Profile',
        description:
            'Your buyer profile, KYC status and account settings - synced with /api/v1/auth/sync-user.',
      ),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
