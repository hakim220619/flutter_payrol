import 'package:flutpayrol/cuti/cutiPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpServiceCuti {
  Future<void> addCuti(dari_tgl, sampai_tgl, gambar1, context) async {
    // print(imagePath);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('token');
    var url = Uri.parse('${dotenv.env['url']}/cuti');
    var request = http.MultipartRequest("POST", url);
    final imagepath1 = await http.MultipartFile.fromPath('bukti', gambar1);
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
  }
}
