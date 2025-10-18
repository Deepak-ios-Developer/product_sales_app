import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ShareAsPDFButton extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double discountedPrice;
  final String? brandName;
  final String? productId;
  final String? skuId;
  final double? originalPrice;
  final double? rating;
  final int? reviewsCount;
  final bool? isNew;
  final bool? isSephoraExclusive;
  final bool? isLimitedEdition;
  final int? moreColors;
  final bool? pickupEligible;
  final bool? sameDayEligible;

  const ShareAsPDFButton({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountedPrice,
    this.brandName,
    this.productId,
    this.skuId,
    this.originalPrice,
    this.rating,
    this.reviewsCount,
    this.isNew,
    this.isSephoraExclusive,
    this.isLimitedEdition,
    this.moreColors,
    this.pickupEligible,
    this.sameDayEligible,
  }) : super(key: key);

  Future<File> _generatePDF() async {
    final pdf = pw.Document();
    pw.MemoryImage? image;

    // Load product image
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

    // Calculate discount and reward points
    final double discount = originalPrice != null && originalPrice! > discountedPrice
        ? ((originalPrice! - discountedPrice) / originalPrice! * 100)
        : 0.0;
    final int rewardPoints = (discountedPrice * 0.1).toInt();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          // Header with title
          pw.Container(
            padding: pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'Product Details',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Product Image
          if (image != null) ...[
            pw.Center(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.ClipRRect(
                  horizontalRadius: 8,
                  verticalRadius: 8,
                  child: pw.Image(image, height: 250),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // Brand Name
          if (brandName?.isNotEmpty ?? false) ...[
            _buildSectionTitle('Brand'),
            pw.Text(
              brandName!,
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 15),
          ],

          // Product Name
          _buildSectionTitle('Product Name'),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 15),

          // Description
          if (description.isNotEmpty) ...[
            _buildSectionTitle('Description'),
            pw.Text(
              description,
              style: pw.TextStyle(fontSize: 12, height: 1.5),
            ),
            pw.SizedBox(height: 15),
          ],

          // Pricing Section
          _buildSectionTitle('Pricing'),
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Current Price:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text(
                      '\$${discountedPrice.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
                if (discount > 0 && originalPrice != null) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Original Price:', style: pw.TextStyle(fontSize: 11)),
                      pw.Text(
                        '\$${originalPrice!.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                          decoration: pw.TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Discount:', style: pw.TextStyle(fontSize: 11)),
                      pw.Text(
                        '${discount.toStringAsFixed(0)}% OFF',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green700,
                        ),
                      ),
                    ],
                  ),
                ],
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Reward Points:', style: pw.TextStyle(fontSize: 11)),
                    pw.Text(
                      '$rewardPoints Points',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.pink700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 15),

          // Rating and Reviews
          if (rating != null && rating! > 0) ...[
            _buildSectionTitle('Customer Reviews'),
            pw.Row(
              children: [
                pw.Text(
                  '★' * rating!.floor() + '☆' * (5 - rating!.floor()),
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.amber),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  '${rating!.toStringAsFixed(1)} / 5.0',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                if (reviewsCount != null && reviewsCount! > 0) ...[
                  pw.SizedBox(width: 5),
                  pw.Text(
                    '($reviewsCount reviews)',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                  ),
                ],
              ],
            ),
            pw.SizedBox(height: 15),
          ],

          // Product Features/Tags
          if (_hasProductFeatures()) ...[
            _buildSectionTitle('Features'),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isNew ?? false) _buildTag('New'),
                if (isSephoraExclusive ?? false) _buildTag('Sephora Exclusive'),
                if (isLimitedEdition ?? false) _buildTag('Limited Edition'),
                if (moreColors != null && moreColors! > 0)
                  _buildTag('$moreColors Colors Available'),
              ],
            ),
            pw.SizedBox(height: 15),
          ],

          // Product Details
          if (_hasProductDetails()) ...[
            _buildSectionTitle('Product Details'),
            pw.Container(
              padding: pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                children: [
                  if (productId != null) _buildDetailRow('Product ID', productId!),
                  if (skuId != null) _buildDetailRow('SKU', skuId!),
                  if (brandName != null) _buildDetailRow('Brand', brandName!),
                  if (pickupEligible != null)
                    _buildDetailRow(
                      'Store Pickup',
                      pickupEligible! ? 'Available' : 'Not Available',
                    ),
                  if (sameDayEligible != null)
                    _buildDetailRow(
                      'Same Day Delivery',
                      sameDayEligible! ? 'Available' : 'Not Available',
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),
          ],

          // Shipping Information
          _buildSectionTitle('Shipping & Handling'),
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text('• ', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Standard Delivery: 5-7 business days',
                        style: pw.TextStyle(fontSize: 11)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Text('• ', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Express Delivery: 2-3 business days',
                        style: pw.TextStyle(fontSize: 11)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Text('• ', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Returns: 30-day return policy',
                        style: pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'Generated on ${DateTime.now().toString().split('.')[0]}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/product_detail_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  bool _hasProductFeatures() {
    return (isNew ?? false) ||
        (isSephoraExclusive ?? false) ||
        (isLimitedEdition ?? false) ||
        (moreColors != null && moreColors! > 0);
  }

  bool _hasProductDetails() {
    return productId != null ||
        skuId != null ||
        brandName != null ||
        pickupEligible != null ||
        sameDayEligible != null;
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey800,
        ),
      ),
    );
  }

  pw.Widget _buildTag(String label) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(fontSize: 10),
      ),
    );
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  void _showPdf(BuildContext context) async {
    try {
      final pdfFile = await _generatePDF();
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Product Details: $title',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159),
        child: Icon(Icons.reply, size: 20),
      ),
      onPressed: () => _showPdf(context),
    );
  }
}