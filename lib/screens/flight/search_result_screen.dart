import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart'; // Pastikan path benar
import '../../models/trip_model.dart'; // Pastikan path benar
import 'flight_booking_screen.dart'; // Pastikan path benar

class SearchResultScreen extends StatelessWidget {
  final String from;
  final String to;
  final DateTime date;
  final String seatClass;
  final int passengers;

  const SearchResultScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.seatClass,
    required this.passengers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Column(
          children: [
            Text("$from ➔ $to", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              "${DateFormat('d MMM yyyy').format(date)} • $passengers Penumpang",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('flights')
            .where('origin', isEqualTo: from)
            .where('destination', isEqualTo: to)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          // Jika ada data
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              // Konversi ke Model
              final trip = TripModel.fromJson(data, doc.id);

              return _buildFlightCard(context, trip);
            },
          );
        },
      ),
    );
  }

  // --- Widget Kartu Penerbangan ---
  Widget _buildFlightCard(BuildContext context, TripModel trip) {
    // 1. Format Jam
    final departureTime = DateFormat('HH:mm').format(trip.departureTime.toDate());
    final arrivalTime = DateFormat('HH:mm').format(trip.arrivalTime.toDate());
    
    // 2. Format Harga
    final price = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0).format(trip.price);

    // 3. Hitung Durasi (Fix error trip.duration)
    final durationDiff = trip.arrivalTime.toDate().difference(trip.departureTime.toDate());
    final String durationString = "${durationDiff.inHours}h ${durationDiff.inMinutes.remainder(60)}m";

    // 4. Buat Kode Bandara Dummy (Fix error trip.originCode)
    // Mengambil 3 huruf pertama dari nama kota dan di-uppercase
    final String originCode = trip.origin.length >= 3 ? trip.origin.substring(0, 3).toUpperCase() : trip.origin;
    final String destinationCode = trip.destination.length >= 3 ? trip.destination.substring(0, 3).toUpperCase() : trip.destination;

    return GestureDetector(
      onTap: () {
        // Navigasi ke Booking
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightBookingScreen(
              airline: trip.airline,
              from: trip.origin,
              to: trip.destination,
              time: "$departureTime - $arrivalTime",
              price: price,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
              children: [
                // Logo Maskapai
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.flight, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.airline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(seatClass, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Text(price, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Fix: Menggunakan variabel originCode buatan manual di atas
                _buildTimeColumn(departureTime, originCode), 
                
                const Icon(Icons.arrow_right_alt, color: Colors.grey),
                
                Column(
                  children: [
                    // Fix: Menggunakan variabel durationString buatan manual
                    Text(durationString, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Text("Direct", style: TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
                
                const Icon(Icons.arrow_right_alt, color: Colors.grey),
                
                // Fix: Typo "buildTimeColumn" -> "_buildTimeColumn"
                _buildTimeColumn(arrivalTime, destinationCode), 
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String time, String code) {
    return Column(
      children: [
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(code, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // Pastikan TIDAK ADA 'const' di sini
        children: [
          // 1. Ganti ikon jadi search_off dan HAPUS 'const'
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          
          // 2. Hapus 'const' di SizedBox
          SizedBox(height: 16),
          
          // 3. Text ini menggunakan variabel, jadi memang tidak boleh const
          Text(
            "Tidak ada penerbangan dari $from ke $to", 
            style: TextStyle(color: Colors.grey), // Hapus const
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 10),
          
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            // Hapus const
            child: Text("Cari Rute Lain"),
          )
        ],
      ),
    );
  }
} 