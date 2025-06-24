import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:wipe_remoto/secure_storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _storageService = SecureStorageService();
  final _textController = TextEditingController();
  String _currentData = "Cargando datos...";
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _loadInitialData();
    _setupFCM();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("La app ha vuelto a primer plano (resumed). Forzando recarga desde disco...");
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.reload();

    final data = prefs.getString(_storageService.getSensitiveDataKey());
    
    if (!mounted) return;
    setState(() {
      _currentData = data ?? "No hay datos sensibles guardados.";
    });
  }

  void _setupFCM() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (!mounted) return;
    setState(() => _fcmToken = token);
    debugPrint("======================================================");
    debugPrint("FCM Token del dispositivo: $token");
    debugPrint("======================================================");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['action'] == 'wipe_data') {
        _wipeAndRefreshUI();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Limpieza remota ejecutada!'), backgroundColor: Colors.orange));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['action'] == 'wipe_data') {
        _wipeAndRefreshUI();
      }
    });
  }
  
  void _saveData() async {
    if (_textController.text.isNotEmpty) {
      await _storageService.saveData(_textController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dato sensible guardado con éxito.')));
      _textController.clear();
      _loadInitialData();
    }
  }

  Future<void> _wipeAndRefreshUI() async {
    await _storageService.wipeAllData();
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Práctica: Wipe Remoto'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Dato Sensible Actual:', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: Text(_currentData, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 24),
          TextField(controller: _textController, decoration: const InputDecoration(labelText: 'Introduce un nuevo dato sensible', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          ElevatedButton.icon(icon: const Icon(Icons.save), label: const Text('Guardar Dato'), onPressed: _saveData),
          ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Refrescar Datos Guardados'), onPressed: _loadInitialData, style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey)),
          const Spacer(),
          if (_fcmToken != null) Card(color: Colors.amber.shade100, child: Padding(padding: const EdgeInsets.all(8.0), child: Column(children: [
            const Text("Token FCM (para pruebas):"),
            SelectableText(_fcmToken!),
            TextButton(child: const Text("Copiar Token"), onPressed: () {
              Clipboard.setData(ClipboardData(text: _fcmToken!));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token copiado!')));
            })
          ]))),
        ]),
      ),
    );
  }
}