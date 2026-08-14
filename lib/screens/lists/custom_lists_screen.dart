import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../providers/list_provider.dart';
import 'widgets/create_edit_list_sheet.dart';

class CustomListsScreen extends StatefulWidget {
  const CustomListsScreen({super.key});

  @override
  State<CustomListsScreen> createState() => _CustomListsScreenState();
}

class _CustomListsScreenState extends State<CustomListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListProvider>().fetchCustomLists();
    });
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const CreateEditListSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<ListProvider>();

    return Scaffold(
      body: listProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : listProvider.customLists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No custom lists created yet.'),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _openCreateSheet, child: const Text('Create a List')),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: listProvider.customLists.length,
                  itemBuilder: (context, index) {
                    final item = listProvider.customLists[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.itemImdbIds.length} Titles'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => listProvider.deleteList(item.id),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, AppRouter.listDetail, arguments: item.id);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateSheet,
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}