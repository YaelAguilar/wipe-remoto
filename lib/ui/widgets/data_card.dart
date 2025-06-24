import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/sensitive_data.dart';

class DataCard extends StatelessWidget {
  final SensitiveData item;
  final VoidCallback onToggleVisibility;
  final VoidCallback onEdit;

  const DataCard({
    super.key,
    required this.item,
    required this.onToggleVisibility,
    required this.onEdit,
  });

  LinearGradient _getTypeColor(String type) {
    switch (type) {
      case "personal": return const LinearGradient(colors: [Color(0xFFF87171), Color(0xFFEF4444)]);
      case "financial": return const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]);
      case "credential": return const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)]);
      default: return const LinearGradient(colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isContentSet = item.content.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(gradient: _getTypeColor(item.type), borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827), fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(item.type.toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isContentSet)
                          GestureDetector(
                            onTap: onToggleVisibility,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                              child: Icon(item.isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF), size: 20),
                            ),
                          ),
                      ],
                    ),
                    if (item.isVisible && isContentSet)
                      _buildVisibleContent(context)
                    else if (!isContentSet)
                      _buildEmptyContent(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text(item.lastAccessed, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        if (!isContentSet)
                          GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(8)),
                              child: const Text('Añadir Dato', style: TextStyle(fontSize: 12, color: Color(0xFF3F51B5), fontWeight: FontWeight.w500)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibleContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
        child: Row(
          children: [
            const Icon(Icons.lock_open_outlined, size: 14, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(child: Text(item.content, style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Color(0xFF374151), letterSpacing: 1.5))),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.content));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
              },
              child: const Icon(Icons.copy_outlined, size: 16, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6), style: BorderStyle.solid)),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: Color(0xFF9CA3AF)),
            SizedBox(width: 8),
            Text('[DATO NO ESTABLECIDO]', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}