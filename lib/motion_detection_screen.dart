import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MotionDetectionScreen extends StatefulWidget {
  @override
  _MotionDetectionScreenState createState() => _MotionDetectionScreenState();
}

class _MotionDetectionScreenState extends State<MotionDetectionScreen> {
  List<double> _accelerometerValues = [0, 0, 0];
  List<FlSpot> _accelerometerData = [];
  Timer? _timer;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isMoving = false;
  bool _hasNotified = false;
  bool _initialCalibrated = false;
  int _timestamp = 0;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _initAccelerometer();
    _initNotifications();
    _calibrateInitialState();
  }

  void _initAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_initialCalibrated) return;

      setState(() {
        _accelerometerValues = [event.x, event.y, event.z];
        _updateAccelerometerData();
      });
      _checkForSignificantChange();
    });

    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      // Reduced the interval to 50ms
      setState(() {});
    });
  }

  void _calibrateInitialState() {
    // Ignore initial readings for 2 seconds to avoid false positives
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _initialCalibrated = true;
      });
    });
  }

  void _updateAccelerometerData() {
    _timestamp++;
    if (_accelerometerData.length >= 50) {
      _accelerometerData.removeAt(0);
    }
    _accelerometerData
        .add(FlSpot(_timestamp.toDouble(), _accelerometerValues[1]));
  }

  void _checkForSignificantChange() {
    double magnitude =
        _accelerometerValues.map((v) => v * v).reduce((a, b) => a + b);

    if (magnitude > 15) {
      // Lowered the threshold for quicker detection
      if (!_isMoving) {
        _isMoving = true;
        _hasNotified = false;
      }
    } else {
      if (_isMoving) {
        _isMoving = false;
      }
    }

    if (_isMoving && !_hasNotified) {
      _showNotification("Significant motion detected!");
      _hasNotified = true;
    }
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'motion_detection_channel',
      'Motion Detection Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Motion Alert',
      message,
      platformChannelSpecifics,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelerometerSubscription.cancel(); // Ensure to cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Motion Detection')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              'Accelerometer: ${_accelerometerValues.map((v) => v.toStringAsFixed(1)).join(', ')}'),
          SizedBox(height: 20),
          Container(
            height: 200,
            padding: EdgeInsets.all(20),
            child: LineChart(
              LineChartData(
                minY: -10,
                maxY: 10,
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _accelerometerData.isNotEmpty
                        ? _accelerometerData
                        : [FlSpot(0, 0)],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
