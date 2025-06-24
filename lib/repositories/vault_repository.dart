import '../models/sensitive_data.dart';

class VaultRepository {
  final List<SensitiveData> _inMemoryData = [
    SensitiveData(id: "1", title: "Documento de Identidad Nacional (DNI)", type: "personal", content: "", lastAccessed: "Nunca", icon: "🆔"),
    SensitiveData(id: "2", title: "Tarjeta de Crédito VISA", type: "financial", content: "", lastAccessed: "Nunca", icon: "💳"),
    SensitiveData(id: "3", title: "Contraseña del Router WiFi", type: "credential", content: "", lastAccessed: "Nunca", icon: "🔐"),
  ];

  Future<List<SensitiveData>> getAllData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _inMemoryData;
  }

  Future<void> updateData(SensitiveData updatedItem) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _inMemoryData.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _inMemoryData[index] = updatedItem;
    }
  }
}