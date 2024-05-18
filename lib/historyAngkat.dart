import 'package:flutter/material.dart';

class HistoryAngkatPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  HistoryAngkatPage({required this.data});

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
          'Riwayat Angkat Sampah',
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
      body: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(
                label: Text('Hari/Tanggal',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Waktu',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Berat/Kg',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: data.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['tanggal'])),
                DataCell(Text(item['waktu'])),
                DataCell(Text(item['berat'])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
