import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fixme_new/features/auth/presentation/views/service_provider_profile_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> providers = [];
  List<Map<String, dynamic>> filteredProviders = [];
  final _locationSearchController = TextEditingController();
  String searchLocation = '';
  String userHometown = '';

  @override
  void initState() {
    super.initState();
    _fetchUserHometown();
    _fetchProviders();
  }

  Future<void> _fetchUserHometown() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref('users/${firebaseUser.uid}/hometown')
            .get();
        if (snapshot.exists) {
          setState(() {
            userHometown = snapshot.value.toString();
          });
        }
      } catch (e) {
        print('Error fetching user hometown: $e');
      }
    }
  }

  Future<void> _fetchProviders() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('service_providers')
          .child(widget.category.toLowerCase())
          .get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          providers = data.entries.map((entry) {
            return {
              'id': entry.key,
              'name': entry.value['name'] as String,
              'experience': entry.value['experience'] as num,
              'location': entry.value['location']?.toString() ?? 'Unknown',
            };
          }).toList();
          _filterAndSortProviders();
        });
      }
    } catch (e) {
      print('Error fetching providers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching providers: $e')),
      );
    }
  }

  void _filterAndSortProviders() {
    setState(() {
      // Filter by location search
      if (searchLocation.isEmpty) {
        filteredProviders = List.from(providers);
      } else {
        filteredProviders = providers
            .where((provider) => provider['location']
                .toLowerCase()
                .contains(searchLocation.toLowerCase()))
            .toList();
      }

      // Sort providers: same hometown first, then apply different sorting for hometown vs others
      filteredProviders.sort((a, b) {
        bool aInHometown =
            userHometown.isNotEmpty && a['location'].toLowerCase() == userHometown.toLowerCase();
        bool bInHometown =
            userHometown.isNotEmpty && b['location'].toLowerCase() == userHometown.toLowerCase();

        // Prioritize providers in the same hometown
        if (aInHometown && !bInHometown) return -1; // a comes first
        if (!aInHometown && bInHometown) return 1; // b comes first

        // If both providers are in the same hometown, sort by experience in ascending order
        if (aInHometown && bInHometown) {
          return (a['experience'] as num).compareTo(b['experience'] as num);
        }

        // If both providers are not in the same hometown, sort by experience in descending order
        if (!aInHometown && !bInHometown) {
          return (b['experience'] as num).compareTo(a['experience'] as num);
        }

        // This line should never be reached due to the above conditions, but added for completeness
        return 0;
      });
    });
  }

  @override
  void dispose() {
    _locationSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3C34),
        title: Text(
          widget.category,
          style: const TextStyle(
            fontFamily: 'londonbridgefontfamily',
            fontSize: 25,
            color: Color.fromARGB(255, 255, 251, 37),
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE0E0E0),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _locationSearchController,
                decoration: InputDecoration(
                  hintText: 'Search by location (e.g., New York)',
                  hintStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1A3C34),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A3C34),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A3C34),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A3C34),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    searchLocation = value;
                    _filterAndSortProviders();
                  });
                },
              ),
            ),
            Expanded(
              child: filteredProviders.isEmpty
                  ? const Center(
                      child: Text(
                        'No providers found for this category',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: Color(0xFF1A3C34),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredProviders.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceProviderProfileScreen(
                                  category: widget.category,
                                  providerId: filteredProviders[index]['id'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ListTile(
                              leading: const CircleAvatar(
                                radius: 25,
                                backgroundColor: Color(0xFF1A3C34),
                                child: Icon(Icons.person,
                                    size: 30, color: Colors.white),
                              ),
                              title: Text(
                                filteredProviders[index]['name'],
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                              subtitle: Text(
                                'Experience: ${filteredProviders[index]['experience']} years\nLocation: ${filteredProviders[index]['location']}',
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF1A3C34),
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 0),
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
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
    );
  }
}