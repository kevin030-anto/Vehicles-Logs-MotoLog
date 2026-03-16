import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import 'vehicle_detail_page.dart';
import 'log_page.dart';
import 'checklist_page.dart';
import 'add_log_page.dart';
import 'add_checklist_dialog.dart'; // We'll create a dialog for checklist

class VehicleDashboardPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDashboardPage({super.key, required this.vehicle});

  @override
  State<VehicleDashboardPage> createState() => _VehicleDashboardPageState();
}

class _VehicleDashboardPageState extends State<VehicleDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Vehicle _currentVehicle;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentVehicle = widget.vehicle;
  }

  // This helps update the UI when the vehicle is updated (e.g. from Add Log)
  void _refreshVehicle() async {
    // Reload vehicle from DB to get latest stats
    // Or just listen to provider if the list updates.
    // Since we passed vehicle by value, we need to find it in the provider.
    final provider = Provider.of<VehicleProvider>(context, listen: false);
    final found = provider.vehicles.where((v) => v.id == widget.vehicle.id);
    if (found.isNotEmpty) {
      setState(() {
        _currentVehicle = found.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to vehicle provider to update header info automatically
    final vehicle = Provider.of<VehicleProvider>(context).vehicles.firstWhere(
      (v) => v.id == widget.vehicle.id,
      orElse: () => widget.vehicle,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VehicleDetailPage(vehicle: vehicle),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Vehicle'),
                  content: const Text(
                    'Are you sure? This will delete all logs.',
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
              if (confirm == true) {
                if (mounted) {
                  await Provider.of<VehicleProvider>(
                    context,
                    listen: false,
                  ).deleteVehicle(vehicle.id!);
                  Navigator.pop(context); // Go back to Home
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant, // Slightly different user
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.licenseNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${vehicle.currentKm.toStringAsFixed(1)} KM',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Spent', style: TextStyle(fontSize: 12)),
                    Text(
                      '\$${vehicle.totalSpent.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Logs'),
              Tab(text: 'Maintenance Checklist'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                LogPage(vehicle: vehicle),
                ChecklistPage(vehicle: vehicle),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            // Add Log
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddLogPage(vehicle: vehicle),
              ),
            );
          } else {
            // Add Checklist
            showDialog(
              context: context,
              builder: (context) => AddChecklistDialog(vehicleId: vehicle.id!),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
