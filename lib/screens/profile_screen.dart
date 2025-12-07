import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Pastikan path benar
import '../constants/colors.dart'; // Pastikan path benar

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Loading...";
  String _userEmail = "...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 FUNGSI: Mengambil Data User
  Future<void> _loadUserData() async {
    final userModel = await AuthService.instance.getStoredUser();
    
    if (mounted) {
      setState(() {
        if (userModel != null) {
          _userName = userModel.name;
          _userEmail = userModel.email;
        } else {
          final currentUser = FirebaseAuth.instance.currentUser;
          _userName = currentUser?.displayName ?? "Pengguna";
          _userEmail = currentUser?.email ?? "email@example.com";
        }
      });
    }
  }

  // 🔹 FUNGSI: Logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              await FirebaseAuth.instance.signOut(); // Logout Firebase
              if (mounted) {
                // Kembali ke Login & Hapus semua history route
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.blueAccent; // Sesuaikan dengan AppColors.primary

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===========================
            // 1. HEADER & FOTO & BACK BUTTON
            // ===========================
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background Biru
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: const [
                        Text(
                          "Profil Saya",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔙 TOMBOL KEMBALI (BACK BUTTON)
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),

                // Foto Profil
                Positioned(
                  bottom: -50,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // ===========================
            // 2. INFO USER
            // ===========================
            Text(
              _userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              _userEmail,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Gold Member",
                style: TextStyle(
                  color: Colors.orange, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 12
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ===========================
            // 3. MENU AKTIF
            // ===========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSectionHeader("Akun"),
                  _buildMenuContainer([
                    _buildMenuItem(
                      icon: Icons.person_outline, 
                      text: "Edit Profil", 
                      // 🟢 Navigasi ke Edit Profil
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.credit_card, 
                      text: "Metode Pembayaran", 
                      // 🟢 Navigasi ke Pembayaran
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PaymentMethodScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.history, 
                      text: "Riwayat Transaksi", 
                      // 🟢 Navigasi ke History
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen())),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildSectionHeader("Umum"),
                  _buildMenuContainer([
                    _buildMenuItem(
                      icon: Icons.settings_outlined, 
                      text: "Pengaturan", 
                      // 🟢 Navigasi ke Pengaturan
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline, 
                      text: "Bantuan & Support", 
                      // 🟢 Navigasi ke Bantuan
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpSupportScreen())),
                    ),
                    _buildMenuItem(
                      icon: Icons.logout, 
                      text: "Keluar", 
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      isLast: true,
                      onTap: _handleLogout,
                    ),
                  ]),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("Versi Aplikasi 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.blueAccent,
    Color textColor = Colors.black87,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ),
        if (!isLast) 
          const Padding(
            padding: EdgeInsets.only(left: 70, right: 20),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
      ],
    );
  }
}

// =========================================================
// 👇 HALAMAN SEMENTARA (Agar Navigasi Berfungsi) 👇
// =========================================================

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: const Center(child: Text("Halaman Edit Profil")),
    );
  }
}

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Metode Pembayaran")),
      body: const Center(child: Text("Halaman Pembayaran")),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: const Center(child: Text("Halaman Riwayat")),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: const Center(child: Text("Halaman Pengaturan")),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bantuan & Support")),
      body: const Center(child: Text("Halaman Bantuan")),
    );
  }
}