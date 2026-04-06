import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'landing_page.dart';

/// 🔥 ADDED IMPORTS
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetProfilePage extends StatefulWidget {
  const PetProfilePage({super.key});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {

  static const Color bgColor = Color(0xFFF5F2EF);
  static const Color primaryText = Color(0xFF2E2E2E);

  /// 🔥 IMAGE VARIABLES
  File? _petImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPetImage();
  }

  /// 🔥 LOAD IMAGE
  Future<void> _loadPetImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('pet_image');

    if (path != null) {
      setState(() {
        _petImage = File(path);
      });
    }
  }

  /// 🔥 PICK IMAGE
  Future<void> _pickPetImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pet_image', pickedFile.path);

      setState(() {
        _petImage = File(pickedFile.path);
      });
    }
  }

  void _showEditDialog(BuildContext context, Map data, String uid) {

    final nameController = TextEditingController(text: data["petName"]);
    final breedController = TextEditingController(text: data["breed"]);
    final genderController = TextEditingController(text: data["gender"]);
    final ageController = TextEditingController(text: data["age"].toString());
    final heightController =
    TextEditingController(text: data["height"].toString());
    final weightController =
    TextEditingController(text: data["weight"].toString());

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  const Text(
                    "Edit Pet Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  _editField("Name", nameController),
                  _editField("Breed", breedController),
                  _editField("Gender", genderController),
                  _editField("Age", ageController),
                  _editField("Height", heightController),
                  _editField("Weight", weightController),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseDatabase.instance
                              .ref("users/$uid/pet")
                              .update({
                            "petName": nameController.text,
                            "breed": breedController.text,
                            "gender": genderController.text,
                            "age": int.parse(ageController.text),
                            "height": double.parse(heightController.text),
                            "weight": double.parse(weightController.text),
                          });

                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("Save"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
      ),

      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseDatabase.instance.ref("users/$uid/pet").onValue,
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final event = snapshot.data as DatabaseEvent;

            if (event.snapshot.value == null) {
              return const Center(child: Text("No Pet Profile Found"));
            }

            final data = Map<String, dynamic>.from(
                event.snapshot.value as Map);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 1),

                  /// HEADER
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Pet ",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC9A66B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// 🔥 ONLY CHANGE HERE (avatar now supports image)
                  Center(
                    child: Column(
                      children: [

                        GestureDetector(
                          onTap: _pickPetImage,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bgColor,
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
                            child: _petImage != null
                                ? ClipOval(
                              child: Image.file(
                                _petImage!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                                : const Icon(
                              Icons.pets_rounded,
                              size: 60,
                              color: primaryText,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          data["petName"] ?? "Pet Name",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  _sectionTitle("Details"),
                  _card([
                    _item(Icons.category, "Breed", data["breed"]),
                    _item(Icons.person, "Gender", data["gender"]),
                    _item(Icons.cake, "Age", data["age"]),
                    _item(Icons.height, "Height(cm)", data["height"]),
                    _item(Icons.monitor_weight, "Weight(kg)", data["weight"]),
                  ]),

                  const SizedBox(height: 25),

                  Center(
                    child: GestureDetector(
                      onTap: () => _showEditDialog(context, data, uid),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A66B),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
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
                        child: const Text(
                          "Edit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
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

  Widget _item(IconData icon, String title, dynamic value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFC9A66B)),
      title: Text(title),
      trailing: Text(value?.toString() ?? "-"),
    );
  }

  static Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}