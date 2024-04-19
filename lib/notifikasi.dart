import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  // Daftar notifikasi
  final List<Map<String, String>> notifikasi = [
    {'judul': 'Notifikasi 1', 'deskripsi': 'Ini adalah contoh notifikasi 1'},
    {'judul': 'Notifikasi 2', 'deskripsi': 'Ini adalah contoh notifikasi 2'},
    {'judul': 'Notifikasi 3', 'deskripsi': 'Ini adalah contoh notifikasi 3'},
    {'judul': 'Notifikasi 4', 'deskripsi': 'Ini adalah contoh notifikasi 4'},
    {'judul': 'Notifikasi 5', 'deskripsi': 'Ini adalah contoh notifikasi 5'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF041D31),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ListView.builder(
        itemCount: notifikasi.length,
        itemBuilder: (context, index) {
          final notif = notifikasi[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
                title: Text(notif['judul']!),
                subtitle: Text(notif['deskripsi']!),
                minVerticalPadding: 0,
              ),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey[300],
              ),
            ],
          );
        },
      ),
    );
  }
}
