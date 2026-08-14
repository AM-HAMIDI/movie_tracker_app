import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/list_provider.dart';

class CreateEditListSheet extends StatefulWidget {
  const CreateEditListSheet({super.key});

  @override
  State<CreateEditListSheet> createState() => _CreateEditListSheetState();
}

class _CreateEditListSheetState extends State<CreateEditListSheet> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    context.read<ListProvider>().createList(name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('New Custom List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'List Name (e.g. Marvel Marathon)',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Create List'),
          ),
        ],
      ),
    );
  }
}