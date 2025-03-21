import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = 'User';
  String hometown = '';
  String phoneNumber = '';
  bool isEditing = false;

  final _firstNameController = TextEditingController();
  final _hometownController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref('users/${firebaseUser.uid}')
            .get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            firstName = data['firstName']?.toString() ?? 'User';
            hometown = data['hometown']?.toString() ?? '';
            phoneNumber = data['phoneNumber']?.toString() ?? '';
            _firstNameController.text = firstName;
            _hometownController.text = hometown;
            _phoneNumberController.text = phoneNumber;
          });
        }
      } catch (e) {
        print('Error fetching user details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: $e')),
        );
      }
    }
  }

  Future<void> _updateUserDetails() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // Validate inputs
      if (_firstNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('First name cannot be empty')),
        );
        return;
      }

      try {
        await FirebaseDatabase.instance
            .ref('users/${firebaseUser.uid}')
            .update({
          'firstName': _firstNameController.text.trim(),
          'hometown': _hometownController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
        });
        setState(() {
          firstName = _firstNameController.text.trim();
          hometown = _hometownController.text.trim();
          phoneNumber = _phoneNumberController.text.trim();
          isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print('Error updating user details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _hometownController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: const Color(0xFF1A3C34), // Consistent with your app's theme
            actions: [
              IconButton(
                icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.white),
                onPressed: () {
                  if (isEditing) {
                    _updateUserDetails();
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await authViewModel.signOut();
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F5F5), // Flash White
                  Color(0xFFE0E0E0), // Slightly darker white
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Profile',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Color(0xFF1A3C34),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!isEditing) ...[
                    _buildProfileField('First Name', firstName),
                    const SizedBox(height: 10),
                    _buildProfileField('Hometown', hometown.isEmpty ? 'Not set' : hometown),
                    const SizedBox(height: 10),
                    _buildProfileField('Phone Number', phoneNumber.isEmpty ? 'Not set' : phoneNumber),
                  ] else ...[
                    _buildTextField(_firstNameController, 'First Name'),
                    const SizedBox(height: 20),
                    _buildTextField(_hometownController, 'Hometown'),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _phoneNumberController,
                      'Phone Number',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, 3),
        );
      },
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3C34),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF1A3C34)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A3C34)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A3C34)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A3C34), width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int selectedIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1A3C34),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/booking');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/chat');
            break;
          case 3:
            // Already on ProfileScreen
            break;
        }
      },
    );
  }
}