import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';

class VehicleDetailPage extends StatefulWidget {
  final Vehicle? vehicle; // If null, it's Add mode. If exists, Edit mode.

  const VehicleDetailPage({super.key, this.vehicle});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _fuelCapacityController = TextEditingController();
  final _mileageController = TextEditingController();
  final _rangeController = TextEditingController();
  final _kmController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedIcon = 'car';
  String _selectedFuelType = 'Petrol';
  DateTime? _purchaseDate;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      // Edit Mode
      _nameController.text = widget.vehicle!.name;
      _licenseController.text = widget.vehicle!.licenseNumber;
      _selectedIcon = widget.vehicle!.icon;
      _selectedFuelType = widget.vehicle!.fuelType;
      _fuelCapacityController.text =
          widget.vehicle!.fuelCapacity?.toString() ?? '';
      _mileageController.text = widget.vehicle!.mileage?.toString() ?? '';
      _rangeController.text = widget.vehicle!.rangePerCharge?.toString() ?? '';
      _kmController.text = widget.vehicle!.currentKm.toString();
      _insuranceController.text = widget.vehicle!.insuranceNumber ?? '';
      _notesController.text = widget.vehicle!.notes ?? '';
      if (widget.vehicle!.purchaseDate != null) {
        _purchaseDate = DateTime.parse(widget.vehicle!.purchaseDate!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _fuelCapacityController.dispose();
    _mileageController.dispose();
    _rangeController.dispose();
    _kmController.dispose();
    _insuranceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id, // Keep ID if editing
        icon: _selectedIcon,
        name: _nameController.text,
        licenseNumber: _licenseController.text.toUpperCase(),
        fuelType: _selectedFuelType,
        fuelCapacity: double.tryParse(_fuelCapacityController.text),
        mileage: double.tryParse(_mileageController.text),
        rangePerCharge: double.tryParse(_rangeController.text),
        currentKm: double.parse(_kmController.text),
        purchaseDate: _purchaseDate?.toIso8601String(),
        insuranceNumber: _insuranceController.text,
        notes: _notesController.text,
        totalSpent: widget.vehicle?.totalSpent ?? 0.0,
      );

      final provider = Provider.of<VehicleProvider>(context, listen: false);
      if (widget.vehicle == null) {
        provider.addVehicle(vehicle);
      } else {
        provider.updateVehicle(vehicle);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEv = _selectedFuelType == 'EV';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Selection
              const Text(
                'Select Icon',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _iconSelection('car', Icons.directions_car),
                  _iconSelection('bike', Icons.two_wheeler),
                  _iconSelection('scooty', Icons.moped),
                ],
              ),
              const SizedBox(height: 16),

              // Core Details
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Vehicle Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _licenseController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'License Number',
                  hintText: 'TN99 AD1234',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter license number' : null,
                onChanged: (value) {
                  _licenseController.value = _licenseController.value.copyWith(
                    text: value.toUpperCase(),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Fuel Type
              const Text(
                'Fuel Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _fuelTypeChip('Petrol'),
                  const SizedBox(width: 8),
                  _fuelTypeChip('Diesel'),
                  const SizedBox(width: 8),
                  _fuelTypeChip('EV'),
                ],
              ),
              const SizedBox(height: 16),

              // Conditional Fields
              if (!isEv) ...[
                TextFormField(
                  controller: _fuelCapacityController,
                  decoration: const InputDecoration(
                    labelText: 'Fuel Tank Capacity (Liters)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(
                    labelText: 'Mileage (KM/L)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                TextFormField(
                  controller: _rangeController,
                  decoration: const InputDecoration(
                    labelText: 'Range (KM per Charge)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 16),

              // Primary Data
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(
                  labelText: 'Current Kilometer Range',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Optional
              ListTile(
                title: Text(
                  _purchaseDate == null
                      ? 'Select Purchase Date'
                      : 'Date: ${DateFormat('yyyy-MM-dd').format(_purchaseDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate ?? DateTime.now(),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _purchaseDate = picked;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _insuranceController,
                decoration: const InputDecoration(
                  labelText: 'Insurance Number (Optional)',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveVehicle,
                  child: const Text('Save Vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconSelection(String value, IconData icon) {
    bool isSelected = _selectedIcon == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIcon = value;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[200],
            radius: 30,
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toUpperCase(),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fuelTypeChip(String label) {
    bool isSelected = _selectedFuelType == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFuelType = label;
          });
        }
      },
    );
  }
}
