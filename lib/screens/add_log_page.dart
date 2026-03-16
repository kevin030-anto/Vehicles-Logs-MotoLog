import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';
import '../models/log_entry.dart';
import '../providers/log_provider.dart';

class AddLogPage extends StatefulWidget {
  final Vehicle vehicle;
  final LogEntry? logToEdit;

  const AddLogPage({super.key, required this.vehicle, this.logToEdit});

  @override
  State<AddLogPage> createState() => _AddLogPageState();
}

class _AddLogPageState extends State<AddLogPage> {
  final _formKey = GlobalKey<FormState>();

  // Use a map or separate controllers
  final _kmController = TextEditingController();
  final _shopController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  // Specific
  final _nextOilKmController = TextEditingController();
  final _customNameController = TextEditingController();

  String _selectedCategory = 'Services';
  DateTime _selectedDate = DateTime.now();

  // Tags for Services
  final List<String> _availableTags = [
    'Tire',
    'Oil',
    'Break',
    'Light',
    'Engine',
    'Wash',
  ];
  final List<String> _selectedTags = [];

  final List<String> _categories = [
    'Services',
    'Oil Change',
    'Tire Change',
    'Other Changes',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicle.fuelType == 'EV') {
      _categories.remove('Oil Change');
      _categories.add('Battery Services');
    }

    if (widget.logToEdit != null) {
      _selectedCategory = widget.logToEdit!.category;
      _selectedDate = DateTime.parse(widget.logToEdit!.date);
      _kmController.text = widget.logToEdit!.currentKm.toString();
      _shopController.text = widget.logToEdit!.shopName;
      _costController.text = widget.logToEdit!.cost.toString();
      _notesController.text = widget.logToEdit!.notes ?? '';
      _nextOilKmController.text =
          widget.logToEdit!.nextOilChangeKm?.toString() ?? '';
      _customNameController.text = widget.logToEdit!.customName ?? '';

      if (widget.logToEdit!.tags != null &&
          widget.logToEdit!.tags!.isNotEmpty) {
        _selectedTags.addAll(widget.logToEdit!.tags!.split(','));
      }
    } else {
      _kmController.text = widget.vehicle.currentKm.toString();
    }
  }

  void _saveLog() {
    if (_formKey.currentState!.validate()) {
      final log = LogEntry(
        id: widget.logToEdit?.id,
        vehicleId: widget.vehicle.id!,
        category: _selectedCategory,
        date: _selectedDate.toIso8601String(),
        currentKm: double.parse(_kmController.text),
        shopName: _shopController.text,
        cost: double.parse(_costController.text),
        notes: _notesController.text,
        tags: _selectedTags.join(','),
        nextOilChangeKm: _selectedCategory == 'Oil Change'
            ? double.tryParse(_nextOilKmController.text)
            : null,
        customName: _selectedCategory == 'Other Changes'
            ? _customNameController.text
            : null,
      );

      final provider = Provider.of<LogProvider>(context, listen: false);
      if (widget.logToEdit == null) {
        provider.addLog(log, widget.vehicle);
      } else {
        provider.updateLog(log, widget.vehicle, widget.logToEdit!.cost);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.logToEdit == null ? 'Add Log' : 'Edit Log'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: widget.logToEdit == null
                    ? (val) {
                        setState(() {
                          _selectedCategory = val!;
                        });
                      }
                    : null, // Disable category change on edit to prevent data loss or complex logic
              ),
              const SizedBox(height: 16),

              // Common Fields
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(
                  labelText: 'Current Vehicle KM',
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _shopController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // Specific Fields
              if (_selectedCategory == 'Services') ...[
                const Text(
                  'Service Tags',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: _availableTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                // Custom tag input could be added here
              ],

              if (_selectedCategory == 'Oil Change') ...[
                TextFormField(
                  controller: _nextOilKmController,
                  decoration: const InputDecoration(
                    labelText: 'Next Oil Change KM',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],

              if (_selectedCategory == 'Other Changes') ...[
                TextFormField(
                  controller: _customNameController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Log Name (e.g. Mirror Replacement)',
                  ),
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveLog,
                  child: const Text('Save Log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
