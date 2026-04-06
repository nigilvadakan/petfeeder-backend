import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ai_chat_page.dart';
import 'home_page.dart';
import 'pet_profile.dart';
import 'feeding_logs_page.dart';
import 'notification_page.dart';
import 'settings_page.dart';
class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),
    FeedingLogsPage(),
    AIChatPage(),
    PetProfilePage(),
    SettingsPage(),
  ];

  void _changeTab(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
  }

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.analytics_rounded,
   /// Icons.smart_toy_rounded,
    Icons.auto_awesome_rounded,
    Icons.pets_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double barWidth = constraints.maxWidth;
            final double itemWidth = barWidth / _icons.length;
            final double circleSize = 58;

            return Container(
              height: 74,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [

                  /// SLIDING CIRCLE
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    left: (_currentIndex * itemWidth) +
                        (itemWidth / 2) -
                        (circleSize / 2),
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFF28282B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  /// ICON ROW
                  Row(
                    children: List.generate(_icons.length, (index) {
                      final bool isSelected = _currentIndex == index;

                      return SizedBox(
                        width: itemWidth,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _changeTab(index),
                          child: Center(
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              scale: isSelected ? 1.15 : 1.0,
                              child: Icon(
                                _icons[index],
                                size: 26,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}