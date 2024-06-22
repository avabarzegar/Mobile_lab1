import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'DataRepository.dart';

class ProfilePage extends StatefulWidget {
  final String loginName;
  ProfilePage({Key? key, required this.loginName}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final DataRepository _repository = DataRepository();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadDataFromSecureStorage();

    // Load data when the page initializes
    _repository.loadData(
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      phoneController: _phoneController,
      emailController: _emailController,
    );

    // Show SnackBar when the profile page is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome Back, ${widget.loginName}'),
          duration: const Duration(seconds: 30),
        ),
      );
    });
  }

  Future<void> _loadDataFromSecureStorage() async {
    _firstNameController.text = await _secureStorage.read(key: 'firstName') ?? '';
    _lastNameController.text = await _secureStorage.read(key: 'lastName') ?? '';
    _phoneController.text = await _secureStorage.read(key: 'phone') ?? '';
    _emailController.text = await _secureStorage.read(key: 'email') ?? '';
  }

  Future<void> _saveDataToSecureStorage() async {
    await _secureStorage.write(key: 'firstName', value: _firstNameController.text);
    await _secureStorage.write(key: 'lastName', value: _lastNameController.text);
    await _secureStorage.write(key: 'phone', value: _phoneController.text);
    await _secureStorage.write(key: 'email', value: _emailController.text);
  }

  @override
  void dispose() {
    // Save data when the page is disposed
    _repository.saveData(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
    );
    _saveDataToSecureStorage();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () {
                    // Launch phone dialer
                    _launchPhone(_phoneController.text);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    // Launch SMS application
                    _launchSMS(_phoneController.text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {
                    // Launch email program with pre-populated email
                    _launchEmail(_emailController.text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveDataToSecureStorage,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch phone dialer
  void _launchPhone(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to launch SMS application
  void _launchSMS(String phoneNumber) async {
    _showUnsupportedAlert();

    /* Function works but the SMS application is not launched, only a new tab.
    String url = 'sms:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showUnsupportedAlert();
    }
    */
  }

  // Function to launch email program with pre-populated email
  void _launchEmail(String emailAddress) async {
    String url = 'mailto:$emailAddress';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to show alert dialog if URL is not supported
  void _showUnsupportedAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unsupported Feature'),
          content: Text('The SMS URL is not supported on this device.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatelessWidget {
  final TextEditingController _loginNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _loginNameController,
              decoration: InputDecoration(
                labelText: 'Login Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      loginName: _loginNameController.text,
                    ),
                  ),
                );
              },
              child: Text('Go to Profile Page'),
            ),
          ],
        ),
      ),
    );
  }
}
