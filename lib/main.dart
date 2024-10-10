import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Beacon Scanner',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: BeaconScannerPage(),
    );
  }
}

class BeaconScannerPage extends StatefulWidget {
  @override
  _BeaconScannerPageState createState() => _BeaconScannerPageState();
}

class _BeaconScannerPageState extends State<BeaconScannerPage> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  String filterName = '';
  double minRssi = -100;
  double maxRssi = 0;
  bool isConnectable = false;
  bool isAdvertising = false;

  final TextEditingController minRssiController = TextEditingController();
  final TextEditingController maxRssiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.location,
    ].request();
  }

  void startScan() {
    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results.where((result) {
          // Apply filters
          bool matchesName = result.device.name.toLowerCase().contains(filterName.toLowerCase());
          bool matchesRssi = result.rssi >= minRssi && result.rssi <= maxRssi;
          bool matchesType = (isConnectable && result.advertisementData.connectable) ||
              (isAdvertising && result.advertisementData.connectable);

          // If no filters are applied, include all devices
          if (!isConnectable && !isAdvertising && filterName.isEmpty) {
            return true; // Include all devices
          }

          return matchesName && matchesRssi && (isConnectable || isAdvertising);
        }).toList();
      });
    });

    Future.delayed(Duration(seconds: 10), () {
      stopScan();
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  void showDeviceDetails(ScanResult result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(result.device.name.isNotEmpty ? result.device.name : 'Unknown Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Device ID: ${result.device.remoteId}'),
              SizedBox(height: 8),
              Text('RSSI: ${result.rssi} dBm'),
              SizedBox(height: 8),
              Text('Timestamp: ${DateTime.now().difference(result.timeStamp).inMilliseconds} ms ago'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void refreshScan() {
    requestPermissions(); // Re-request permissions
    startScan(); // Restart scanning for devices
  }

  void applyFilters() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apply Filters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Device Name Filter'),
                  onChanged: (value) {
                    setState(() {
                      filterName = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text('RSSI Range'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minRssiController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Min RSSI'),
                        onChanged: (value) {
                          setState(() {
                            minRssi = double.tryParse(value) ?? -100;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxRssiController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Max RSSI'),
                        onChanged: (value) {
                          setState(() {
                            maxRssi = double.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Connectable'),
                  value: isConnectable,
                  onChanged: (bool? value) {
                    setState(() {
                      isConnectable = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Advertising'),
                  value: isAdvertising,
                  onChanged: (bool? value) {
                    setState(() {
                      isAdvertising = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startScan(); // Restart scan after applying filters
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void resetFilters() {
    setState(() {
      filterName = '';
      minRssi = -100;
      maxRssi = 0;
      isConnectable = false;
      isAdvertising = false;
      minRssiController.clear();
      maxRssiController.clear();
    });
    startScan(); // Restart scanning for devices
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: isScanning ? stopScan : startScan,
            child: Text(
              isScanning ? 'STOP' : 'SCAN',
              style: TextStyle(color: Colors.white),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'refresh') {
                refreshScan(); // Handle refresh action
              } else if (value == 'filter') {
                applyFilters(); // Show filter dialog
              } else if (value == 'no_filters') {
                resetFilters(); // Reset filters
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'refresh',
                  child: Text('Refresh'),
                ),
                PopupMenuItem<String>(
                  value: 'filter',
                  child: Text('Filters'),
                ),
                PopupMenuItem<String>(
                  value: 'no_filters',
                  child: Text('No Filters'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.orange[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Filters Applied', style: TextStyle(color: Colors.black)),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  ScanResult result = scanResults[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.bluetooth, color: Colors.blue),
                      title: Text(
                        result.device.name.isNotEmpty ? result.device.name : 'Unknown device',
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(result.device.remoteId.toString(), style: TextStyle(color: Colors.grey[600])),
                          Text('NOT BONDED', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${result.rssi} dBm', style: TextStyle(color: Colors.green)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sync, size: 16, color: Colors.black),
                              SizedBox(width: 4),
                              Text('${DateTime.now().difference(result.timeStamp).inSeconds} s ago'),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => showDeviceDetails(result),
                    ),
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
