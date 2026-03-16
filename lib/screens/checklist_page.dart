import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';
import '../providers/checklist_provider.dart';
import 'add_checklist_dialog.dart';

class ChecklistPage extends StatefulWidget {
  final Vehicle vehicle;

  const ChecklistPage({super.key, required this.vehicle});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ChecklistProvider>(
        context,
        listen: false,
      ).loadChecklist(widget.vehicle.id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.items.isEmpty) {
          return const Center(child: Text('No checklist items.'));
        }

        return ListView.builder(
          itemCount: provider.items.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            final item = provider.items[index];
            bool isDone = item.isCompleted == 1;

            return Dismissible(
              key: Key(item.id.toString()),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  // Delete
                  return true;
                } else {
                  // Edit
                  showDialog(
                    context: context,
                    builder: (context) => AddChecklistDialog(
                      vehicleId: widget.vehicle.id!,
                      itemToEdit: item,
                    ),
                  );
                  return false;
                }
              },
              onDismissed: (direction) {
                provider.deleteChecklist(item.id!, widget.vehicle.id!);
              },
              background: Container(
                color: Colors.blue,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                child: InkWell(
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Edit'),
                            onTap: () {
                              Navigator.pop(ctx);
                              showDialog(
                                context: context,
                                builder: (context) => AddChecklistDialog(
                                  vehicleId: widget.vehicle.id!,
                                  itemToEdit: item,
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Delete'),
                            onTap: () async {
                              Navigator.pop(ctx);
                              provider.deleteChecklist(
                                item.id!,
                                widget.vehicle.id!,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: CheckboxListTile(
                    value: isDone,
                    title: Text(
                      item.title,
                      style: TextStyle(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Added: ${item.dateAdded}'),
                        if (item.targetDate != null)
                          Text(
                            'Target: ${item.targetDate}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        if (isDone && item.dateCompleted != null)
                          Text(
                            'Completed: ${item.dateCompleted}',
                            style: const TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                    onChanged: (val) {
                      provider.toggleComplete(item, val ?? false);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
