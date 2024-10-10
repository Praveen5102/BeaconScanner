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
        scaffoldBackgroundColor: Colors.white, // Bright background color
      ),
      home: BeaconScannerPage(),
    );
  }
}

class BeaconScannerPage extends StatefulWidget {
  @override
  _BeaconScannerPageState createState() => _BeaconScannerPageState();
}

class _BeaconScannerPageState extends State<BeaconScannerPage>
    with SingleTickerProviderStateMixin {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
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
        scanResults = results;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.blue], // Vibrant gradient colors
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
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.orange[100], // Vibrant body background color
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.black),
                  SizedBox(width: 8),
                  Text('No filter', style: TextStyle(color: Colors.black)),
                  Expanded(child: SizedBox()),
                  Icon(Icons.arrow_drop_down, color: Colors.black),
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
                              Text('${DateTime.now().difference(result.timeStamp).inMilliseconds} ms', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => showDeviceDetails(result), // Show device details on tap
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
