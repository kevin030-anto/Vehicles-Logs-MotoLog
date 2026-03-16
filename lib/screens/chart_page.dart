import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/vehicle_provider.dart';
import '../providers/log_provider.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<VehicleProvider>(context, listen: false).loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Spending Chart')),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          if (vehicleProvider.isLoading)
            return const Center(child: CircularProgressIndicator());

          if (vehicleProvider.vehicles.isEmpty) {
            return const Center(child: Text('No vehicles available.'));
          }

          // Initial selection logic
          if (_selectedVehicleId == null &&
              vehicleProvider.vehicles.isNotEmpty) {
            _selectedVehicleId = vehicleProvider.vehicles.first.id;
            Future.microtask(
              () => Provider.of<LogProvider>(
                context,
                listen: false,
              ).loadLogs(_selectedVehicleId!),
            );
          } else if (_selectedVehicleId != null &&
              !vehicleProvider.vehicles.any(
                (v) => v.id == _selectedVehicleId,
              )) {
            if (vehicleProvider.vehicles.isNotEmpty) {
              _selectedVehicleId = vehicleProvider.vehicles.first.id;
              Future.microtask(
                () => Provider.of<LogProvider>(
                  context,
                  listen: false,
                ).loadLogs(_selectedVehicleId!),
              );
            } else {
              _selectedVehicleId = null;
            }
          }

          return Column(
            children: [
              // Dropdown
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<int>(
                  value: _selectedVehicleId,
                  decoration: const InputDecoration(
                    labelText: 'Select Vehicle',
                    border: OutlineInputBorder(),
                  ),
                  items: vehicleProvider.vehicles.map((v) {
                    return DropdownMenuItem(
                      value: v.id,
                      child: Text('${v.name} (${v.licenseNumber})'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedVehicleId = newValue;
                    });
                    if (newValue != null) {
                      Provider.of<LogProvider>(
                        context,
                        listen: false,
                      ).loadLogs(newValue);
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Chart
              Expanded(
                child: Consumer<LogProvider>(
                  builder: (context, logProvider, child) {
                    if (logProvider.isLoading)
                      return const Center(child: CircularProgressIndicator());

                    if (logProvider.logs.isEmpty)
                      return const Center(
                        child: Text('No logs for this vehicle.'),
                      );

                    // Aggregate Data
                    Map<String, double> spending = {};
                    double total = 0;
                    for (var log in logProvider.logs) {
                      spending[log.category] =
                          (spending[log.category] ?? 0) + log.cost;
                      total += log.cost;
                    }

                    if (total == 0)
                      return const Center(child: Text('No spending recorded.'));

                    List<PieChartSectionData> sections = [];
                    int i = 0;
                    spending.forEach((category, amount) {
                      final isTouched = false;
                      final fontSize = isTouched ? 25.0 : 16.0;
                      final radius = isTouched ? 60.0 : 50.0;
                      const shadows = [
                        Shadow(color: Colors.black, blurRadius: 2),
                      ];

                      final colors = [
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.teal,
                      ];

                      sections.add(
                        PieChartSectionData(
                          color: colors[i % colors.length],
                          value: amount,
                          title:
                              '${(amount / total * 100).toStringAsFixed(1)}%',
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: shadows,
                          ),
                        ),
                      );
                      i++;
                    });

                    return Column(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                        // Legend
                        Expanded(
                          child: ListView(
                            children: spending.entries.map((e) {
                              int index = spending.keys.toList().indexOf(e.key);
                              final colors = [
                                Colors.blue,
                                Colors.red,
                                Colors.green,
                                Colors.orange,
                                Colors.purple,
                                Colors.teal,
                              ];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      colors[index % colors.length],
                                  radius: 10,
                                ),
                                title: Text(e.key),
                                trailing: Text(
                                  '\$${e.value.toStringAsFixed(2)}',
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
