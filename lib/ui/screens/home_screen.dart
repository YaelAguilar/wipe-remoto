import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../models/sensitive_data.dart';
import '../../viewmodels/vault_viewmodel.dart';
import '../widgets/data_card.dart';
import '../widgets/edit_data_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupFCM();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("SecureVault: App ha vuelto a primer plano. Refrescando...");
      Provider.of<VaultViewModel>(context, listen: false).loadData();
    }
  }

  void _setupFCM() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (!mounted) return;
    setState(() => _fcmToken = token);

    final viewModel = Provider.of<VaultViewModel>(context, listen: false);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['action'] == 'wipe_data') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Comando de limpieza remota ejecutado!'), backgroundColor: Colors.orange)
        );
        viewModel.wipeDataAndRefresh();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['action'] == 'wipe_data') {
        viewModel.wipeDataAndRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VaultViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: _buildAppBar(context, viewModel.data.length),
          body: _buildBody(context, viewModel),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
    );
  }
  
  Widget _buildBody(BuildContext context, VaultViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.data.length,
      itemBuilder: (context, index) {
        final item = viewModel.data[index];
        return DataCard(
          item: item,
          onToggleVisibility: () => viewModel.toggleVisibility(item.id),
          onEdit: () => _showEditDialog(context, viewModel, item),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, VaultViewModel viewModel, SensitiveData item) {
    showDialog(
      context: context,
      builder: (_) => EditDataDialog(
        item: item,
        onSave: (newTitle, newContent) {
          viewModel.updateItem(item.id, newTitle, newContent);
        },
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context, int dataCount) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 160,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF9333EA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withAlpha(51), shape: BoxShape.circle), child: const Icon(Icons.security_rounded, color: Colors.white, size: 20)),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SecureVault', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('Datos protegidos', style: TextStyle(color: Color.fromARGB(204, 255, 255, 255), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total', '$dataCount')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Seguro', '100%')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color.fromARGB(204, 255, 255, 255), fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (_fcmToken != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('FCM Token de Desarrollo'),
              content: SingleChildScrollView(child: SelectableText(_fcmToken!)),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _fcmToken!));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token copiado al portapapeles')));
                  },
                  child: const Text('Copiar y Cerrar'),
                )
              ],
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: const SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_filled, color: Color(0xFF6366F1), size: 24),
                    SizedBox(height: 4),
                    Text('Inicio', style: TextStyle(color: Color(0xFF6366F1), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}