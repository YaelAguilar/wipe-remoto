import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wipe_remoto/home_page.dart';
import 'package:wipe_remoto/secure_storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint("====================================================");
  debugPrint("¡¡¡MANEJADOR EN SEGUNDO PLANO (_firebaseMessagingBackgroundHandler) ACTIVADO!!!");
  debugPrint("ID del Mensaje: ${message.messageId}");
  debugPrint("Datos recibidos (message.data): ${message.data}");

  if (message.data['action'] == 'wipe_data') {
    debugPrint("CONDICIÓN 'wipe_data' CUMPLIDA. PROCEDIENDO A LIMPIAR...");
    final storage = SecureStorageService();
    await storage.wipeAllData();
    debugPrint("¡DATOS SENSIBLES ELIMINADOS DESDE SEGUNDO PLANO!");
  } else {
    debugPrint("La condición 'wipe_data' NO se cumplió. Clave 'action' no encontrada o valor incorrecto.");
    debugPrint("Valor de 'action' recibido: ${message.data['action']}");
  }
  debugPrint("====================================================");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Práctica Wipe Remoto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}