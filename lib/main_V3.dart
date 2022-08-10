//import 'dart:developer';
import 'dart:convert';
//import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //const myApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urdu Character Recognition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  //const MainScreen({Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future<void> captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      //debugPrint(image.path);
      //selectedImage = File(image.path);
      uploadImage(image);
    }
  }

  Future<void> selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      //debugPrint(image.path);
      uploadImage(image);
    }
  }

  // Future<void> fetchData() async {
  //   var url = Uri.parse("http://164.90.174.177/");
  //   var response = await http.get(url);
  //   print('Response body: ${response.body}');
  // }

  Future<void> uploadImage(image) async {
    http.MultipartRequest request = http.MultipartRequest(
        'POST', Uri.parse("http://10.0.2.2:5000/classifycharacter"));

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('application', 'jpeg'),
      ),
    );

    http.StreamedResponse r = await request.send();
    print(r.statusCode);
    print(await r.stream.transform(utf8.decoder).join());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Image"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                captureImage();
              },
              child: Text("Use Camera"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
              ),
            ),
            Container(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                selectImage();
              },
              child: Text("Use Gallery"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          postData();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),*/
    );
  }
}
