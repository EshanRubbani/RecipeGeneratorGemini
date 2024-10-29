import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipegenerator/screens/signin.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController updateController = TextEditingController();
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Profile icon
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_icon.png'),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),

            // Email
            Text(
              user?.email ?? 'No Email', // Display email or fallback
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 30),

            // Change password field
            Padding(
              padding: EdgeInsets.all(16),
              child: TextFormField(
                controller: updateController,
                decoration: InputDecoration(
                  labelText: 'Change Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20),

            // Update password button
            ElevatedButton(
              onPressed: () async {
                if (updateController.text.isNotEmpty) {
                  try {
                    await user?.updatePassword(updateController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password updated successfully.')),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'requires-recent-login') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please re-authenticate to update your password.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.message}')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please fill in the password field first.')),
                  );
                }
              },
              child: Text('Update Password'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                backgroundColor: Colors.blue, // Button color
              ),
            ),

            SizedBox(height: 20),

            // Logout button
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SigninPage()),
                );
              },
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                backgroundColor: Colors.red, // Button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
