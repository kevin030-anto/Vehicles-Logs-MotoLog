import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'vehicle_detail_page.dart';
import 'vehicle_dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load vehicles when the page initializes
    Future.microtask(
      () => Provider.of<VehicleProvider>(context, listen: false).loadVehicles(),
    );
  }

  IconData _getVehicleIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
        return Icons.two_wheeler;
      case 'scooty':
        return Icons.moped;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Log'), elevation: 0),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          if (vehicleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vehicleProvider.vehicles.isEmpty) {
            return const Center(
              child: Text('No vehicles added yet. Tap + to add one.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehicleProvider.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicleProvider.vehicles[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      _getVehicleIcon(vehicle.icon),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    vehicle.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.licenseNumber),
                      Text('${vehicle.currentKm.toStringAsFixed(1)} KM'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VehicleDashboardPage(vehicle: vehicle),
                      ),
                    ).then((_) {
                      // Refresh list on return
                      Provider.of<VehicleProvider>(
                        context,
                        listen: false,
                      ).loadVehicles();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VehicleDetailPage(), // Add mode
            ),
          ).then((_) {
            Provider.of<VehicleProvider>(context, listen: false).loadVehicles();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
