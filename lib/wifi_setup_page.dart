import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WifiSetupPage extends StatefulWidget {
  const WifiSetupPage({super.key});

  @override
  State<WifiSetupPage> createState() => _WifiSetupPageState();
}

class _WifiSetupPageState extends State<WifiSetupPage> {
  final ssidController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;

  Future<void> sendWifi() async {
    final ssid = ssidController.text.trim();
    final password = passController.text.trim();

    if (ssid.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Enter WiFi name and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse(
      "http://192.168.4.1/save?s=$ssid&p=$password",
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to connect. Make sure you're connected to ESP32 WiFi"),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    ssidController.dispose();
    passController.dispose();
    super.dispose();
  }

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // 🔙 SAME BACK ARROW STYLE AS HELP PAGE
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
                "Setup ESP32 WiFi",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Connect your feeder to home network",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 25),

              // 🔥 INSTRUCTIONS CARD
              _card([
                _item(Icons.info_outline,
                    "Connect to device WiFi (PetFeeder_Setup)"),
                _item(Icons.wifi, "Enter your home WiFi details"),
                _item(Icons.play_arrow, "Tap Connect"),
              ]),

              const SizedBox(height: 25),

              // 🔥 INPUT CARD
              _card([
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: ssidController,
                    decoration: InputDecoration(
                      hintText: "WiFi Name (SSID)",
                      prefixIcon: const Icon(Icons.wifi, color: Color(0xFFC9A66B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFFC9A66B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 30),

              // 🔥 BUTTON (GOLD STYLE)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendWifi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A66B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Connect ESP32",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
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

  // 🔷 NEUMORPHIC CARD
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

  // 🔷 ICON TEXT ITEM
  Widget _item(IconData icon, String text) {
    return ListTile(
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
      title: Text(text),
    );
  }
}