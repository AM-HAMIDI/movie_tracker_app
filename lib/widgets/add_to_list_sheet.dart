import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/list_provider.dart';

class AddToListSheet extends StatefulWidget {
  final String imdbId;
  const AddToListSheet({super.key, required this.imdbId});

  @override
  State<AddToListSheet> createState() => _AddToListSheetState();
}

class _AddToListSheetState extends State<AddToListSheet> {
  @override
  void initState() {
    super.initState();
    // Moved here! This ensures the lists are fetched ONLY ONCE when the sheet opens,
    // completely eliminating the infinite loading and blinking loop.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListProvider>().fetchCustomLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<ListProvider>();
    final customLists = listProvider.customLists;

    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add to Custom List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: listProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : customLists.isEmpty
                      ? const Center(child: Text('No custom lists found. Create one first!'))
                      : ListView.builder(
                          itemCount: customLists.length,
                          itemBuilder: (context, index) {
                            final list = customLists[index];
                            // Check if the current movie is in this specific list
                            final bool isInList = list.itemImdbIds.contains(widget.imdbId);

                            return CheckboxListTile(
                              title: Text(list.name),
                              value: isInList,
                              activeColor: Colors.deepPurpleAccent,
                              onChanged: (bool? value) async {
                                if (value == true) {
                                  await listProvider.addItemToList(list.id, widget.imdbId);
                                } else {
                                  await listProvider.removeItemFromList(list.id, widget.imdbId);
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}