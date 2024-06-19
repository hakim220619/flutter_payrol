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

class AddCutiPage extends StatefulWidget {
  const AddCutiPage({Key? key}) : super(key: key);

  @override
  _AddCutiPageState createState() => _AddCutiPageState();
}

class _AddCutiPageState extends State<AddCutiPage> {
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
  void checkPermissionAndOpenFilePicker() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      openFilePicker();
    } else {
      if (await Permission.storage.request().isGranted) {
        openFilePicker();
      } else {
        // Handle denied permissions
        print("Permission denied by user.");
      }
    }
  }

  void openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // File picked successfully
      File file = File(result.files.single.path!);
      setState(() {
        filePath = file.path;
      });

      // print(file);
      // uploadFile(file); // Call your API function here
    } else {
      // User canceled the picker
      print("User canceled the file picker.");
    }
  }

  void uploadFile(File file) async {
    try {
      print(file);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/cuti');
      var request = http.MultipartRequest("POST", url);
      final imagepath1 = await http.MultipartFile.fromPath('bukti', file.path);
      // print(imagepath);
      request.fields['dari_tgl'] = dari_tgl.text;
      request.fields['sampai_tgl'] = sampai_tgl.text;
      request.files.add(imagepath1);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'multipart/form-data';

      final response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const CutiPage(),
        ),
      );
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Tambah Cuti'),
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
                                hintText: 'Dari Tanggal'),
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
                                dari_tgl.text =
                                    date.toString().substring(0, 10);
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: true,
                            controller: sampai_tgl,
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: 'Sampai Tanggal'),
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
                                sampai_tgl.text = "";
                              } else {
                                sampai_tgl.text =
                                    date.toString().substring(0, 10);
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        filePath == null
                            ? Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shadowColor:
                                        const Color.fromARGB(255, 0, 0, 0),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32.0)),
                                    minimumSize: Size(300, 40), //////// HERE
                                  ),
                                  onPressed: openFilePicker,
                                  child: Text("Open File Picker"),
                                ),
                              )
                            : Text('$filePath'),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                // print(filePath);
                                await HttpServiceCuti().addCuti(
                                    dari_tgl, sampai_tgl, filePath, context);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 1, vertical: 10),
                              child: const Center(
                                child: Text(
                                  "Simpan",
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
