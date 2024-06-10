import 'package:flutter/material.dart';
import 'package:flutter_application_5/components/my_button.dart';
import 'package:flutter_application_5/components/my_text_field.dart';
import 'package:flutter_application_5/services/auth_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LocalAuthentication localAuthentication = LocalAuthentication();
  bool _supportState = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  void _checkBiometricSupport() async {
    _supportState = await localAuthentication.canCheckBiometrics;
    setState(() {}); // Trigger a rebuild to reflect the change
  }

  Future<bool> _authenticate() async {
    bool authenticated = false;
    if (_supportState) {
      try {
        authenticated = await localAuthentication.authenticate(
          localizedReason: 'Scan your fingerprint to authenticate',
        );
      } catch (e) {
        print("Error during authentication: $e");
      }
    } else {
      print("Biometrics are not available on this device.");
    }
    return authenticated;
  }

  void _signIn() async {
    bool isAuthenticated = await _authenticate();
    if (isAuthenticated) {
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        await authService.signInWithEmailandPassword(
          emailController.text,
          passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fingerprint authentication failed!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_supportState)
                    const Text('This device is supported')
                  else
                    const Text('This device is not supported'),
                  const Divider(height: 100),
                  const SizedBox(height: 30),
                  Icon(
                    Icons.message,
                    size: 100,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Back you've been missed!",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  MyButton(onTap: _signIn, text: "Sign In"),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Not a member?'),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Register now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
