import 'package:e_amazon/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_form_field.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final postalCode = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  buildTitle(title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      final data = doc.data();
      if (data != null) {
        nameController.text = data['name'] ?? user!.displayName ?? '';
        phoneController.text = data['phone'] ?? user!.phoneNumber ?? '';
        addressController.text = data['address'] ?? '';
        postalCode.text = data['postal_code'] ?? '';
      }
    }
  }

  Future<void> _updateProfile() async {
    if (formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'postal_code': postalCode.text.trim(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
          child: ElevatedButton(
            onPressed: _updateProfile,
            child: Text(
              "Update Profile",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
      appBar: AppBar(title: Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitle("Name"),
              CustomTextFormField(
                controller: nameController,
                hintText: 'Name',
                validator: (value) {
                  return Validator.requiredField(value);
                },
              ),
              SizedBox(height: 10.h),
              buildTitle("Phone number"),

              CustomTextFormField(
                controller: phoneController,
                hintText: 'Phone number',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  return Validator.validatePhoneNumber(value!);
                },
              ),
              SizedBox(height: 10.h),
              buildTitle("Address"),

              CustomTextFormField(
                controller: addressController,
                hintText: 'Address',
                validator: (value) {
                  return Validator.requiredField(value!);
                },
              ),
              SizedBox(height: 10.h),
              buildTitle("Postal code"),

              CustomTextFormField(
                controller: postalCode,
                hintText: 'Postal code',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  return Validator.requiredField(value!);
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
