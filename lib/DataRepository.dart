import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:url_launcher/url_launcher.dart';

class DataRepository {
  static const _firstNameKey = 'firstName';
  static const _lastNameKey = 'lastName';
  static const _phoneKey = 'phone';
  static const _emailKey = 'email';

  // Load data from SharedPreferences
  Future<void> loadData({
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController phoneController,
    required TextEditingController emailController,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypter = _getEncrypter();

    firstNameController.text = _decrypt(prefs.getString(_firstNameKey), encrypter) ?? '';
    lastNameController.text = _decrypt(prefs.getString(_lastNameKey), encrypter) ?? '';
    phoneController.text = _decrypt(prefs.getString(_phoneKey), encrypter) ?? '';
    emailController.text = _decrypt(prefs.getString(_emailKey), encrypter) ?? '';
  }

  // Save data to SharedPreferences
  Future<void> saveData({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypter = _getEncrypter();

    prefs.setString(_firstNameKey, _encrypt(firstName, encrypter));
    prefs.setString(_lastNameKey, _encrypt(lastName, encrypter));
    prefs.setString(_phoneKey, _encrypt(phone, encrypter));
    prefs.setString(_emailKey, _encrypt(email, encrypter));
  }

  // Initialize Encrypter with a key
  encrypt.Encrypter _getEncrypter() {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    final iv = encrypt.IV.fromLength(16);
    return encrypt.Encrypter(encrypt.AES(key));
  }

  // Encrypt data
  String _encrypt(String value, encrypt.Encrypter encrypter) {
    final iv = encrypt.IV.fromLength(16); // Use a random IV for encryption
    final encrypted = encrypter.encrypt(value, iv: iv);
    return encrypted.base64;
  }

  // Decrypt data
  String? _decrypt(String? encryptedValue, encrypt.Encrypter encrypter) {
    if (encryptedValue == null) return null;
    final iv = encrypt.IV.fromLength(16); // Use the same IV length for decryption
    return encrypter.decrypt64(encryptedValue, iv: iv);
  }
}
