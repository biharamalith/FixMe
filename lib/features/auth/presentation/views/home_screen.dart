import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fixme_new/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fixme_new/features/auth/presentation/views/category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = 'User';
  int _selectedIndex = 0;
  String featuredImageUrl = 'https://i.imgur.com/8z5K7.jpg';
  final List<Map<String, dynamic>> categories = [
    {'title': 'Plumbing', 'icon': 'assets/plumbing_icon.png'},
    {'title': 'Electrical', 'icon': 'assets/electrical_icon.png'},
    {'title': 'Cleaning', 'icon': 'assets/cleaning_icon.png'},
    {'title': 'Mechanic', 'icon': 'assets/mechanic_icon.png'},
    {'title': 'A/C Repair', 'icon': 'assets/ac_repair_icon.png'},
    {'title': 'Painter', 'icon': 'assets/painter_icon.png'},
    {'title': 'Meson', 'icon': 'assets/meson_icon.png'},
    {'title': 'Caregiver', 'icon': 'assets/caregiver_icon.png'},
    {'title': 'Home appliance repairing', 'icon': 'assets/home_appliance_icon.png'},
  ];
  final List<Map<String, dynamic>> allServiceProviders = [
    {'name': 'John Doe', 'category': 'Plumber', 'rating': 4.5},
    {'name': 'Jane Smith', 'category': 'Electrician', 'rating': 4.8},
    {'name': 'Alice Brown', 'category': 'Cleaner', 'rating': 4.2},
    {'name': 'Mike Johnson', 'category': 'Mechanic', 'rating': 4.7},
    {'name': 'Sarah Wilson', 'category': 'Plumber', 'rating': 4.9},
    {'name': 'Tom Clark', 'category': 'Electrician', 'rating': 4.3},
  ];
  List<Map<String, dynamic>> recommendedProviders = [];
  String? lastSearchedCategory;

  @override
  void initState() {
    super.initState();
    _fetchFirstName();
    _fetchFeaturedImage();
    _updateRecommendations();
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
        }
      } catch (e) {
        print('Error fetching firstName: $e');
      }
    }
  }

  Future<void> _fetchFeaturedImage() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('featured_image')
          .get();
      if (snapshot.exists) {
        setState(() {
          featuredImageUrl = snapshot.value.toString();
          print('Featured image URL: $featuredImageUrl');
        });
      } else {
        print('Featured image not found in database, using default URL');
        setState(() {
          featuredImageUrl = 'https://i.imgur.com/8z5K7.jpg';
        });
      }
    } catch (e) {
      print('Error fetching featured image: $e');
      setState(() {
        featuredImageUrl = 'https://i.imgur.com/8z5K7.jpg';
      });
    }
  }

  void _updateRecommendations() {
    if (lastSearchedCategory != null) {
      recommendedProviders = allServiceProviders
          .where((provider) =>
              provider['category'].toLowerCase() ==
              lastSearchedCategory!.toLowerCase())
          .toList();
      recommendedProviders.sort((a, b) => b['rating'].compareTo(a['rating']));
      if (recommendedProviders.length < 3) {
        final remainingProviders = allServiceProviders
            .where((provider) =>
                provider['category'].toLowerCase() !=
                lastSearchedCategory!.toLowerCase())
            .toList();
        remainingProviders.sort((a, b) => b['rating'].compareTo(a['rating']));
        recommendedProviders.addAll(
            remainingProviders.take(3 - recommendedProviders.length));
      }
    } else {
      recommendedProviders = List.from(allServiceProviders);
      recommendedProviders.sort((a, b) => b['rating'].compareTo(a['rating']));
      recommendedProviders = recommendedProviders.take(3).toList();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        if (authViewModel == null) {
          return const Scaffold(
            body: Center(child: Text('Error: AuthViewModel not found')),
          );
        }
        return Theme(
          data: Theme.of(context).copyWith(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1A3C34), // Force Forest Green
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A3C34), // Dark Green
              title: const Text(
                'FixMe',
                style: TextStyle(
                  fontFamily: 'londonbridgefontfamily',
                  fontSize: 25,
                  color: Color.fromARGB(255, 255, 251, 37),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notification');
                  },
                ),
              ],
              automaticallyImplyLeading: false,
              elevation: 0,
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: const Color(0xFF1A3C34), // Dark Green
                      width: double.infinity,
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'What are you looking for',
                              hintStyle: const TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.grey,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF1A3C34), // Dark Green
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1A3C34), // Dark Green
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1A3C34), // Dark Green
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1A3C34), // Dark Green
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onSubmitted: (value) {
                              if (categories.any((category) =>
                                  category['title'].toLowerCase() ==
                                  value.toLowerCase())) {
                                setState(() {
                                  lastSearchedCategory = value;
                                  _updateRecommendations();
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CategoryScreen(category: value),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Text(
                                'Hi $firstName',
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Color(0xFF1A3C34), // Dark Green
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '👋',
                                style: TextStyle(fontSize: 28),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Categories',
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF1A3C34), // Dark Green
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              alignment: WrapAlignment.center,
                              children: categories
                                  .map((category) => CategoryCard(
                                        title: category['title'],
                                        iconPath: category['icon'],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CategoryScreen(
                                                      category:
                                                          category['title']),
                                            ),
                                          );
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Recommendations',
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF1A3C34), // Dark Green
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...recommendedProviders.map((provider) =>
                              _buildServiceProviderCard(
                                  provider['name'],
                                  provider['category'],
                                  provider['rating'])),
                          const SizedBox(height: 32),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Featured',
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color(0xFF1A3C34), // Dark Green
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildFeaturedImage(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed, // Force fixed type
              backgroundColor: const Color(0xFF1A3C34), // Forest Green
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.book), label: 'Booking'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Profile'),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              onTap: _onItemTapped,
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceProviderCard(String name, String category, double rating) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFF1A3C34), // Dark Green
          child: Icon(Icons.person, size: 30, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3C34), // Dark Green
          ),
        ),
        subtitle: Text(
          category,
          style: const TextStyle(
            fontFamily: 'Roboto',
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Color(0xFF39FF14), // Spark Green (kept for stars)
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: Color(0xFF1A3C34), // Dark Green
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedImage() {
    return Container(
      width: 300,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Image.network(
              featuredImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child:
                      const Center(child: Text('Failed to load advertisement')),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  }) : super(key: key);

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5), // Flash White
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.iconPath,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 40,
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF1A3C34), // Dark Green
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}