import 'dart:async';
import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LightSensingScreen extends StatefulWidget {
  @override
  _LightSensingScreenState createState() => _LightSensingScreenState();
}

class _LightSensingScreenState extends State<LightSensingScreen> {
  Light? _light;
  StreamSubscription? _subscription;
  int _luxLevel = 0;
  String _lightStatus = 'Unknown';
  Color _bulbColor = Colors.yellow;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initNotifications();
  }

  Future<void> initPlatformState() async {
    try {
      _light = Light();
      _subscription = _light?.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void onData(int luxValue) async {
    setState(() {
      _luxLevel = luxValue;
      if (luxValue < 50) {
        _lightStatus = 'Dark';
        _bulbColor = Colors.yellow.withOpacity(1.0);
        _showNotification('Low light detected', 'Turning on smart lights');
      } else if (luxValue < 1000) {
        _lightStatus = 'Dim';
        _bulbColor = Colors.yellow.withOpacity(0.5);
      } else {
        _lightStatus = 'Bright';
        _bulbColor = Colors.yellow.withOpacity(0.2);
        _showNotification('Bright light detected', 'Turning off smart lights');
      }
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'light_level_channel',
      'Light Level Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Level Sensing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current light level:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '$_luxLevel lux',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Light status: $_lightStatus',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            Icon(
              Icons.lightbulb,
              size: 100,
              color: _bulbColor,
            ),
            Text(
              'Simulated Smart Light',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
