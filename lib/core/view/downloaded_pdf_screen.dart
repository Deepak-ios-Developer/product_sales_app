import 'dart:io';
import 'package:flutter/material.dart';
import 'package:product_sale_app/core/constants/common_strings.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadedPDFsScreen extends StatefulWidget {
  @override
  _DownloadedPDFsScreenState createState() => _DownloadedPDFsScreenState();
}

class _DownloadedPDFsScreenState extends State<DownloadedPDFsScreen> {
  List<FileSystemEntity> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedPDFs();
  }

  // Load all the downloaded PDF files
  Future<void> _loadDownloadedPDFs() async {
    // Ask for storage permission first
    final status = await _requestStoragePermission();

    if (status) {
      // Use the default download directory
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        final List<FileSystemEntity> files = directory
            .listSync()
            .where((file) => file.path.endsWith('.pdf') && file.uri.pathSegments.last.startsWith('app_')) // Filter by prefix "app_"
            .toList();

        setState(() {
          pdfFiles = files;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download folder not found.')),
        );
      }
    } else {
      // If permission is denied
      setState(() {
        pdfFiles = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required to view PDFs')),
      );
    }
  }

  // Open PDF with the default PDF viewer
  void _openPDF(String filePath) {
    OpenFile.open(filePath);
  }

  // Request storage permission for Android 10 and above
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 10 and above, we need to request MANAGE_EXTERNAL_STORAGE permission
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          return true;
        } else {
          // For Android 9 and below, request the standard storage permission
          final permissionStatus = await Permission.storage.request();
          return permissionStatus.isGranted;
        }
      }
    }
    return true; // No need for special permission handling on iOS
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.downloadedPDFs),
        surfaceTintColor: Colors.transparent,
      ),
      body: pdfFiles.isEmpty
          ? Center(child:Text(AppStrings.noDownloadsFound))
          : ListView.builder(
        itemCount: pdfFiles.length,
        itemBuilder: (context, index) {
          final file = pdfFiles[index];
          final fileName = file.uri.pathSegments.last;
          final fileSize = File(file.path).statSync().size;
          final fileDate = DateTime.fromMillisecondsSinceEpoch(
              File(file.path).statSync().modified.millisecondsSinceEpoch)
              .toLocal();
          final formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(fileDate);  // <-- Use DateFormat

          return ListTile(
            title: Text(fileName),
            subtitle: Text("${AppStrings.size} ${fileSize / 1024} KB, Date: $formattedDate"),
            trailing: Icon(Icons.open_in_new),
            onTap: () => _openPDF(file.path),
          );
        },
      ),
    );
  }
}
