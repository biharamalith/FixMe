// lib/features/auth/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = 'User'; // Default name until fetched

  @override
  void initState() {
    super.initState();
    _fetchFirstName();
  }

  Future<void> _fetchFirstName() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref('users/${firebaseUser.uid}/firstName')
            .get();
        if (snapshot.exists) {
          setState(() {
            firstName = snapshot.value.toString();
          });
        } else {
          print('No firstName found for UID: ${firebaseUser.uid}');
        }
      } catch (e) {
        print('Error fetching firstName: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('FixMe Fresh'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await authViewModel.signOut();
                  if (authViewModel.user == null) {
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hi $firstName',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '👋',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for a service...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCategoryIcon('Plumbing', Icons.plumbing),
                      _buildCategoryIcon('Electrical', Icons.electrical_services),
                      _buildCategoryIcon('Cleaning', Icons.cleaning_services),
                      _buildCategoryIcon('Carpentry', Icons.handyman),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Service Providers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildServiceProviderCard('John Doe', 'Plumber', 4.5),
                  _buildServiceProviderCard('Jane Smith', 'Electrician', 4.8),
                  _buildServiceProviderCard('Alice Brown', 'Cleaner', 4.2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(String title, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[100],
          child: Icon(icon, size: 30, color: Colors.blue),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildServiceProviderCard(String name, String category, double rating) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.yellow, size: 20),
            SizedBox(width: 4),
            Text(rating.toString()),
          ],
        ),
      ),
    );
  }
}