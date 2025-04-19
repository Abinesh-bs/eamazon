import 'dart:io';

import 'package:e_amazon/pages/add_to_card.dart';
import 'package:e_amazon/pages/products/product.dart';
import 'package:e_amazon/pages/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Widget> pages;
  int navIndex = 0;
  int index = 0;

  @override
  initState() {
    pages = [const Product(), AddToCard(), Profile()];
    navIndex = index;
    super.initState();
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).textSelectionTheme.selectionColor,
      currentIndex: navIndex,
      onTap: (index) {
        setState(() {
          navIndex = index;
        });
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.explore),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_cart_outlined),
          label: "Cart",
        ),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.profile_circled, size: 23),
          label: "Profile",
        ),
      ],
    );
  }

  Future _onWillPop() async {
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
              'Are you sure want to close app?',
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
                  Future.delayed(const Duration(milliseconds: 200), () {
                  exit(0);
                  });
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _onWillPop(),
      child: Scaffold(
        key: scaffoldKey,
        body: Stack(children: [pages.elementAt(navIndex)]),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
