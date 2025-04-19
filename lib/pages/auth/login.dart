import 'package:e_amazon/routes/app_routes.dart';
import 'package:e_amazon/utils/firebase_service.dart';
import 'package:e_amazon/utils/shared_preference.dart';
import 'package:e_amazon/utils/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/custom_form_field.dart';
import '../../widgets/default_button.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final firebaseAuth = FirebaseService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoad = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),

      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              children: [
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
                      text: 'Login',
                      onPressed: () async {
                        //firebaseAuth.addProduct();
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isLoad = true;
                          });

                          String? result = await firebaseAuth.login(
                            emailController.text,
                            passwordController.text,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Text("Signup"),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoad = true;
                    });
                    String result = await firebaseAuth.handleGoogleSignIn();
                    if (result == 'Success') {
                      Navigator.popAndPushNamed(context, AppRoutes.home);
                    }
                    setState(() {
                      isLoad = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://pngimg.com/uploads/google/google_PNG19635.png",
                          height: 25.h,
                          width: 25.h,
                        ),
                        Text(
                          "Continue with google",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
