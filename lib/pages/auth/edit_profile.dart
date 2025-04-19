import 'package:e_amazon/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/user_data.dart';
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
  final postalCodeController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Widget buildTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        final userProfile = UserProfileModel.fromFirestore(doc.data()!, user!.uid);
        nameController.text = userProfile.name.isNotEmpty ? userProfile.name : user!.displayName ?? '';
        phoneController.text = userProfile.phone.isNotEmpty ? userProfile.phone : user!.phoneNumber ?? '';
        addressController.text = userProfile.address;
        postalCodeController.text = userProfile.postalCode;
      } else {
        nameController.text = user!.displayName ?? '';
        phoneController.text = user!.phoneNumber ?? '';
      }
    }
  }

  Future<void> _updateProfile() async {
    if (formKey.currentState!.validate()) {
      final userProfile = UserProfileModel(
        uid: user!.uid,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        postalCode: postalCodeController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set(userProfile.toJson(), SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
        width: MediaQuery.sizeOf(context).width,
        child: ElevatedButton(
          onPressed: _updateProfile,
          child: Text(
            "Update Profile",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ),
      ),
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitle("Name"),
              CustomTextFormField(
                controller: nameController,
                hintText: 'Name',
                validator: (value) => Validator.requiredField(value),
              ),
              SizedBox(height: 10.h),
              buildTitle("Phone number"),
              CustomTextFormField(
                controller: phoneController,
                hintText: 'Phone number',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => Validator.validatePhoneNumber(value!),
              ),
              SizedBox(height: 10.h),
              buildTitle("Address"),
              CustomTextFormField(
                controller: addressController,
                hintText: 'Address',
                validator: (value) => Validator.requiredField(value!),
              ),
              SizedBox(height: 10.h),
              buildTitle("Postal code"),
              CustomTextFormField(
                controller: postalCodeController,
                hintText: 'Postal code',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => Validator.requiredField(value!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}