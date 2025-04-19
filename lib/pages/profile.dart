import 'package:e_amazon/utils/shared_preference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final auth = FirebaseAuth.instance;

  Future logOutDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(
              "EAmazon",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            content: Text(
              'Are you sure want to logout?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'No',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  auth.signOut();
                  SharedPreferenceHelper.clear();
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName(AppRoutes.splash),
                  );
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
                color: Theme.of(context).colorScheme.primary,
                child: Text(
                  'Yes',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
    return true;
  }

  customTrailingIcon() {
    return Icon(
      Icons.arrow_forward_ios_sharp,
      color: Colors.grey.shade500,
      size: 18,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              },
              child: ListTile(
                leading: Icon(
                  Icons.person_outline_sharp,
                  color: Theme.of(context).primaryColor,
                ),

                title: Text('Edit Profile'),
                trailing: customTrailingIcon(),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.wishlist);
              },
              child: ListTile(
                leading: Icon(
                  Icons.favorite_border,
                  color: Theme.of(context).primaryColor,
                ),

                title: Text('Wishlist'),
                trailing: customTrailingIcon(),
              ),
            ),
            GestureDetector(
              onTap: () {
                logOutDialog();
              },
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Sign Out'),
                trailing: customTrailingIcon(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
