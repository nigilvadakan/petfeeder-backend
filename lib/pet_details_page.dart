import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'bar.dart';
import 'package:google_fonts/google_fonts.dart';

class PetDetailsPage extends StatefulWidget {
  const PetDetailsPage({super.key});

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  final petNameController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String? selectedGender;

  static const Color primaryDark = Color(0xFF28282B);
  static const Color lightBg = Colors.white;


  Future<void> savePetDetails() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseDatabase.instance.ref("users/$uid/pet").set({
      "petName": petNameController.text,
      "breed": breedController.text,
      "age": ageController.text,
      "height": heightController.text,
      "weight": weightController.text,
      "gender": selectedGender,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomBar()),
    );
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: const TextStyle(
        color: primaryDark,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: primaryDark.withOpacity(0.3)),
      ),
      focusedBorder:  OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: primaryDark, width: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ✨ Script Style Heading
              Center(
                child: Text(
                  "Pet Info",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lobster(
                    fontSize: 34,
                    color: primaryDark,
                    letterSpacing: 1,
                  ),

                ),
              ),


              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Let’s personalize their journey",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: petNameController,
                decoration: buildInputDecoration("Pet Name"),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: breedController,
                decoration: buildInputDecoration("Breed"),
              ),
              const SizedBox(height: 20),

              // ✅ Gender as 3rd field (Dropdown)
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: buildInputDecoration("Gender"),
                items: const [
                  DropdownMenuItem(
                    value: "Male",
                    child: Text("Male"),
                  ),
                  DropdownMenuItem(
                    value: "Female",
                    child: Text("Female"),
                  ),

                ],
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration("Age"),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration("Height(cm)"),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration("Weight(kg)"),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: savePetDetails,
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
