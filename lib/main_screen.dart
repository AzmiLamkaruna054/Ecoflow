import 'package:flutter/material.dart';
import 'notifikasi.dart';
import 'dart:async';
import 'history.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:d_info/d_info.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class MainScreen extends StatelessWidget {
  void _goToNotificationsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotifikasiPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF041D31),
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('EcoFlow',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                  color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            onPressed: () {
              _goToNotificationsPage(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20.0),
            HeaderContent(),
            BarStatusSampah(),
            TampungSampahSekarang(),
            Riwayat(),
          ],
        ),
      ),
    );
  }
}

class HeaderContent extends StatefulWidget {
  @override
  _HeaderContentState createState() => _HeaderContentState();
}

class _HeaderContentState extends State<HeaderContent> {
  late Stream<DateTime> _dateTimeStream;
  late StreamController<DateTime> _controller;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _controller = StreamController<DateTime>();
    _dateTimeStream = _controller.stream;
    _startTimer();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      _controller.add(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hii,\nSelamat datang di aplikasi EcoFlow',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                        height: 8), // Tambahkan jarak antara teks dan tanggal
                    StreamBuilder<DateTime>(
                      stream: _dateTimeStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          String formattedDate =
                              DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                                  .format(snapshot.data!);
                          return Text(
                            formattedDate,
                            style: TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.w600),
                          );
                        } else {
                          return Text(
                              '.........................................................',
                              style: TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.w600));
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 30),
              Hero(
                tag: 'logo',
                child: Image.asset('images/ecoflow_logo.png', width: 70, height: 70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BarStatusSampah extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double maxLoad = 4.0;
    double load = 1.5;
    double value = (load / maxLoad) * 100;

    double maxCapacity = 1.8;
    double Capacity = 1.1;
    double valueCapacity = (Capacity / maxCapacity) * 100;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: EdgeInsets.all(16.0),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.7),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Penampungan Sampah',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: value / 100,
                    backgroundColor: Color(0xFFD9D9D9),
                    minHeight: 7.0,
                    borderRadius: BorderRadius.circular(4.0),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(getValueColor(value)),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${load.toStringAsFixed(0)} Kg / ${maxLoad.toStringAsFixed(0)} Kg',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.0),
            const Text(
              'Status Jaring Sampah',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: valueCapacity / 100,
                    minHeight: 7.0,
                    backgroundColor: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(4.0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        getValueColor(valueCapacity, isCapacity: true)),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${valueCapacity.toStringAsFixed(0)} %',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.0),
          ],
        ),
      ),
    );
  }
}

class TampungSampahSekarang extends StatelessWidget {
  const TampungSampahSekarang({Key? key});

  _customProgress(BuildContext context) async {
    ProgressDialog pd = ProgressDialog(context: context);

    /// show the state of preparation first.
    pd.show(
      max: 100,
      msg: 'Menyiapkan...',
      progressType: ProgressType.valuable,
      backgroundColor: Colors.white,
      progressValueColor: Color.fromARGB(255, 29, 47, 111),
      progressBgColor: Colors.white12,
      msgColor: Colors.black,
      valueColor: Colors.black45,
      barrierColor: Colors.black.withOpacity(0.7),
      valueFontWeight: FontWeight.w600
    );

    /// Added to test late loading starts
    await Future.delayed(Duration(milliseconds: 3000));
    for (int i = 0; i <= 100; i++) {
      /// You can indicate here that the download has started.
      pd.update(value: i, msg: 'Mengangkat Sampah...');
      i++;
      await Future.delayed(Duration(milliseconds: 100));
    }

    pd.close();

    // Show success dialog
    DInfo.dialogSuccess(context, 'Sampah berhasil diangkat');
    DInfo.closeDialog(context, durationBeforeClose: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: EdgeInsets.all(16.0),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.7),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.black45,
                  size: 30.0,
                ),
                SizedBox(height: 15),
                Text(
                  'Tampung Sampah Sekarang',
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
              ],
            ),
            GestureDetector(
              onTap: () async {
                bool? isYes = await DInfo.dialogConfirmation(
                  context,
                  'Tampung Sampah Sekarang?',
                  'Apakah anda yakin ingin mengambil sampah?',
                );
                if (isYes ?? false) {
                  // print('user click yes');
                  _customProgress(context);
                } else {
                  // print('user click no');
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                margin: EdgeInsets.all(0),
                child: SizedBox(
                  width: 84,
                  height: 60,
                  child: Center(
                    child: Icon(
                      // Icons.power_settings_new_rounded,
                      Icons.power_settings_new_sharp,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Riwayat extends StatelessWidget {
  const Riwayat({Key? key}) : super(key: key);

  // Data riwayat
  static const List<Map<String, dynamic>> Data = [
    {'tanggal': 'Kamis 21/03/2024', 'berat': '1.5 Kg'},
    {'tanggal': 'Rabu 20/03/2024', 'berat': '2.0 Kg'},
    {'tanggal': 'Kamis 21/03/2024', 'berat': '1.5 Kg'},
    {'tanggal': 'Rabu 20/03/2024', 'berat': '2.0 Kg'},
    {'tanggal': 'Kamis 21/03/2024', 'berat': '1.5 Kg'},
    {'tanggal': 'Rabu 20/03/2024', 'berat': '2.0 Kg'},
    {'tanggal': 'Kamis 21/03/2024', 'berat': '1.5 Kg'},
    {'tanggal': 'Rabu 20/03/2024', 'berat': '2.0 Kg'},
    {'tanggal': 'Kamis 21/03/2024', 'berat': '1.5 Kg'},
    {'tanggal': 'Rabu 20/03/2024', 'berat': '2.0 Kg'},
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> limitedData = Data.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat buang sampah',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.history,
              ),
            ],
          ),
          SizedBox(height: 16.0),
          _buildTableHeader(),
          SizedBox(height: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: limitedData.map((item) {
              return _buildDataRow(item['tanggal'], item['berat']);
            }).toList(),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: InkWell(
                  onTap: () {
                    print("lihat Semua");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryPage(data: Data)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 8.0,
                          ),
                        ),
                        SizedBox(width: 3.0),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hari/Tanggal',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Jumlah/Kg',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String date, String weight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date,
          style: TextStyle(fontSize: 14.0),
        ),
        Text(
          weight,
          style: TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }
}

Color getValueColor(double value, {bool isCapacity = false}) {
  if (isCapacity) {
    if (value <= 45) {
      return Colors.green;
    } else if (value <= 80) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  } else {
    if (value <= 45) {
      return Colors.green;
    } else if (value <= 80) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
