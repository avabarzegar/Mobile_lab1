import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Login Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  String imageFolder = 'images/question-mark.png';
  final EncryptedSharedPreferences _storage = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    _loadCredentials();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  void _checkPassword() {
    setState(() {
      if (_passwordController.text == 'QWERTY123') {
        imageFolder = 'images/idea.png';
      } else {
        imageFolder = 'images/stop.png';
      }
    });
    _showSaveCredentialsDialog();
  }

  Future<void> _showSaveCredentialsDialog() async {
    bool save = false;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Data'),
          content: const Text('Would You Like to Save Your Login Data?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                save = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                save = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (save) {
      _saveCredentialsIfAvailable();
    } else {
      _clearCredentials();
    }
  }

  Future<void> _saveCredentialsIfAvailable() async {
    if (_storage != null) {
      await _saveCredentials();
    } else {
      print("Storage is not initialized!");
    }
  }

  Future<void> _saveCredentials() async {
    // Save credentials to EncryptedSharedPreferences
    await _storage.setString('username', _loginController.text);
    await _storage.setString('password', _passwordController.text);
  }

  Future<void> _clearCredentials() async {
    // Clear saved credentials from EncryptedSharedPreferences
    await _storage.remove('username');
    await _storage.remove('password');
    // Reset text fields
    _loginController.clear();
    _passwordController.clear();
  }

  Future<void> _loadCredentials() async {
    String? username = await _storage.getString('username');
    String? password = await _storage.getString('password');

    if (username != null && password != null && username.isNotEmpty && password.isNotEmpty) {
      _loginController.text = username;
      _passwordController.text = password;

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final snackBar = SnackBar(
          content: const Text('Previous login credentials are currently loaded.'),
          duration: const Duration(seconds: 30),
          action: SnackBarAction(
            label: 'Clear saved data',
            onPressed: () {
              _clearCredentials();
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                hintText: "Type here",
                border: OutlineInputBorder(),
                labelText: "Login name",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Type here",
                border: OutlineInputBorder(),
                labelText: "Password",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Login"),
              onPressed: _checkPassword,
            ),
            const SizedBox(height: 20),
            Image.asset(imageFolder, width: 300, height: 300),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}