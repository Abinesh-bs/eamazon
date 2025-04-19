import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalNotifierProvider = ChangeNotifierProvider<GlobalProvider>((ref) {
  return GlobalProvider(ref);
});

class GlobalProvider extends ChangeNotifier {
  Ref ref;
  GlobalKey<ScaffoldState>? scaffoldKey;
  String deviceType = "android";
  int userId = 0;
  bool isLoading = false;
  String timezone = 'Asia/Kolkata';
  BuildContext? context;
  String address = "";
  String postalCode = "";
  List<String> selectedCategories = [];

  GlobalProvider(this.ref);

  rebuildApp() {
    notifyListeners();
  }
}
