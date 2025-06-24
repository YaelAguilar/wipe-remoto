import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _keySensitiveData = 'sensitive_data';

  String getSensitiveDataKey() => _keySensitiveData;

  Future<void> saveData(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySensitiveData, data);
    debugPrint("Dato guardado: $data");
  }

  Future<String?> readData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySensitiveData);
  }

  Future<void> wipeAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("¡Todos los datos de SharedPreferences han sido eliminados!");
  }
}