import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ Pastikan import ini sesuai dengan struktur folder Anda
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../models/destination_model.dart';
import '../flight/flight_screen.dart';
import '../profile_screen.dart';

// ✅ Pastikan file ini ada dan nama class di dalamnya adalah 'TripHistoryScreen'
import '../flight/trip_history_screen.dart'; 

// ✅ WIDGET: Import widget kartu destinasi
import '../../widgets/popular_destination.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "Traveler";
  UserModel? _currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.instance.getStoredUser();
    if (mounted && user != null) {
      setState(() {
        _currentUser = user;
        _userName = user.name;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0: 
        break; // Home (Diam di tempat)
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FlightScreen()));
        break;
      case 2:
        // ✅ FITUR AKTIF: Navigasi ke Halaman History
        // Pastikan nama class di file trip_history_screen.dart adalah TripHistoryScreen
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TripHistoryScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Background sedikit lebih terang
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER
              _buildHeader(),
              const SizedBox(height: 24),

              // 2. SEARCH BAR
              _buildSearchBar(),
              const SizedBox(height: 24),

              // 3. KATEGORI (Hanya Flight & More)
              _buildCategories(),
              const SizedBox(height: 32),

              // 4. POPULAR DESTINATION (Vertikal & Lebih Menarik)
              _buildPopularDestinationsSection(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back,",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E2C),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        // Container Profile dengan Shadow
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FlightScreen()));
        },
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: AppColors.primary.withOpacity(0.7), size: 26),
          hintText: "Where do you want to go?",
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.tune_rounded, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    Widget categoryItem(IconData icon, String label, Color color, VoidCallback onTap, {bool isPrimary = false}) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isPrimary ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                    BoxShadow(
                      color: isPrimary ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.08), 
                      blurRadius: 12, 
                      offset: const Offset(0, 6)
                    ),
                ],
              ),
              child: Icon(icon, color: isPrimary ? Colors.white : color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              label, 
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 13,
                color: Colors.grey[800]
              )
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        categoryItem(Icons.flight_takeoff_rounded, "Flights", AppColors.primary, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FlightScreen()));
        }, isPrimary: true), 
        
        const SizedBox(width: 40), 
        
        categoryItem(Icons.grid_view_rounded, "More", Colors.grey, () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu lainnya segera hadir")));
        }),
      ],
    );
  }

  Widget _buildPopularDestinationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Popular Destinations",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              onPressed: (){}, 
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text("See All"),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            )
          ],
        ),
        const SizedBox(height: 6),
        Text("Discover your next adventure", style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
        
        // StreamBuilder untuk data destinasi
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('destinations').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Text("No destinations found yet."),
              );
            }

            // ListView.builder Vertikal
            return ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final destination = DestinationModel.fromSnapshot(doc);
                
                return PopularDestinationCard(destination: destination);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white, 
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0, 
          items: [
            _buildNavBarItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
            _buildNavBarItem(Icons.flight_rounded, Icons.flight_outlined, 'Flight', 1),
            _buildNavBarItem(Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Orders', 2),
            _buildNavBarItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(index == _selectedIndex ? activeIcon : inactiveIcon),
      label: label,
    );
  }
}