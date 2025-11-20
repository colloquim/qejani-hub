// screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'renter' or 'landlord'

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  static const Color _primaryBlue = Color(0xFF1976D2); // Deep Blue

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // LOGIN
        await AuthService().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // SIGNUP
        await AuthService().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: widget.role,
          fullName: _fullNameController.text.trim(),
        );
      }
      _routeUser();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin
              ? 'Login failed. Please check your email and password.'
              : 'Sign up failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _routeUser() {
    final targetPath =
        widget.role == 'renter' ? '/renter/home' : '/landlord/dashboard';
    context.go(targetPath);
  }

  // Helper function for consistent minimalist input decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryBlue.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryBlue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.grey.shade50, // Very light gray fill
      labelStyle: const TextStyle(color: Colors.black54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Minimalist AppBar (transparent background, blue icon/title)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _primaryBlue,
        title: Text(
          _isLogin
              ? 'Welcome Back'
              : 'Create ${widget.role.toUpperCase()} Account',
        ),
        centerTitle: true,
      ),
      // Clean white background for the minimalist look
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          // Removed Card for a cleaner, edge-to-edge minimalist feel
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon/Logo Placeholder
                const Icon(
                  Icons.apartment_rounded,
                  size: 60,
                  color: _primaryBlue,
                ),
                const SizedBox(height: 16),

                // Main Title
                Text(
                  _isLogin
                      ? 'Sign In to Qejani Hub'
                      : 'Register as a ${widget.role.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Full Name for Sign Up (Styled to be minimalist blue)
                if (!_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration('Full Name', Icons.person),
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please enter your full name.'
                          : null,
                    ),
                  ),

                // Email (Styled to be minimalist blue)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email Address', Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value == null || !value.contains('@'))
                            ? 'Enter a valid email.'
                            : null,
                  ),
                ),

                // Password (Styled to be minimalist blue)
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: _inputDecoration('Password', Icons.lock),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) => (value == null || value.length < 6)
                        ? 'Password must be at least 6 characters.'
                        : null,
                  ),
                ),

                // Submit Button (Blue, prominent, and good size)
                SizedBox(
                  height: 56, // Good, prominent size
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAuthForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isLogin ? 'LOGIN' : 'SIGN UP',
                            style: const TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 20),

                // Toggle Login/Signup (Blue text)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      // Clear controllers when switching forms for a clean slate
                      _emailController.clear();
                      _passwordController.clear();
                      _fullNameController.clear();
                      _formKey.currentState?.reset();
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Need an account? Sign Up'
                        : 'Already have an account? Login',
                    style: const TextStyle(
                      fontSize: 16,
                      color: _primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
