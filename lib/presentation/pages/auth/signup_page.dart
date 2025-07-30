// lib/presentation/pages/signup_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.8), // semi-transparent
      body: Center(
        child: Text('Signup form ici'),
      ),
    );
  }
}
