import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/checklist_item.dart';
import '../providers/checklist_provider.dart';

class AddChecklistDialog extends StatefulWidget {
  final int vehicleId;
  final ChecklistItem? itemToEdit;

  const AddChecklistDialog({
    super.key,
    required this.vehicleId,
    this.itemToEdit,
  });

  @override
  State<AddChecklistDialog> createState() => _AddChecklistDialogState();
}

class _AddChecklistDialogState extends State<AddChecklistDialog> {
  final _titleController = TextEditingController();
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _titleController.text = widget.itemToEdit!.title;
      if (widget.itemToEdit!.targetDate != null) {
        try {
          _targetDate = DateTime.parse(
            widget.itemToEdit!.targetDate!,
          ); // Assuming stored as ISO string if full date, but likely just string.
          // Requirement: "target 'finish date'". Let's stick to YYYY-MM-DD string.
          // Actually, YYYY-MM-DD is easy to parse.
        } catch (e) {
          // ignore
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.itemToEdit == null
            ? 'Add Checklist Item'
            : 'Edit Checklist Item',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Task Description'),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(
              _targetDate == null
                  ? 'Target Finish Date'
                  : DateFormat('yyyy-MM-dd').format(_targetDate!),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _targetDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _targetDate = picked);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              final item = ChecklistItem(
                id: widget.itemToEdit?.id,
                vehicleId: widget.vehicleId,
                title: _titleController.text,
                dateAdded:
                    widget.itemToEdit?.dateAdded ??
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                targetDate: _targetDate != null
                    ? DateFormat('yyyy-MM-dd').format(_targetDate!)
                    : null,
                isCompleted: widget.itemToEdit?.isCompleted ?? 0,
                dateCompleted: widget.itemToEdit?.dateCompleted,
              );

              if (widget.itemToEdit == null) {
                Provider.of<ChecklistProvider>(
                  context,
                  listen: false,
                ).addChecklist(item);
              } else {
                Provider.of<ChecklistProvider>(
                  context,
                  listen: false,
                ).updateChecklist(item);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
