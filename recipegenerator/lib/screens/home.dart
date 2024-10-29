import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipegenerator/screens/image.dart';
import 'package:recipegenerator/screens/profile.dart';
import 'package:recipegenerator/screens/save.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  String? _selectedCountry;
  final List<String> _countries = [
    'Select Country',
    'USA',
    'Canada',
    'Mexico',
    'India',
    'China'
    'Pakistan',
    'Brazil',
    'Russia',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Australia',
    'Japan',
    'South Korea'
  ];
  final List<Widget> _pages = [
    HomeContent(),
    ImageGenerationPage(),
    SavedPage(),
    ProfilePage(),
  ];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _recipe;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _generateRecipe() async {
    String ingredientsText = _ingredientsController.text;
    List<String> ingredients = ingredientsText.isNotEmpty
        ? ingredientsText.split(',').map((e) => e.trim()).toList()
        : [];
    String servings = _servingsController.text;
    String country = _selectedCountry ?? 'Select Country';

    if (ingredients.isEmpty ||
        servings.isEmpty ||
        country == 'Select Country') {
      _showErrorDialog('Please fill out all fields.');
      return;
    }

    final String apiUrl = 'https://aksa.pythonanywhere.com/recipe';
    final Map<String, dynamic> payload = {
      'ingredients': ingredients,
      'servings': servings,
      'country': country
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        final recipe = responseJson['recipe'] as String;

        setState(() {
          _recipe = recipe;
        });

        _showRecipeDialog(recipe);
      } else {
        _showErrorDialog('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating recipe: $e');
      _showErrorDialog('Error generating recipe. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      await _analyzeImage(File(image.path));
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    final String apiUrl = 'https://aksa.pythonanywhere.com/analyze-image';

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
          // Add new ingredients to the list and update the controller
          setState(() {
            String currentText = _ingredientsController.text;
            if (currentText.isNotEmpty) {
              _ingredientsController.text += ', ';
            }
            _ingredientsController.text += result.trim();
          });
        }
      } else {
        _showErrorDialog('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorDialog('Error uploading image. Please try again.');
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }

  void _showErrorDialog(String message) {
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

  void _showRecipeDialog(String recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Generated Recipe'),
          content: Text(recipe),
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

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loader when loading
            : _selectedIndex == 0
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Ingredients TextField
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ingredientsController,
                                decoration: InputDecoration(
                                  labelText: 'Ingredients (comma separated)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _showImageSourceSelection,
                              child: Text('Upload Image'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Country Selector
                        DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          items: _countries.map((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCountry = newValue!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Country',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          isExpanded: true,
                        ),
                        SizedBox(height: 20),

                        // Servings TextField
                        TextField(
                          controller: _servingsController,
                          decoration: InputDecoration(
                            labelText: 'Number of Servings',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),

                        // Generate Recipe Button
                        ElevatedButton(
                          onPressed: _generateRecipe,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.greenAccent,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Generate Recipe',
                            style: TextStyle(
                                fontSize: 18,
                                color:
                                    const Color.fromARGB(255, 241, 241, 241)),
                          ),
                        ),
                        if (_recipe != null) // Display the recipe if available
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              'Generated Recipe:\n$_recipe',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  )
                : _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Image Generation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent.shade700,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.lightBlue.shade50,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Home Page Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
