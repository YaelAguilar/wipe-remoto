import 'package:flutter/material.dart';
import '../models/sensitive_data.dart';
import '../repositories/secure_storage_service.dart';

class VaultViewModel extends ChangeNotifier {
  final SecureStorageService _storage = SecureStorageService();
  
  List<SensitiveData> _data = [];
  List<SensitiveData> get data => _data;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  VaultViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    _data = await _storage.readData();
    
    _isLoading = false;
    notifyListeners();
  }

  void toggleVisibility(String id) {
    final item = _data.firstWhere((e) => e.id == id);
    item.isVisible = !item.isVisible;
    notifyListeners();
  }

  Future<void> updateItem(String id, String newTitle, String newContent) async {
    final index = _data.indexWhere((item) => item.id == id);
    if (index != -1) {
      final itemToUpdate = _data[index];
      if (itemToUpdate.content.isEmpty) {
        itemToUpdate.title = newTitle;
        itemToUpdate.content = newContent;
        itemToUpdate.lastAccessed = "Recién añadido";
        await _storage.saveData(_data);
        notifyListeners();
      }
    }
  }

  Future<void> wipeDataAndRefresh() async {
    debugPrint("ViewModel: Recargando datos después de un wipe...");
    await loadData();
  }
}