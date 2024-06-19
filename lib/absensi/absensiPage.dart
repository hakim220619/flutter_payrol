import 'package:flutpayrol/home/HomePage.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

List _listsData = [];
String? name = '';
String? barcodeScanRes;

class _AbsensiPageState extends State<AbsensiPage> {
  Future<dynamic> listKeluhan() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/absen');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      // print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data);
        setState(() {
          _listsData = data['data'];
          name = preferences.getString('name');
          // print(_listsData);
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  // Sample data for three lists
  @override
  void initState() {
    super.initState();
    listKeluhan();
  }

  Future refresh() async {
    setState(() {
      listKeluhan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Absens',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Homepage()));
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(253, 255, 252, 252),
          ),
        ),
        backgroundColor: Colors.blue[300],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: _listsData.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "Nama: ${name}",
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "latitude : ${_listsData[index]['latitude']} longitude: ${_listsData[index]['longitude']}",
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          var token = preferences.getString('token');
          barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
              '#ff6666', 'Cancel', true, ScanMode.BARCODE);
          // print(barcodeScanRes);
          // setState(() {
          //   // if (res is String) {
          //   //   print(res.toString());
          //   // }
          // });
          // print(res);

          var url = Uri.parse('${dotenv.env['url']}/absen');
          final response = await http.post(url, headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          }, body: {
            "status": '1',
            "latitude": '-7.2905298',
            "longitude": '109.0310344',
          });
          // print(response.body);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print(data);
            setState(() async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const AbsensiPage(),
                ),
              );
            });
          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This tra
    );
  }
}
