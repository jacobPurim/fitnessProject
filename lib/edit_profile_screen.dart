import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  String _selectedGender = "Male";
  File? _pickedImage;
  bool _isLoading = false;
  bool _isPickingImage = false; // 1. เพิ่มตัวแปรเช็คสถานะการเลือกรูป

  @override
  void initState() {
    super.initState();
    final user = widget.userData;
    _nameController = TextEditingController(text: user['name']);
    _emailController = TextEditingController(text: user['email']);
    _ageController = TextEditingController(text: user['age'].toString());
    _weightController = TextEditingController(text: user['weight'].toString());
    _heightController = TextEditingController(text: user['height'].toString());
    _selectedGender = user['gender'] ?? "Male";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // 2. แก้ไขฟังก์ชันเลือกรูปภาพ
  Future<void> _pickImage() async {
    // ถ้ากำลังเลือกรูปอยู่ ให้หยุดทำงานทันที (ป้องกันการกดรัว)
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true); // ล็อกไว้ก่อน

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      debugPrint("Pick image error: $e");
      // อาจจะแสดง SnackBar บอกผู้ใช้ถ้าจำเป็น
    } finally {
      // ปลดล็อกเมื่อทำงานเสร็จ (ไม่ว่าจะสำเร็จหรือ Error)
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var uri = Uri.parse("http://10.0.2.2/flutter_api/update_profile.php");
      var request = http.MultipartRequest("POST", uri);

      request.fields['user_id'] = widget.userData['id'].toString();
      request.fields['name'] = _nameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['age'] = _ageController.text.trim();
      request.fields['weight'] = _weightController.text.trim();
      request.fields['height'] = _heightController.text.trim();
      request.fields['gender'] = _selectedGender;

      if (_pickedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _pickedImage!.path,
        ));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);

      if (data['success'] == true) {
        String newImage = (data['profile_image'] != null && data['profile_image'] != "")
            ? data['profile_image']
            : widget.userData['profile_image'];

        int w = int.tryParse(_weightController.text) ?? 0;
        int h = int.tryParse(_heightController.text) ?? 0;
        double newBmi = (h > 0) ? w / ((h / 100) * (h / 100)) : 0.0;

        Map<String, dynamic> updatedData = {
          "id": widget.userData['id'],
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "gender": _selectedGender,
          "age": int.tryParse(_ageController.text) ?? 0,
          "weight": w,
          "height": h,
          "profile_image": newImage,
          "bmi": newBmi,
        };

        if (mounted) {
          Navigator.pop(context, updatedData);
        }
      } else {
        _showError(data['message'] ?? "Update failed");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    String oldImage = widget.userData['profile_image'] ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!) as ImageProvider
                          : (oldImage.isNotEmpty
                              ? NetworkImage("http://10.0.2.2/flutter_api/uploads/profile/$oldImage")
                              : null),
                      child: (_pickedImage == null && oldImage.isEmpty)
                          ? const Icon(Icons.person, size: 60, color: Colors.white54)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        // 3. เรียกใช้ฟังก์ชันที่แก้ไขแล้ว
                        onTap: _isPickingImage ? null : _pickImage, 
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: _isPickingImage 
                             // แสดง loading เล็กๆ ถ้ากำลังเปิด Gallery
                             ? const SizedBox(
                                 width: 20, 
                                 height: 20, 
                                 child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                               )
                             : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField("Full Name", _nameController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField("Age", _ageController, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("Weight (kg)", _weightController, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("Height (cm)", _heightController, isNumber: true)),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Gender", style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _genderOption("Male", Icons.male),
                  const SizedBox(width: 16),
                  _genderOption("Female", Icons.female),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _genderOption(String gender, IconData icon) {
    bool isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.redAccent : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: Colors.red, width: 2) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(gender, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}