import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';


import 'package:nav_bars/screens/pages/arena_radar_screen.dart';
import 'package:nav_bars/screens/pages/battle_market_screen.dart';
import 'package:nav_bars/screens/pages/leaderboard_screen.dart';
import 'package:nav_bars/screens/pages/my_battles_screen.dart';
import 'package:nav_bars/screens/pages/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 0; // Startujemy od Radaru
  late final PageController _pageController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPageIndex);
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: currentPageIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentPageIndex = index;
    });
    _tabController.animateTo(index);
  }

  void _onNavTap(int index) {
    setState(() => currentPageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: const [
          Icons.radar, 
          Icons.groups, 
          Icons.sports_mma, 
          Icons.emoji_events,
          Icons.settings
        ],
        activeIndex: currentPageIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        onTap: _onNavTap,
        activeColor: Theme.of(context).colorScheme.primary,
        inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),

      appBar: AppBar(
        title: const Text('USTAWKA.IO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),

      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          const ArenaRadarScreen(),
          const BattleMarketScreen(),
          const MyBattlesScreen(),
          const LeaderboardScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }
}
