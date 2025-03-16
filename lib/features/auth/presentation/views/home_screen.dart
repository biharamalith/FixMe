import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = 'User';
  int _selectedIndex = 0; // Track the selected bottom navigation item

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the respective screen based on the index
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
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.yellow,
            title: Image.asset(
              'assets/fixmelogo.png', // Replace with your logo image path
              height: 40, // Adjust height as needed to fit your logo
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.grey),
                onPressed: () {
                  Navigator.pushNamed(context, '/notification');
                },
              ),
            ],
            automaticallyImplyLeading: false, // Remove the back arrow
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reduced yellow container (only for spacing, no content inside)
                Container(
                  color: const Color(0xFFFFE730),
                  width: double.infinity,
                  height: 8, // Reduced height to make it smaller
                ),
                // White content section with greeting
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'What are you looking for',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Greeting moved below the search bar
                      Row(
                        children: [
                          Text(
                            'Hi $firstName',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '👋',
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCategoryIcon('Plumbing', Icons.plumbing),
                          _buildCategoryIcon('Electrical', Icons.electrical_services),
                          _buildCategoryIcon('Cleaning', Icons.cleaning_services),
                          _buildCategoryIcon('Carpentry', Icons.handyman),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Service Providers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildServiceProviderCard('John Doe', 'Plumber', 4.5),
                      _buildServiceProviderCard('Jane Smith', 'Electrician', 4.8),
                      _buildServiceProviderCard('Alice Brown', 'Cleaner', 4.2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
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
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildServiceProviderCard(String name, String category, double rating) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.yellow, size: 20),
            const SizedBox(width: 4),
            Text(rating.toString()),
          ],
        ),
      ),
    );
  }
}