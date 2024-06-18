import 'dart:convert';
import 'dart:io';

import 'package:flutpayrol/cuti/cutiPage.dart';
import 'package:flutpayrol/cuti/serviceCuti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddCutiPage extends StatefulWidget {
  const AddCutiPage({Key? key}) : super(key: key);

  @override
  _AddCutiPageState createState() => _AddCutiPageState();
}


class _AddCutiPageState extends State<AddCutiPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // ignore: override_on_non_overriding_member
  String? imagePath1;

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
                        containerImageWidget1(context),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                               await HttpServiceCuti().addCuti(
                                    dari_tgl,
                                    sampai_tgl,
                                    imagePath1,                                   
                                    context);
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

  Widget containerImageWidget1(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final path = await chooseImage();
        setState(() {
          imagePath1 = path;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(.40)),
            borderRadius: BorderRadius.circular(4),
            image: imagePath1 != null
                ? DecorationImage(
                    image: FileImage(File(imagePath1!)), fit: BoxFit.cover)
                : null),
        child: Visibility(
            visible: imagePath1 == null ? true : false,
            child: const Text('Pilih')),
      ),
    );
  }
}

Future<String?> chooseImage() async {
  final ImagePicker picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery);
  return image!.path;
}
