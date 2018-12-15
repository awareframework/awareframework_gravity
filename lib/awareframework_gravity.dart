import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';


/// The Gravity measures the acceleration applied to the sensor
/// built-in into the device, including the force of gravity.
///
/// Your can initialize this class by the following code.
/// ```dart
/// var sensor = GravitySensor();
/// ```
///
/// If you need to initialize the sensor with configurations,
/// you can use the following code instead of the above code.
/// ```dart
/// var config =  GravitySensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
///
/// var sensor = GravitySensor.init(config);
/// ```
///
/// Each sub class of AwareSensor provides the following method for controlling
/// the sensor:
/// - `start()`
/// - `stop()`
/// - `enable()`
/// - `disable()`
/// - `sync()`
/// - `setLabel(String label)`
///
/// `Stream<GravityData>` allow us to monitor the sensor update
/// events as follows:
///
/// ```dart
/// sensor.onDataChanged.listen((data) {
///   print(data)
/// }
/// ```
///
/// In addition, this package support data visualization function on Cart Widget.
/// You can generate the Cart Widget by following code.
/// ```dart
/// var card = GravityCard(sensor: sensor);
/// ```
class GravitySensor extends AwareSensor {
  static const MethodChannel _gravityMethod = const MethodChannel('awareframework_gravity/method');
  static const EventChannel  _gravityStream  = const EventChannel('awareframework_gravity/event');

  static const EventChannel  _onDataChangedStream  = const EventChannel('awareframework_gravity/event_on_data_changed');

  static StreamController<GravityData> onDataChangedStreamController = StreamController<GravityData>();

  GravityData data = GravityData();

  /// Init Gravity Sensor without a configuration file
  ///
  /// ```dart
  /// var sensor = GravitySensor.init(null);
  /// ```
  GravitySensor():this.init(null);

  /// Init Gravity Sensor with GravitySensorConfig
  ///
  /// ```dart
  /// var config =  GravitySensorConfig();
  /// config
  ///   ..debug = true
  ///   ..frequency = 100;
  ///
  /// var sensor = GravitySensor.init(config);
  /// ```
  GravitySensor.init(GravitySensorConfig config) : super(config){
    super.setMethodChannel(_gravityMethod);
  }

  /// An event channel for monitoring sensor events.
  ///
  /// `Stream<GravityData>` allow us to monitor the sensor update
  /// events as follows:
  ///
  /// ```dart
  /// sensor.onDataChanged.listen((data) {
  ///   print(data)
  /// }
  ///

  Stream<GravityData> get onDataChanged{
    onDataChangedStreamController.close();
    onDataChangedStreamController = StreamController<GravityData>();
    return onDataChangedStreamController.stream;
  }

  @override
  Future<Null> start() {
    super.getBroadcastStream(_onDataChangedStream, "on_data_changed").map(
            (dynamic event) => GravityData.from(Map<String,dynamic>.from(event))
    ).listen((event){
      this.data = event;
      if(!onDataChangedStreamController.isClosed){
        onDataChangedStreamController.add(event);
      }
    });
    return super.start();
  }

  @override
  Future<Null> stop() {
    super.cancelBroadcastStream("on_data_changed");
    return super.stop();
  }

}

/// A configuration class of GravitySensor
///
/// You can initialize the class by following code.
///
/// ```dart
/// var config =  GravitySensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
/// ```
class GravitySensorConfig extends AwareSensorConfig{
  GravitySensorConfig();

  int frequency    = 5;
  double period    = 1.0;
  double threshold = 0.0;

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['frequency'] = frequency;
    map['period']    = period;
    map['threshold'] = threshold;
    return map;
  }
}

/// A data model of GravitySensor
///
/// This class converts sensor data that is Map<String,dynamic> format, to a
/// se
///
class GravityData extends AwareData {
  Map<String,dynamic> source;
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  int eventTimestamp = 0;
  GravityData():this.from(null);
  GravityData.from(Map<String,dynamic> data):super.from(data){
    if(data != null){
      x = data["x"];
      y = data["y"];
      z = data["z"];
      eventTimestamp = data["eventTimestamp"];
    }
  }

  @override
  String toString() {
    if (this.source != null){
      return this.source.toString();
    }
    return super.toString();
  }
}

///
/// A Card Widget of Gravity Sensor
///
/// You can generate a Cart Widget by following code.
/// ```dart
/// var card = GravityCard(sensor: sensor);
/// ```
class GravityCard extends StatefulWidget {
  GravityCard({Key key, @required this.sensor,
                                  this.bufferSize=299,
                                  this.height=250.0}) : super(key: key);

  final GravitySensor sensor;
  final int bufferSize;
  final double height;

  final List<LineSeriesData> dataLine1 = List<LineSeriesData>();
  final List<LineSeriesData> dataLine2 = List<LineSeriesData>();
  final List<LineSeriesData> dataLine3 = List<LineSeriesData>();

  @override
  GravityCardState createState() => new GravityCardState();
}

///
/// A Card State of Gravity Sensor
///
class GravityCardState extends State<GravityCard> {

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {
      if(mounted){
        setState((){
          if(event!=null){
            DateTime.fromMicrosecondsSinceEpoch(event.timestamp);
            var buffer = widget.bufferSize;
            double x = event.x;
            double y = event.y;
            double z = event.z;
            StreamLineSeriesChart.add(data:x, into:widget.dataLine1, id:"x", buffer: buffer);
            StreamLineSeriesChart.add(data:y, into:widget.dataLine2, id:"y", buffer: buffer);
            StreamLineSeriesChart.add(data:z, into:widget.dataLine3, id:"z", buffer: buffer);
          }
        });
      }
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
  }

  @override
  Widget build(BuildContext context) {
    var data = StreamLineSeriesChart.createTimeSeriesData(
        widget.dataLine1,
        widget.dataLine2,
        widget.dataLine3
    );
    return new AwareCard(
      contentWidget: SizedBox(
          height:widget.height,
          width: MediaQuery.of(context).size.width*0.8,
          child: new StreamLineSeriesChart(data),
        ),
      title: "Gravity",
      sensor: widget.sensor
    );
  }
}
