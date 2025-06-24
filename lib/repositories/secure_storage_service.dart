import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensitive_data.dart';

class SecureStorageService {
  static const _key = 'secure_vault_data';

  Future<void> saveData(List<SensitiveData> data) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> dataAsMap = data.map((item) => item.toJson()).toList();
    String jsonString = jsonEncode(dataAsMap);
    await prefs.setString(_key, jsonString);
  }

  Future<List<SensitiveData>> readData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [
        SensitiveData(id: "1", title: "Documento de Identidad Nacional (DNI)", type: "personal", content: "", lastAccessed: "Nunca", icon: "🆔"),
        SensitiveData(id: "2", title: "Tarjeta de Crédito VISA", type: "financial", content: "", lastAccessed: "Nunca", icon: "💳"),
        SensitiveData(id: "3", title: "Contraseña del Router WiFi", type: "credential", content: "", lastAccessed: "Nunca", icon: "🔐"),
      ];
    }

    List<dynamic> dataAsMap = jsonDecode(jsonString);
    return dataAsMap.map((itemMap) => SensitiveData.fromJson(itemMap)).toList();
  }

  Future<void> wipeAllData() async {

    List<SensitiveData> currentData = await readData();
    for (var item in currentData) {
      item.content = "";
      item.lastAccessed = "Borrado remotamente";
    }
    await saveData(currentData);
    debugPrint("¡SecureVault: El contenido de los datos ha sido borrado!");
  }
}