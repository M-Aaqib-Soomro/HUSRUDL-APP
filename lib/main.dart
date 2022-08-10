// Importing the required packages
//import 'dart:developer';
import 'dart:convert';
//import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clipboard/clipboard.dart';

// Define Dart main function body
void main() {
  // Run the flutter app
  runApp(MyApp());
}

// Define the flutter main app class
// The calss MyApp is inherited from StatelessWidget of Flutter
// Stateless means that, everything on the page that we are going to build, will stay static
// And the content on the page is not able to be changed
class MyApp extends StatelessWidget {
  //const myApp({Key? key}) : super(key: key);

  // Create a Widget
  // A class can have only one Widget
  // It is overriding the Widget prebuilt in the StatelessWidget Class
  @override
  Widget build(BuildContext context) {
    // Return the app's structure
    // We can then implement more screens in this app
    return MaterialApp(
      // Set title of the app
      title: 'Urdu Character Recognition',
      // Flag the app as not in debug mode
      // Which means, the app is in production mode
      debugShowCheckedModeBanner: false,
      // Define the theme of the app
      theme: ThemeData(
        // Assign the Deep Purple color palette
        primaryColor: Colors.deepPurple,
      ),
      // Now, as the home screen, assign the MainScreen class which is defined below this class
      home: MainScreen(),
    );
  }
}

// Define the class MainScreen which will be loaded as soon as the user opens the app
class MainScreen extends StatelessWidget {
  //const MainScreen({Key? key}) : super(key: key);

  // Create an instance of the Image Picker
  final ImagePicker _picker = ImagePicker();
  // Create a variable of type File that will store image
  File? selectedImage;

  // Define a Future function captureImage
  // It will allow the user to capture a new image using their phone camera
  // It is of Future type because it is an asynchronous task, and takes time to be done
  Future<void> captureImage(BuildContext context) async {
    // Create an image variable of type XFile
    // It opens camera for the user to capture an image, and returns the image upon capturing
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    // Check if an image was captured or not
    if (image != null) {
      // If yes, assign it to selectedImage
      selectedImage = File(image.path);
      // Send to the uploadImage method to upload the image to the server
      uploadImage(selectedImage, context);
    }
  }

  // Define a Future function selectImage
  // It will allow the user to select an image from their phone gallery
  // It is of Future type because it is an asynchronous task, and takes time to be done
  Future<void> selectImage(BuildContext context) async {
    // Create an image variable of type XFile
    // It opens gallery for the user to select an image, and returns the image upon selection
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    // Check if an image was selected or not
    if (image != null) {
      // Send to the uploadImage method to upload the image to the server
      uploadImage(image, context);
    }
  }

  // Define a Future function uploadImage
  // It will accept an image object, and upload it to the server
  // It is of Future type because it is an asynchronous task, and takes time to be done
  Future<void> uploadImage(image, context) async {
    // Define url variable, and assign the API endpoint to it
    final url = "http://10.0.2.2:5000/classifycharacter";

    // Create an http request object
    // Request method will be POST
    // And data type will be Multipart which supports any kind of files to upload
    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(url));

    // Add the image to the request
    // Define the request data to be image, and image as JPEG
    // Set the path to the image
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('application', 'jpeg'),
      ),
    );

    // Send the request and wait for the response
    http.StreamedResponse r = await request.send();

    final output = await r.stream.transform(utf8.decoder).join();

    print(output);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Output(output)),
    );
  }

  // Create a Widget
  // This will be the main screen on the landing page
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold that defines the basic home screen structure according to the phone
    return Scaffold(
      // Set the AppBar on top of the screen
      appBar: AppBar(
        // Set the title of the current page
        title: Text("Select Image"),
      ),
      // Define the body of the page
      // Align all the contents of the body to Center
      body: Center(
        // Create a Column child of the body
        // Column will have multiple children aligned vertically
        child: Column(
          // Set x-axis alignment of the Column to center
          mainAxisAlignment: MainAxisAlignment.center,
          // Set y-axis alignment of the Column to center
          crossAxisAlignment: CrossAxisAlignment.center,

          // Define the children list
          // It will contain more widgets
          children: [
            // Define an ElevatedButton for Capture Image, which is raised a bit up on the screen
            ElevatedButton(
              // Run this block of code when the button is pressed
              onPressed: () {
                // Call the Capture Image function
                captureImage(context);
              },

              // The child of this button will be a Text on the button
              child: Text("Use Camera"),

              // Set styles to the button
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
              ),
            ),

            // Define an empty container for space between the two buttons
            Container(
              height: 10,
            ),

            // Define another ElavatedButton for Select Image
            ElevatedButton(
              // Run this block of code when the button is pressed
              onPressed: () {
                // Call the Capture Image function
                selectImage(context);
              },

              // The child of this button will be a Text on the button
              child: Text("Use Gallery"),

              // Set styles of the button
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Output extends StatelessWidget {
  //const Output({Key? key}) : super(key: key);

  final String classifiedOutput;

  Output(this.classifiedOutput);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Classified Text"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(classifiedOutput),
            ElevatedButton(
              onPressed: () {
                FlutterClipboard.copy(classifiedOutput);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text("Text copied successfully!")),
                );
              },
              child: Text("Copy"),
            ),
          ],
        ),
      ),
    );
  }
}
