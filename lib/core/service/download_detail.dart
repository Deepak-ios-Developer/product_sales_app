import 'package:flutter/material.dart';
import 'package:product_sale_app/core/themes/app_theme.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data' as typed;
import '../model/product_model.dart';
import '../common_widgets/app_loader.dart';

Future<void> generateAndSavePDF(BuildContext context, Products product) async {
  final pdf = pw.Document();
  
  // Helper to parse price from string format like "$26.00" or "$8.00 - $16.00"
  double parsePrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return 0.0;
    String cleaned = priceString.replaceAll(RegExp(r'[^\d.-]'), '');
    if (cleaned.contains('-')) {
      cleaned = cleaned.split('-')[0].trim();
    }
    return double.tryParse(cleaned) ?? 0.0;
  }
  
  // Get price from currentSku
  final double price = parsePrice(product.currentSku?.listPrice);
  final double salePrice = parsePrice(product.currentSku?.salePrice);
  final double currentPrice = salePrice > 0 ? salePrice : price;
  
  final double discount = price > 0 && currentPrice < price 
      ? ((price - currentPrice) / price * 100) 
      : 0.0;
  final double saveAmount = price - currentPrice;
  
  // Get image URL - use heroImage or first available image
  final String imageUrl = product.heroImage ?? 
                         product.image450 ?? 
                         product.image250 ?? 
                         product.image135 ?? 
                         '';
  
  // Get rating and reviews
  final double rating = double.tryParse(product.rating ?? '0') ?? 0.0;
  final int reviewsCount = int.tryParse(product.reviews ?? '0') ?? 0;
  
  try {
    // Show Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AppLoader(
        label: "Generating PDF...",
        indicatorSize: 20,
        indicatorColor: AppTheme.secondaryColor,
      ),
    );

    // Fetch the image for the PDF
    pw.ImageProvider? image;
    if (imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final typed.Uint8List imageBytes = response.bodyBytes;
          image = pw.MemoryImage(imageBytes);
        }
      } catch (e) {
        print('Error loading image: $e');
      }
    }

    // Add content to the PDF with professional styling
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              padding: pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.grey400,
                    width: 2,
                  ),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'PRODUCT DETAILS',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                    ),
                  ),
                  if (rating > 0)
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.amber,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        '⭐ ${rating.toStringAsFixed(1)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 30),
            
            // Product Image
            if (image != null)
              pw.Center(
                child: pw.Container(
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 1),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Image(
                    image,
                    width: 300,
                    height: 300,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
            
            pw.SizedBox(height: 30),
            
            // Brand Name
            if (product.brandName != null && product.brandName!.isNotEmpty)
              pw.Container(
                padding: pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  product.brandName!.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            
            // Product Title
            pw.Text(
              product.displayName ?? product.productName ?? 'No Title',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            
            pw.SizedBox(height: 10),
            
            // Product ID
            if (product.productId != null)
              pw.Container(
                padding: pw.EdgeInsets.only(bottom: 10),
                child: pw.Text(
                  'Product ID: ${product.productId}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            
            // Badges
            if (product.currentSku != null)
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (product.currentSku!.isNew ?? false)
                    _buildBadge('NEW', PdfColors.blue),
                  if (product.currentSku!.isSephoraExclusive ?? false)
                    _buildBadge('SEPHORA EXCLUSIVE', PdfColors.purple),
                  if (product.currentSku!.isLimitedEdition ?? false)
                    _buildBadge('LIMITED EDITION', PdfColors.red),
                  if (product.moreColors != null && product.moreColors! > 0)
                    _buildBadge('${product.moreColors} COLORS', PdfColors.pink),
                ],
              ),
            
            pw.SizedBox(height: 20),
            
            // Price Section
            pw.Container(
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PRICING',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '\$${currentPrice.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 32,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700,
                            ),
                          ),
                          if (discount > 0) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Original: \$${price.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey600,
                                decoration: pw.TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (discount > 0)
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.green,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            children: [
                              pw.Text(
                                '${discount.toStringAsFixed(0)}% OFF',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                              if (saveAmount > 0)
                                pw.Text(
                                  'Save \$${saveAmount.toStringAsFixed(2)}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 25),
            
            // Availability Section
            if (product.pickupEligible != null || product.sameDayEligible != null)
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                margin: pw.EdgeInsets.only(bottom: 20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'AVAILABILITY',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    if (product.pickupEligible != null)
                      pw.Text(
                        '• Store Pickup: ${product.pickupEligible! ? "Available" : "Not Available"}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                    if (product.sameDayEligible != null)
                      pw.Text(
                        '• Same Day Delivery: ${product.sameDayEligible! ? "Available" : "Not Available"}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                    if (product.shipToHomeEligible != null)
                      pw.Text(
                        '• Ship to Home: ${product.shipToHomeEligible! ? "Available" : "Not Available"}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ),
            
            // Description Section
            if (product.currentSku?.imageAltText != null && 
                product.currentSku!.imageAltText!.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DESCRIPTION',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    product.currentSku!.imageAltText!,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey800,
                      lineSpacing: 1.5,
                    ),
                    textAlign: pw.TextAlign.justify,
                  ),
                ],
              )
            else
              pw.Text(
                'No description available',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            
            pw.Spacer(),
            
            // Footer
            pw.Container(
              padding: pw.EdgeInsets.only(top: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                    color: PdfColors.grey400,
                    width: 1,
                  ),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated on ${DateTime.now().toString().split(' ')[0]}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  if (reviewsCount > 0)
                    pw.Text(
                      '$reviewsCount reviews • ${rating.toStringAsFixed(1)}★',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Check and request storage permission
    if (await requestStoragePermission()) {
      final productName = (product.displayName ?? product.productName ?? 'unknown')
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      
      if (Platform.isAndroid) {
        // For Android, save to the Downloads folder
        final downloadsDirectory = Directory('/storage/emulated/0/Download');
        final fileName = "product_${productName}_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final file = File("${downloadsDirectory.path}/$fileName");

        // Write the PDF data to the file
        await file.writeAsBytes(await pdf.save());
        print("📄 Saved at: ${file.path}");

        // Hide loader first
        Navigator.of(context, rootNavigator: true).pop();

        // Show Snackbar on success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF downloaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        // For iOS, save to the app's document directory
        final directory = await getApplicationDocumentsDirectory();
        final fileName = "product_${productName}_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final file = File("${directory.path}/$fileName");

        // Write the PDF data to the file
        await file.writeAsBytes(await pdf.save());
        print("📄 Saved at: ${file.path}");

        // Hide loader first
        Navigator.of(context, rootNavigator: true).pop();

        // Show Snackbar on success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } else {
      // Hide loader first
      Navigator.of(context, rootNavigator: true).pop();

      // If permission is not granted, show error message
      print("Permission denied. Cannot save the file.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Permission denied. Cannot save the file.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    print('Error generating PDF: $e');
    
    // Hide loader first
    Navigator.of(context, rootNavigator: true).pop();
    
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Error generating PDF: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// Helper widget to build badges
pw.Widget _buildBadge(String text, PdfColor color) {
  return pw.Container(
    padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
      color: color.shade(0.2),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: color,
      ),
    ),
  );
}

// Define the requestStoragePermission function
Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    // Check Android version
    
    // For Android 11 (API 30) and above
    if (Platform.version.contains('Android 11') || 
        Platform.version.contains('Android 12') || 
        Platform.version.contains('Android 13') ||
        Platform.version.contains('Android 14')) {
      // Request MANAGE_EXTERNAL_STORAGE permission
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }
    } else {
      // For Android 10 and below, use regular storage permission
      if (await Permission.storage.isGranted) {
        return true;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
  }
  
  // For iOS, no special permission is needed for saving files to the documents directory
  return true;
}