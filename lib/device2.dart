// import 'dart:io';
// import 'package:flutter/material.dart';
// // import 'package:qr_code_scanner/qr_code_scanner.dart';
// // import 'package:dio/dio.dart';
// // import 'package:path_provider/path_provider.dart';
//
// class QRCodeScanner extends StatefulWidget {
//   @override
//   _QRCodeScannerState createState() => _QRCodeScannerState();
// }
//
// class _QRCodeScannerState extends State<QRCodeScanner> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   // QRViewController? controller;
//   String? imageUrl;
//   File? downloadedImage;
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _downloadImage(String url) async {
//     try {
//       final dio = Dio();
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath =
//           '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final response = await dio.download(url, filePath);
//
//       if (response.statusCode == 200) {
//         setState(() {
//           downloadedImage = File(filePath);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error downloading image: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan QR Code')),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 5,
//             child: QRView(
//               key: qrKey,
//               onQRViewCreated: (QRViewController controller) {
//                 this.controller = controller;
//                 controller.scannedDataStream.listen((scanData) {
//                   setState(() {
//                     imageUrl = scanData.code;
//                   });
//                   controller.pauseCamera();
//                   _downloadImage(imageUrl!);
//                 });
//               },
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (downloadedImage != null)
//                   Image.file(downloadedImage!, height: 200)
//                 else
//                   Text(imageUrl != null ? 'Image URL: $imageUrl' : 'Scan a QR Code'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
