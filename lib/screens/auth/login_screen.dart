// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

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
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (_isLogin) {
          // LOGIN
          final user = await AuthService().signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          if (user != null) {
            // Check user role after successful login
            // For a full MVP, you'd check the saved user role in Firestore here
            // and route accordingly (renter: /home, landlord: /landlord-dashboard).
            _routeUser(user.uid);
          }
        } else {
          // SIGNUP
          final user = await AuthService().signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          if (user != null) {
            // IMPORTANT: Create the user document with the selected role immediately after signup
            await DatabaseService().createUser(
              uid: user.uid,
              email: user.email!,
              role: widget.role,
            );
            _routeUser(user.uid);
          }
        }
      } catch (e) {
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication Failed: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _routeUser(String uid) {
    // Navigate based on the selected role during login/signup
    if (widget.role == 'renter') {
      context.go('/home'); // Go to Renter's main page
    } else if (widget.role == 'landlord') {
      // Assuming you have a landlord dashboard route
      context.go('/landlord-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_isLogin ? 'Login' : 'Sign Up'} as ${widget.role.toUpperCase()}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin
                      ? 'Welcome Back!'
                      : 'Join Qejani Hub as a ${widget.role.toUpperCase()}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAuthForm,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isLogin ? 'LOGIN' : 'SIGN UP',
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Need an account? Sign Up'
                        : 'Already have an account? Login',
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
