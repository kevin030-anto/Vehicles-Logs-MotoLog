import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';
import '../models/log_entry.dart';
import '../providers/log_provider.dart';
import 'add_log_page.dart'; // Reuse for edit

class LogPage extends StatefulWidget {
  final Vehicle vehicle;

  const LogPage({super.key, required this.vehicle});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<LogProvider>(
        context,
        listen: false,
      ).loadLogs(widget.vehicle.id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (context, logProvider, child) {
        if (logProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (logProvider.logs.isEmpty) {
          return const Center(child: Text('No logs found.'));
        }

        return ListView.builder(
          itemCount: logProvider.logs.length,
          padding: const EdgeInsets.only(bottom: 80), // Space for FAB
          itemBuilder: (context, index) {
            final log = logProvider.logs[index];
            return Dismissible(
              key: Key(log.id.toString()),
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
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  // Delete
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Log'),
                      content: const Text(
                        'Are you sure you want to delete this log? The cost will be deducted from total.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Edit
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddLogPage(vehicle: widget.vehicle, logToEdit: log),
                    ),
                  );
                  return false; // Don't dismiss
                }
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  Provider.of<LogProvider>(
                    context,
                    listen: false,
                  ).deleteLog(log, widget.vehicle);
                }
              },
              child: Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.build)),
                  title: Text(
                    log.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.shopName),
                      Text(
                        DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.parse(log.date)),
                      ),
                      if (log.notes != null && log.notes!.isNotEmpty)
                        Text(
                          log.notes!,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${log.cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddLogPage(
                                    vehicle: widget.vehicle,
                                    logToEdit: log,
                                  ),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Delete'),
                            onTap: () async {
                              Navigator.pop(ctx);
                              await Provider.of<LogProvider>(
                                context,
                                listen: false,
                              ).deleteLog(log, widget.vehicle);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
