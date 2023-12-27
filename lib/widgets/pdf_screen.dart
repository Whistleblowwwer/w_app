import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:w_app/styles/color_style.dart';

class PDFScreen extends StatefulWidget {
  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    fromAsset('assets/terminos.pdf', 'terminos.pdf').then((f) {
      setState(() {
        pathPDF = f.path;
      });
    });
  }

  Future<File> fromAsset(String asset, String filename) async {
    // Prepara el temporal directory
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    // Carga el archivo
    ByteData bd = await rootBundle.load(asset);
    var bytes = bd.buffer.asUint8List();

    // Guarda como archivo
    File file = File('$tempPath/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos de servicio'),
      ),
      body: pathPDF == ""
          ? const Center(
              child: CircularProgressIndicator(
              backgroundColor: ColorStyle.grey, // Fondo del indicador
              valueColor: AlwaysStoppedAnimation<Color>(ColorStyle.darkPurple),
            ))
          : PDFView(
              filePath: pathPDF,
              enableSwipe: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onPageChanged: (int? page, int? total) {
                print('page change: $page/$total');
                setState(() {});
              },
            ),
    );
  }
}
