import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutpayrol/cuti/cutiPage.dart';
import 'package:flutpayrol/cuti/serviceCuti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadGaji extends StatefulWidget {
  const DownloadGaji({Key? key}) : super(key: key);

  @override
  _DownloadGajiState createState() => _DownloadGajiState();
}

class _DownloadGajiState extends State<DownloadGaji> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // ignore: override_on_non_overriding_member
  String? imagePath1;
  String? filePath;

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  TextEditingController dari_tgl = TextEditingController();
  TextEditingController sampai_tgl = TextEditingController();

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Download gaji'),
              leading: IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
            body: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Form(
                key: _formKey,
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: true,
                            controller: dari_tgl,
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: 'Pilih Tanggal'),
                            validator: (value) {
                              if (value == false)
                                return 'Silahkan Pilih Tanggal';
                              return null;
                            },
                            onTap: () async {
                              DateFormat('dd/mm/yyyy').format(DateTime.now());
                              var date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100));
                              if (date == null) {
                                dari_tgl.text = "";
                              } else {
                                dari_tgl.text = date.toString().substring(0, 7);
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                // print(dari_tgl.text);
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                var token = preferences.getString('token');
                                var url =
                                    Uri.parse('${dotenv.env['url']}/slip-gaji');
                                final response = await http.post(url, headers: {
                                  "Accept": "application/json",
                                  "Authorization": "Bearer $token",
                                }, body: {
                                  'yearMonth': dari_tgl.text
                                });
                                // print(response.body);
                                if (response.statusCode == 200) {
                                  final data = jsonDecode(response.body);
                                  // print(data['file_path']);
                                  setState(() async {
                                    String url = data['file_path'];
                                    var urllaunchable = await canLaunch(url); //canLaunch is from url_launcher package
                                    if (urllaunchable) {
                                      await launch(
                                          url); //launch is from url_launcher package to launch URL
                                    } else {
                                      print("URL can't be launched.");
                                    }
                                  });
                                }
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 1, vertical: 10),
                              child: const Center(
                                child: Text(
                                  "Download",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(9, 107, 199, 1),
                                  borderRadius: BorderRadius.circular(10)),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
