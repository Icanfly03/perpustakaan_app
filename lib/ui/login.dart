import 'package:flutter/material.dart';
import 'package:perpustakaan_app/service/user_service.dart';
import 'package:perpustakaan_app/ui/beranda.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool _isLoading = false;

  void loginProcess() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String? token = await UserService().login(usernameCtrl.text, passwordCtrl.text);
      setState(() => _isLoading = false);

      if (token != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BerandaPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal. Username/Password salah!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.library_books, color: Colors.teal.shade300, size: 80),
                    const SizedBox(height: 16),
                    Text('Selamat Datang!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                    const SizedBox(height: 8),
                    Text('Silakan login untuk masuk',
                        style: TextStyle(fontSize: 14, color: theme.hintColor)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: usernameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.teal.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Username wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark ? const Color.fromARGB(255, 242, 241, 241) : Colors.teal.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.teal)
                        : ElevatedButton.icon(
                            onPressed: loginProcess,
                            icon: const Icon(Icons.login),
                            label: const Text('Login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
