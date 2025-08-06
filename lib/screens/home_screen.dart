import 'package:flutter/material.dart';
import 'package:recipedia/services/api_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:recipedia/Utils/constants.dart';
import 'my_app_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    super.initState();
    page = [
      const MyAppHomeScreen(),
      navBarPage(Iconsax.heart5),
      navBarPage(Iconsax.setting_21),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
                selectedIndex == 0 ? Iconsax.home5 : Iconsax.home_1),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
                selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
            label: "Favourite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
                selectedIndex == 2 ? Iconsax.setting_21 : Iconsax.setting_2),
            label: "Settings",
          ),
        ],
      ),
      body: page[selectedIndex],
    );
  }
  navBarPage(iconName) {
    return Center(
      child: Icon(iconName, size: 100, color: kPrimaryColor),
      );
  }
}




