import 'package:e_amazon/routes/app_routes.dart';
import 'package:e_amazon/utils/firebase_service.dart';
import 'package:e_amazon/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_form_field.dart';
import '../../widgets/default_button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final firebaseAuth = FirebaseService();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextFormField(
                  hintText: 'Full name',
                  controller: nameController,
                  validator: (value) {
                    return Validator.requiredField(value);
                  },
                ),
                CustomTextFormField(
                  hintText: 'Phone number',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: phoneController,
                  validator: (value) {
                    return Validator.validatePhoneNumber(value);
                  },
                ),
                CustomTextFormField(
                  hintText: 'Email',
                  controller: emailController,

                  validator: (value) {
                    return Validator.validateEmail(value);
                  },
                ),
                CustomTextFormField(
                  hintText: 'Password',
                  controller: passwordController,
                  validator: (value) {
                    return Validator.requiredField(value);
                  },
                ),

                isLoad
                    ? SizedBox(
                      height: 30.h,
                      width: 30.w,
                      child: CircularProgressIndicator(),
                    )
                    : DefaultButton(
                      text: 'Signup',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isLoad = true;
                          });
                          String? result = await firebaseAuth.register(
                            emailController.text,
                            passwordController.text,
                            nameController.text,
                            phoneController.text,
                          );
                          setState(() {
                            isLoad = false;
                          });
                          if (result != null) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(result)));
                          } else {
                            Navigator.popAndPushNamed(context, AppRoutes.home);
                          }
                        }
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
