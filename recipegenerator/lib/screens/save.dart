import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data for the list
    final List<Map<String, String>> recipes = [
      {
        'title': 'Recipe 1',
        'description': 'This is a brief description of Recipe 1.'
      },
      {
        'title': 'Recipe 2',
        'description': 'This is a brief description of Recipe 2.'
      },
      {
        'title': 'Recipe 3',
        'description': 'This is a brief description of Recipe 3.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Saved Recipes'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            title: Text(recipe['title']!),
            subtitle: Text(recipe['description']!),
            onTap: () {
              // Handle item tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(
                    title: recipe['title']!,
                    description: recipe['description']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final String title;
  final String description;

  RecipeDetailPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              description,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
