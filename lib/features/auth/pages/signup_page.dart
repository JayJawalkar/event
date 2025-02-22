// ignore_for_file: use_build_context_synchronously
import 'package:event/core/constants/image_constants.dart';
import 'package:event/core/image/image.dart';
import 'package:event/features/auth/pages/login_page.dart';
import 'package:event/features/auth/widgets/text_field_explicit.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final SupabaseClient supabase = Supabase.instance.client;
  String id = randomAlphaNumeric(10);
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Basic email validation pattern
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailPattern.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            SizedBox(
              height: 100,
            ),
            ImageSvg(
              height: 200,
              width: 200,
              path: ImageConstants.signUp,
            ),
            TextFieldExplicit(
              validator: validateName,
              textInputType: TextInputType.name,
              obscureText: false,
              labelText: 'Enter Name',
              controller: nameController,
            ),
            TextFieldExplicit(
              validator: validateEmail,
              textInputType: TextInputType.emailAddress,
              obscureText: false,
              labelText: 'Enter Email',
              controller: emailController,
            ),
            TextFieldExplicit(
              validator: validatePassword,
              textInputType: TextInputType.visiblePassword,
              obscureText: true,
              labelText: 'Enter Password',
              controller: passwordController,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  fixedSize: Size(double.maxFinite, 60),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () async {
                  try {
                    await supabase.auth
                        .signUp(
                      password: passwordController.text.trim(),
                      email: emailController.text.trim(),
                    )
                        .then((response) async {
                      if (response.user != null) {
                        // Insert user data into the database
                        try {
                          await supabase.from('users').insert({
                            'id': id,
                            'name': nameController.text.trim(),
                            'email': emailController.text.trim(),
                            'password': passwordController.text.trim(),
                          });

                          // Show success message
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Account created successfully! Please login.'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Wait for SnackBar to be visible before navigation
                            await Future.delayed(const Duration(seconds: 2));

                            // Navigate to login page
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error saving user data: ${e.toString()}')),
                            );
                          }
                        }
                      }
                    }).onError((error, stackTrace) {
                      // Handle auth errors
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Authentication error: ${error.toString()}')),
                        );
                      }
                    });
                  } catch (e1) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e1.toString()}')),
                      );
                    }
                  }
                },
                child: Text(
                  '   Sign In   ',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an Account?',
                  style: TextStyle(fontSize: 18),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    'LogIn',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
