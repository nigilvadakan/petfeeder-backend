import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EF),

      body: Stack(
        children: [

          // 🔥 FULL BACKGROUND GRADIENT (FIX FOR WHITE STRIP)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFC9A66B),
                  Color(0xFFE0C48F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                Expanded(
                  child: Column(
                    children: [

                      // 🔥 TOP HEADER (REMOVED GRADIENT FROM HERE ONLY)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(10, 10, 20, 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // 🔥 BACK ARROW INSIDE HEADER
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Hello",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              "Before using PawBite, please read and accept our Privacy Policy.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🔥 MAIN CONTENT CARD
                      Expanded(
                        child: Container(
                          transform: Matrix4.translationValues(0, -20, 0),
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                          ),
                          child: Column(
                            children: [

                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      const Text(
                                        "Privacy Policy",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      const Text(
                                        "Last updated: October 2026",
                                        style: TextStyle(color: Colors.black54),
                                      ),

                                      const SizedBox(height: 20),

                                      sectionText(
                                        "Welcome to PawBite – Smart Pet Feeder App. Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our application.",
                                      ),

                                      sectionTitle("1. Information We Collect"),

                                      bullet("Account Information",
                                          "We collect your email address and profile details."),

                                      bullet("Device & Feeding Data",
                                          "Feeding schedules, logs, and device status (food, water, battery)."),

                                      bullet("Usage Data",
                                          "App interaction data to improve experience."),

                                      sectionTitle("2. How We Use Your Information"),

                                      bullet("", "Automate feeding"),
                                      bullet("", "Sync with ESP32"),
                                      bullet("", "Notifications"),
                                      bullet("", "Improve app"),

                                      sectionTitle("3. Data Storage and Security"),

                                      sectionText(
                                          "Your data is securely stored using Firebase with industry-standard protection."),

                                      sectionTitle("4. Data Sharing"),

                                      sectionText(
                                          "We do NOT sell or share your personal data. Only trusted services like Firebase are used."),

                                      sectionTitle("5. Your Rights"),

                                      bullet("", "Access data"),
                                      bullet("", "Update data"),
                                      bullet("", "Delete account"),

                                      sectionTitle("6. Changes to This Policy"),

                                      sectionText(
                                          "We may update this policy periodically. Updates will be reflected in the app."),

                                      sectionTitle("7. Contact Us"),

                                      const Text(
                                        "📧 support@pawbite.com",
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),

                                      const SizedBox(height: 20),

                                      const Text(
                                        "Your trust is important to us. Thank you for using PawBite.",
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 🔥 BUTTONS
                              Row(
                                children: [

                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Decline",
                                          style: TextStyle(color: Colors.black54),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFC9A66B),
                                            Color(0xFFE0C48F),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Accept",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget bullet(String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text("• ", style: TextStyle(fontSize: 16)),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  if (title.isNotEmpty)
                    TextSpan(
                      text: "$title: ",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}