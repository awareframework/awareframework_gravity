import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_gravity/awareframework_gravity.dart';
import 'package:awareframework_core/awareframework_core.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  GravitySensor sensor;
  GravitySensorConfig config;

  @override
  void initState() {
    super.initState();

    config = GravitySensorConfig()
      ..frequency = 100
      ..dbType = DatabaseType.DEFAULT
      ..debug = true;

    sensor = new GravitySensor.init(config);

    sensor.start();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Plugin Example App'),
          ),
          body: new GravityCard(sensor: sensor,)
      ),
    );
  }
}
