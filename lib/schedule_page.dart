import 'package:flutter/material.dart';
import 'manual_feeding_page.dart';
import 'automatic_feeding_page.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  static const Color primaryDark = Color(0xFF28282B);
  static const Color bgColor = Color(0xFFF5F2EF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryDark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 18),

            /// 🔥 UPDATED TITLE (GOLD)
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: "Feeding ",
                    style: TextStyle(color: primaryDark),
                  ),
                  TextSpan(
                    text: "Schedule",
                    style: TextStyle(color: Color(0xFFC9A66B)), // ✅ GOLD
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Choose how you want to feed your pet",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 35),

            /// AUTOMATIC FEEDING CARD
            _ScheduleCard(
              icon: Icons.settings_suggest_rounded,
              title: "Automatic Feeding",
              iconColor: const Color(0xFF2F6EDB), // KEEP BLUE ICON
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AutomaticFeedingPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            /// MANUAL FEEDING CARD
            _ScheduleCard(
              icon: Icons.restaurant_menu_rounded,
              title: "Manual Feeding",
              iconColor: const Color(0xFFFFA000), // KEEP YELLOW ICON
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManualFeedingPage(),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  const _ScheduleCard({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,

      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 170),
        padding: const EdgeInsets.all(26),

        decoration: BoxDecoration(
          color: SchedulePage.bgColor, // ✅ NEURO BG
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(-4, -4),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ICON
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: SchedulePage.primaryDark,
              ),
            ),

          ],
        ),
      ),
    );
  }
}