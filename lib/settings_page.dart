import 'package:flutter/material.dart';
import 'account_profile_page.dart';
import 'privacy_policy_page.dart';
import 'help_support_page.dart';
import 'about_pawbite_page.dart';
import 'activity_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing_page.dart';
import 'wifi_setup_page.dart';
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDark = false;
  bool notifications = true;
  bool refill = true;

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
          (route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout(context);
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,

      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 1),

              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Manage your account and device preferences",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 25),

              _sectionTitle("General"),
              _card([
                _item(Icons.person, "Account Profile", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AccountProfilePage()));
                }),
                _item(Icons.lock, "Privacy Policy", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
                }),
                _item(Icons.help_outline, "Help & Support", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HelpSupportPage()));
                }),
                _item(Icons.info_outline, "About PawBite", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutPawbitePage()));
                }),
                _item(Icons.bar_chart, "My Activity", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ActivityPage()));
                }),
              ]),

              const SizedBox(height: 25),

              /// 🔥 UPDATED APPEARANCE
              _sectionTitle("Appearance"),
              _card([
                _switchItem(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  isDark ? "Light Mode" : "Dark Mode",
                  isDark,
                      (v) {
                    setState(() => isDark = v);
                  },
                ),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("Device"),
              _card([
                _deviceTile(),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("Notifications"),
              _card([
                _switchItem(Icons.notifications, "Enable Notifications", notifications, (v) {
                  setState(() => notifications = v);
                }),
                _switchItem(Icons.warning, "Refill Alerts", refill, (v) {
                  setState(() => refill = v);
                }),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("About"),
              _card([
                _item(Icons.info, "App Version 1.0.0", () {},),

              ]),

              const SizedBox(height: 30),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A66B), // 🔥 GOLD BACKGROUND
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6), // 🔥 softer highlight
                        offset: const Offset(-3, -3),
                        blurRadius: 6,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white, // 🔥 WHITE TEXT
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),



              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: primaryText)),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(children: children),
    );
  }

  Widget _item(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFC9A66B)),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  /// 🔥 UPDATED SWITCH
  Widget _switchItem(
      IconData icon, String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,

      activeColor: const Color(0xFF8B7E74),
      activeTrackColor: const Color(0xFF8B7E74).withOpacity(0.4),

      inactiveThumbColor: Colors.grey.shade400,
      inactiveTrackColor: Colors.grey.shade300,

      secondary: Icon(
        icon,
        color: title == "Light Mode" ? Colors.black : Colors.brown,
      ),

      title: Text(title),
    );
  }

  Widget _deviceTile() {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WifiSetupPage(),
          ),
        );
      },
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.memory, color: Colors.green),
      ),
      title: const Text("ESP32 - Feeder"),
      subtitle: const Text("Tap to setup WiFi"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}