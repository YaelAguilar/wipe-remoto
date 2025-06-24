import 'package:flutter/material.dart';
import '../../models/sensitive_data.dart';

class EditDataDialog extends StatefulWidget {
  final SensitiveData item;
  final Function(String newTitle, String newContent) onSave;

  const EditDataDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<EditDataDialog> createState() => _EditDataDialogState();
}

class _EditDataDialogState extends State<EditDataDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _contentController = TextEditingController(text: widget.item.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdding = widget.item.content.isEmpty;

    return AlertDialog(
      title: Text(isAdding ? 'Añadir Dato' : 'Editar Dato'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'El título no puede estar vacío' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: isAdding ? 'Dato Secreto' : 'Contenido',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'El dato no puede estar vacío' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _titleController.text,
                _contentController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(isAdding ? 'Guardar' : 'Guardar Cambios'),
        ),
      ],
    );
  }
}