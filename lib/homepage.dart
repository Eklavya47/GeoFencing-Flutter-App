import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_1/location.dart';
import 'package:test_1/maps.dart';
// Make sure this path matches your project structure

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${user!.email}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.to(const MyLocation()), // This is the button to location.dart
              child: const Text("Go to Location"),
            ),
            ElevatedButton(
              onPressed: () => Get.to(const MapExample()), // This is the button to location.dart
              child: const Text("Go to maps"),
            ),
          
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: signout,
        child: const Icon(Icons.logout_rounded), // Changed icon to logout for clarity
      ),
    );
  }
}