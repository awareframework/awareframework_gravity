import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/// init sensor
class GravitySensor extends AwareSensorCore {
  static const MethodChannel _gravityMethod = const MethodChannel('awareframework_gravity/method');
  static const EventChannel  _gravityStream  = const EventChannel('awareframework_gravity/event');

  /// Init Gravity Sensor with GravitySensorConfig
  GravitySensor(GravitySensorConfig config):this.convenience(config);
  GravitySensor.convenience(config) : super(config){
    /// Set sensor method & event channels
    super.setMethodChannel(_gravityMethod);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> onDataChanged(String id){
     return super.getBroadcastStream(_gravityStream, "on_data_changed", id).map((dynamic event) => Map<String,dynamic>.from(event));
  }
}

class GravitySensorConfig extends AwareSensorConfig{
  GravitySensorConfig();

  /// TODO

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    return map;
  }
}

/// Make an AwareWidget
class GravityCard extends StatefulWidget {
  GravityCard({Key key, @required this.sensor}) : super(key: key);

  GravitySensor sensor;

  @override
  GravityCardState createState() => new GravityCardState();
}


class GravityCardState extends State<GravityCard> {

  List<LineSeriesData> dataLine1 = List<LineSeriesData>();
  List<LineSeriesData> dataLine2 = List<LineSeriesData>();
  List<LineSeriesData> dataLine3 = List<LineSeriesData>();
  int bufferSize = 299;

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged("ui").listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          StreamLineSeriesChart.add(data:event['x'], into:dataLine1, id:"x", buffer: bufferSize);
          StreamLineSeriesChart.add(data:event['y'], into:dataLine2, id:"y", buffer: bufferSize);
          StreamLineSeriesChart.add(data:event['z'], into:dataLine3, id:"z", buffer: bufferSize);
        }
      });
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
  }


  @override
  Widget build(BuildContext context) {
    return new AwareCard(
      contentWidget: SizedBox(
          height:250.0,
          width: MediaQuery.of(context).size.width*0.8,
          child: new StreamLineSeriesChart(StreamLineSeriesChart.createTimeSeriesData(dataLine1, dataLine2, dataLine3)),
        ),
      title: "Gravity",
      sensor: widget.sensor
    );
  }

  @override
  void dispose() {
    widget.sensor.cancelBroadcastStream("ui");
    super.dispose();
  }

}
