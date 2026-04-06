import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPawbitePage extends StatelessWidget {
  const AboutPawbitePage({super.key});

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // 🔥 SAME APPBAR STYLE AS HELP PAGE
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              const Text(
                "About PawBite",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Smart feeding, simplified care",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 25),

              _sectionTitle("What is PawBite?"),
              _card([
                _item(Icons.pets,
                    "PawBite is an IoT-based smart pet feeder that automates feeding and helps monitor your pet’s daily nutrition with ease."),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("Key Features"),
              _card([
                _item(Icons.schedule, "Automated feeding schedules"),
                _item(Icons.analytics, "Real-time food & water monitoring"),
                _item(Icons.notifications, "Smart alerts & notifications"),
                _item(Icons.devices, "ESP32 device integration"),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("Why PawBite?"),
              _card([
                _item(Icons.favorite, "Ensures consistent feeding habits"),
                _item(Icons.access_time, "Saves time for busy pet owners"),
                _item(Icons.security, "Reliable and secure data handling"),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("Technology"),
              _card([
                _item(Icons.memory, "ESP32-based IoT system"),
                _item(Icons.cloud, "Firebase Realtime Database"),
                _item(Icons.phone_android, "Flutter mobile application"),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("Contact"),
              _card([
                _clickableItem(
                  Icons.email,
                  "support@pawbite.com",
                ),
              ]),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 EMAIL FUNCTION
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@pawbite.com',
      query: 'subject=PawBite Inquiry&body=Hello PawBite Team,',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  // 🔷 SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: primaryText,
        ),
      ),
    );
  }

  // 🔷 CARD (SAME STYLE)
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

  // 🔷 NORMAL ITEM
  Widget _item(IconData icon, String text) {
    return ListTile(
      leading: _iconBox(icon),
      title: Text(text),
    );
  }

  // 🔷 CLICKABLE ITEM (EMAIL)
  Widget _clickableItem(IconData icon, String text) {
    return ListTile(
      onTap: _sendEmail,
      leading: _iconBox(icon),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  // 🔷 ICON STYLE (GOLD + NEUMORPHISM)
  Widget _iconBox(IconData icon) {
    return Container(
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
    );
  }
}