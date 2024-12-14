import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // استيراد Firestore
import 'user_home_screen.dart'; // تأكد من استيراد صفحة الصفحة الرئيسية للمستخدم
import 'user_register.dart'; // تأكد من استيراد شاشة التسجيل

class UserLoginScreen extends StatefulWidget {
  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // دالة لتسجيل الدخول باستخدام Firebase
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // Attempt login with Firebase
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get the current user UID
        String uid = userCredential.user?.uid ?? '';

        // Fetch user data from Firestore
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          // Fetch the tasks assigned to the logged-in user
          QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
              .collection('tasks')
              .where('assignedUserId',
                  isEqualTo:
                      uid) // Assuming the tasks are assigned using 'assignedUserId'
              .get();

          if (taskSnapshot.docs.isNotEmpty) {
            // Handle the tasks (e.g., pass them to the home screen or process them)
            List tasks = taskSnapshot.docs.map((doc) => doc.data()).toList();
            // You can pass the tasks to the home screen or another part of your app
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserHomeScreen(
                  email: email,
                ),
              ),
            );
          } else {
            // Handle case where no tasks are assigned
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('No Tasks Assigned'),
                  content: Text('You have no tasks assigned at the moment.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          throw Exception('User data not found in Firestore');
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Login failed';
        if (e.code == 'user-not-found') {
          message = 'No user found for that email';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password provided for that user';
        }

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Handle other errors
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An unexpected error occurred'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Show warning if fields are empty
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill in all fields'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              // شعار أو أيقونة أعلى الصفحة
              Center(
                child: Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              // نص الترحيب
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Login to your account to continue',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // حقل البريد الإلكتروني
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // حقل كلمة المرور
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // زر تسجيل الدخول
              ElevatedButton(
                onPressed: _login,
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              // نص للتسجيل الجديد
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      // الانتقال إلى صفحة التسجيل
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserRegisterScreen(
                            onUserAdded: (String name) {
                              // يمكنك إضافة الكود الخاص بإضافة المستخدم هنا
                            },
                          ),
                        ),
                      );
                    },
                    child: Text('Register here'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
