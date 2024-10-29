import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageGenerationPage extends StatefulWidget {
  @override
  _ImageGenerationPageState createState() => _ImageGenerationPageState();
}

class _ImageGenerationPageState extends State<ImageGenerationPage> {
  bool _isLoading = false;
  String _response = '';

  Future<void> _analyzeImage(File imageFile) async {
    final String apiUrl = 'https://aksa.pythonanywhere.com/analyze-recipe';

    setState(() {
      _isLoading = true; // Show loader
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseJson = json.decode(responseData);
        final result = responseJson['result'] as String;

        if (result.trim() == "I don't know.") {
          _showErrorDialog('Unable to identify ingredients.');
        } else {
          setState(() {
            _response = result.trim(); // Update _response
          });
        }
      } else {
        _showErrorDialog('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error uploading image. Please try again.');
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File imageFile = File(image.path);
      await _analyzeImage(imageFile);
    }
  }

  Future<void> _showErrorDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Image Upload and Analysis'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: Center(
                  child: Icon(
                    Icons.upload,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Text(
                _response.isEmpty
                    ? 'Tap the icon to upload an image of food to get a recipe'
                    : _response,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
