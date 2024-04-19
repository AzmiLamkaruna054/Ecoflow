import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const HistoryPage({Key? key, required this.data}) : super(key: key);

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
          'Riwayat Buang Sampah',
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
        child: Center(
          child: DataTable(
            dataRowMinHeight: 30,
            dataRowMaxHeight: 30,
            columnSpacing: MediaQuery.of(context).size.width * 0.4,
            horizontalMargin: 0,
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Hari/Tanggal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Jumlah/Kg',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: data.map((item) {
              return DataRow(
                cells: <DataCell>[
                  DataCell(Text(item['tanggal'])),
                  DataCell(Text(item['berat'])),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
