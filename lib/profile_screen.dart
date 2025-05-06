import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Player';
  String _email = 'example@gmail.com';
  String _number = '+91 1234567890';
  String? _profilePicturePath;

  void _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Player';
    });
  }

  void _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email') ?? 'example@gmail.com';
    });
  }
  void _loadNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _number = prefs.getString('number') ?? '+91 1234567890';
    });
  }

  void _loadProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profilePicturePath = prefs.getString('profilePicture');
    });
  }

  Future<void> _pickProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profilePicture', image.path);

      setState(() {
        _profilePicturePath = image.path; // Update the UI with the new profile picture
      });
    }
  }
  
  @override
  void initState() {
    super.initState();
    _loadName();
    _loadEmail();
    _loadProfilePicture();
    _loadNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ); // Go back to the home screen
          },
        ),
        title: Text(_userName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickProfilePicture, // Open image picker to select a new profile picture
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicturePath != null
                    ? FileImage(File(_profilePicturePath!))
                    : const AssetImage('assets/images/img_1.png') as ImageProvider,
                backgroundColor: Colors.grey,
              ),
            ),
            // const CircleAvatar(
            //   radius: 50,
            //   backgroundImage: AssetImage('assets/images/img_1.png'), // Replace with your image asset
            // ),
            const SizedBox(height: 22),
            TextField(
              controller: TextEditingController(text: _userName),
              decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              onChanged: (value) {
                // Save the changed name in local storage
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('userName', value);
                });
              // Handle name change logic here
              },
            ),
            //
            const SizedBox(height: 30),
            TextField(
              controller: TextEditingController(text: _email),
              decoration: const InputDecoration(
              labelText: 'E-mail',
              border: OutlineInputBorder(),
              ),
              style:const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              onChanged: (value) {
                // Save the changed name in local storage
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('email', value);
                });
              // Handle email change logic here
              },
            ),
            const SizedBox(height: 30),
            TextField(
              controller: TextEditingController(text: _number),
              decoration: const InputDecoration(
              labelText: 'Mobile Number',
              border: OutlineInputBorder(),
              ),
              style:const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              onChanged: (value) {
                // Save the changed name in local storage
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('number', value);
                });
              // Handle email change logic here
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add your logout logic here
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}