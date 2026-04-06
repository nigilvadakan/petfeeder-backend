import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 NEW

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> {

  final user = FirebaseAuth.instance.currentUser;

  bool isEditing = false;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  // 🔥 IMAGE VARIABLES
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // 🔥 LOAD IMAGE ON START
  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');

    if (path != null) {
      setState(() {
        _image = File(path);
      });
    }
  }

  // 🔥 PICK + SAVE IMAGE
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('profile_image', pickedFile.path);

      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  String getUsername() {
    if (user != null && user!.email != null) {
      return user!.email!.split('@').first;
    }
    return "User";
  }

  Future<void> changePassword() async {
    try {
      if (newPasswordController.text != confirmPasswordController.text) {
        showSnack("Passwords do not match");
        return;
      }

      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPasswordController.text.trim(),
      );

      await user!.reauthenticateWithCredential(cred);
      await user!.updatePassword(newPasswordController.text.trim());

      showSnack("Password updated successfully");

    } catch (e) {
      showSnack("Error: ${e.toString()}");
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {

    final username = getUsername();
    final email = user?.email ?? "";

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

              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Account ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // normal
                      ),
                    ),
                    TextSpan(
                      text: "Profile",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC9A66B), // 🔥 highlight (gold)
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Manage your account details",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 25),

              // 🔥 AVATAR + CHANGE BUTTON
              Center(
                child: Column(
                  children: [

                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      backgroundImage:
                      _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Text(
                        username[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                          : null,
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: pickImage,
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          color: Color(0xFFC9A66B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  username,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),

              Center(
                child: Text(
                  email,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),

              const SizedBox(height: 25),

              neuItem(Icons.person, "Username", username),
              neuItem(Icons.email, "Email", email),
              neuItem(Icons.lock, "Password", "********"),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() => isEditing = true);
                  },
                  child: const Text(
                    "Manage Account",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (isEditing) buildEditSection(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget neuItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F2EF),
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
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFFC9A66B),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditSection() {
    return Column(
      children: [

        input(currentPasswordController, "Current Password"),
        input(newPasswordController, "New Password"),
        input(confirmPasswordController, "Confirm Password"),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // 🔥 SAVE BUTTON (BLACK)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () async {
                await changePassword();
                setState(() => isEditing = false);
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),

            // 🔥 CANCEL BUTTON (BLACK TEXT)
            TextButton(
              onPressed: () {
                setState(() => isEditing = false);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }


  Widget input(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EF), // match bg
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: const Offset(-4, -4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}