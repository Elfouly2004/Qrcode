import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      print("Storage permission not granted.");
    }
  } else if (Platform.isIOS) {
    var status = await Permission.photosAddOnly.request();
    if (!status.isGranted) {
      print("Photos permission not granted.");
    }
  }
}

class QRCodeGenerator extends StatefulWidget {
  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  @override
  void initState() {
    super.initState();
    requestPermissions();  // Request permissions on app start
  }

  XFile? myPhoto;
  String? qrData;

  // Method to pick image from the camera
  Future<XFile?> pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    return image;
  }

  choosephoto() {
    pickImage().then((value) {
      setState(() {
        myPhoto = value;
        if (myPhoto != null) {
          compressImage();  // Compress the image after selection
        }
      });
    });
  }

  // Method to compress image
  Future<void> compressImage() async {
    var result = await FlutterImageCompress.compressWithFile(
      myPhoto!.path,
      minWidth: 50,  // Compress image width
      minHeight: 50,  // Compress image height
      quality: 60,  // Compress quality
    );

    if (result != null) {
      // Encode the compressed image to Base64 and assign it to qrData
      qrData = base64Encode(result);
      setState(() {});
    }
  }

  Future<void> saveQRCodeToGallery() async {
    if (qrData != null) {
      try {
        // Generate the QR code image from the data using QrImage
        final qrImage = QrImageView(
          data: qrData!,
          size: 200.0,
        );

        // Convert the QR image to a widget and render it to an image
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(200, 200)));
        qrImage.paint(canvas, Size(200, 200)); // Paint the QR code on the canvas
        final picture = recorder.endRecording();
        final img = await picture.toImage(200, 200); // Render the image

        // Convert the QR image to bytes
        final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
        final buffer = byteData!.buffer.asUint8List();

        // Get the app's document directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/qr_code.png';

        // Save the image to a file
        final file = File(filePath);
        await file.writeAsBytes(buffer);

        // After saving locally, request permission to write to gallery
        await _saveToGallery(file);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Code saved to gallery!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No QR Code generated')),
      );
    }
  }

  // Method to move file to gallery
  Future<void> _saveToGallery(File file) async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = Directory('/storage/emulated/0/Pictures/');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final newFile = await file.copy('${directory.path}/qr_code.png');
        print("Image saved to gallery at: ${newFile.path}");
      }
    } else if (Platform.isIOS) {
      // iOS-specific gallery saving code (this requires additional native code)
      print('For iOS, save to gallery requires custom native code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate QR Code')),
      body: SingleChildScrollView(  // Allow scrolling of content
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,  // Use MainAxisSize.min for compact sizing
            children: [
              ElevatedButton(
                onPressed: choosephoto,
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              myPhoto != null
                  ? Image.file(File(myPhoto!.path), height: 200)
                  : Text('No image selected'),
              SizedBox(height: 20),
              qrData != null
                  ? Flexible(
                fit: FlexFit.loose,  // Use Flexible with FlexFit.loose
                child: QrImageView(
                  data: qrData!,
                  size: 200.0,
                  version: QrVersions.auto,
                ),
              )
                  : Text('Generate QR Code after selecting an image'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: saveQRCodeToGallery,
                child: Text('Save QR Code to Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
