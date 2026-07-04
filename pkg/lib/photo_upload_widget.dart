import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadWidget extends StatefulWidget {
  const PhotoUploadWidget({super.key});

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // Galeriden fotoğraf seçimi
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      // TODO: Seçilen görseli Go backend'ine (multipart/form-data) gönder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, height: 250, fit: BoxFit.cover),
              )
            : Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
              ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload_file),
          label: const Text('Ürün Fotoğrafı Yükle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD4AF37), // Altın rengi
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }
}