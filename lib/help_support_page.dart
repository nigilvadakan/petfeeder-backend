import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 🔥 NEW

import 'package:firebase_auth/firebase_auth.dart'; // 🔥 NEW
import 'package:firebase_database/firebase_database.dart';
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

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
                "Help & Support",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Get help with your smart feeder and app",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 25),

              _sectionTitle("Common Issues"),
              _card([
                _item(context, Icons.wifi_off, "Device not connecting",
                    "Ensure your feeder and phone are connected to the same WiFi network. Restart your ESP32 device and check if WiFi credentials were entered correctly."),

                _item(context, Icons.schedule, "Feeding not triggering",
                    "Verify that your feeding schedule is saved correctly. Also ensure the device has power and is connected to the internet."),

                _item(context, Icons.sync_problem, "App not syncing",
                    "Pull down to refresh or restart the app. Check your internet connection and ensure Firebase services are reachable."),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("Troubleshooting"),
              _card([
                _item(context, Icons.wifi, "Check WiFi connection",
                    "Make sure your phone and feeder are on the same network. Avoid using mobile data during setup."),

                _item(context, Icons.restart_alt, "Restart feeder device",
                    "Power off your ESP32 feeder, wait a few seconds, and turn it back on to reset the connection."),

                _item(context, Icons.settings, "Verify feeding schedule",
                    "Check if the correct time and portion size are set. Ensure there are no overlapping schedules."),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("FAQs"),
              _card([
                _item(context, Icons.help_outline, "How to reset the device?",
                    "Press and hold the reset button on your feeder for 5–10 seconds until the indicator light blinks."),

                _item(context, Icons.edit_calendar, "How to change feeding schedule?",
                    "Go to the scheduling page, update the time or portion, and save changes."),

                _item(context, Icons.notifications, "Why am I not receiving alerts?",
                    "Check notification permissions in your phone settings and ensure alerts are enabled in the app."),
              ]),

              const SizedBox(height: 25),

              _sectionTitle("Contact Support"),
              _card([
                _item(context, Icons.email, "support@pawbite.com",
                    "You can email us anytime. Our support team will respond within 24 hours."),

                _item(context, Icons.feedback, "Send Feedback",
                    "We value your feedback! Share your experience to help us improve PawBite."),
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
      query: 'subject=PawBite Support&body=Describe your issue...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  // 🔥 FEEDBACK POPUP
  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Send Feedback",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Write your feedback...",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A66B), // 🔥 GOLD
                ),
                onPressed: () async {

                  final text = controller.text.trim();

                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter feedback")),
                    );
                    return;
                  }

                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    final uid = user?.uid ?? "anonymous";

                    final dbRef = FirebaseDatabase.instance.ref();

                    await dbRef
                        .child("feedback")
                        .child(uid)
                        .push()
                        .set({
                      "message": text,
                      "email": user?.email ?? "anonymous",
                      "timestamp": DateTime.now().toIso8601String(),
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Feedback sent!")),
                    );

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white), // 🔥 WHITE
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // 🔷 POPUP FUNCTION
  void _showHelpDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),

              const SizedBox(height: 10),

              Text(description, textAlign: TextAlign.center),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Got it"),
              ),
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
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: primaryText)),
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
              blurRadius: 6),
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 8),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String desc) {
    return ListTile(
      onTap: () {
        if (title == "support@pawbite.com") {
          _sendEmail(); // 🔥 EMAIL
        } else if (title == "Send Feedback") {
          _showFeedbackDialog(context); // 🔥 FEEDBACK
        } else {
          _showHelpDialog(context, title, desc);
        }
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
                blurRadius: 4),
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 4),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFC9A66B)),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}