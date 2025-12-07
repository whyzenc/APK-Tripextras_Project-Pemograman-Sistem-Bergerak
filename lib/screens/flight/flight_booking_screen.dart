import 'package:flutter/material.dart';
// import '../../../constants/colors.dart'; // Uncomment jika file sudah ada
// import '../../../routes/app_routes.dart'; // Uncomment jika routes sudah siap

class FlightBookingScreen extends StatefulWidget {
  final String airline;
  final String from;
  final String to;
  final String time;
  final String price;

  const FlightBookingScreen({
    super.key,
    required this.airline,
    required this.from,
    required this.to,
    required this.time,
    required this.price,
  });

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  
  // State untuk Dropdown Pembayaran
  String _selectedPayment = 'BCA Virtual Account';
  final List<String> _paymentMethods = [
    'BCA Virtual Account',
    'Mandiri Virtual Account',
    'BNI Virtual Account',
    'Credit Card (Visa/Master)',
    'E-Wallet (GoPay/OVO)'
  ];

  // State untuk Loading
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Fallback warna jika AppColors belum ada
    const Color primaryColor = Colors.blueAccent; 

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Konfirmasi Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 1. Kartu Detail Penerbangan
            _buildSectionLabel("Detail Penerbangan"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.airline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text("Economy Class", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(widget.price, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _flightInfo(widget.from, "Berangkat"),
                      const Icon(Icons.flight_takeoff, color: Colors.blueAccent),
                      _flightInfo(widget.to, "Tujuan"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Center(child: Text(widget.time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
                ],
              ),
            ),
            
            const SizedBox(height: 25),

            // 🔹 2. Form Data Penumpang
            _buildSectionLabel("Data Penumpang"),
            _buildTextField(nameController, 'Nama Lengkap (Sesuai KTP)', Icons.person),
            const SizedBox(height: 15),
            _buildTextField(idController, 'Nomor NIK / Paspor', Icons.card_membership),
            
            const SizedBox(height: 25),

            // 🔹 3. Metode Pembayaran
            _buildSectionLabel("Metode Pembayaran"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPayment,
                  isExpanded: true,
                  icon: const Icon(Icons.payment, color: primaryColor),
                  items: _paymentMethods.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPayment = newValue!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 4. Tombol Bayar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Catatan Kecil
            const Center(
              child: Text(
                "Dengan menekan tombol di atas, Anda menyetujui\nSyarat & Ketentuan maskapai.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Helper ---

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _flightInfo(String code, String label) {
    return Column(
      children: [
        Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  // --- Logic ---

  void _handleBooking() async {
    // 1. Validasi Input
    if (nameController.text.isEmpty || idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data penumpang!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Simulasi Loading
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Pura-pura connect server

    setState(() {
      _isLoading = false;
    });

    // 3. Tampilkan Dialog Sukses (Lebih aman daripada pushNamed jika route belum siap)
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Booking Berhasil!"),
          ],
        ),
        content: const Text(
          "Tiket elektronik telah dikirim ke email Anda.\nSilakan cek inbox.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog
              Navigator.pop(context); // Kembali ke list penerbangan
              Navigator.pop(context); // Kembali ke menu cari
            },
            child: const Text("Kembali ke Beranda"),
          ),
        ],
      ),
    );
    
    // Jika routes sudah siap, Anda bisa gunakan:
    // Navigator.pushNamed(context, AppRoutes.bookingSuccess);
  }
}