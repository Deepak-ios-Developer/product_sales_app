import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../constants/common_strings.dart';

class ShareAsPDFButton extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double discountedPrice;

  // 👈 Added this

  const ShareAsPDFButton({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountedPrice,

    // 👈 Added this
  }) : super(key: key);

  Future<File> _generatePDF() async {
    final pdf = pw.Document();

    pw.MemoryImage? image;

    try {
      if (imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          image = pw.MemoryImage(response.bodyBytes);
        }
      }
    } catch (e) {
      print('Error loading image: $e');
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            if (image != null) pw.Center(child: pw.Image(image, height: 200)), // 👈 Add image if available
            pw.SizedBox(height: 20),
            pw.Text('${AppStrings.title}: $title'),
            pw.SizedBox(height: 10),
            pw.Text('${AppStrings.price}: \$$discountedPrice'),
            pw.SizedBox(height: 10),
            pw.Text('${AppStrings.description}: $description'),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/shared_detail.pdf");
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  void _showPdf(BuildContext context) async {
    final pdfFile = await _generatePDF();
    await Share.shareXFiles([XFile(pdfFile.path)], text: 'Sharing Product Detail as PDF');

  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: GestureDetector(
        onTap: () => _showPdf(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // Almost no color
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // Soft shadow
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159), // Flip horizontally
              child: Icon(
                Icons.reply, // Curved arrow icon
                color: Colors.black87, // Soft black color
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
