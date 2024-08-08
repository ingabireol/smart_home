import 'package:flutter/material.dart';
import 'package:smarthome/geofence_screen.dart';
import 'motion_detection_screen.dart';
import 'light_detection_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Motion Detection'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MotionDetectionScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Light Sensing'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LightSensingScreen()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Geofencing'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPagez()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
