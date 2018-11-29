import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';

/// init sensor
class GravitySensor extends AwareSensorCore {
  static const MethodChannel _gravityMethod = const MethodChannel('awareframework_gravity/method');
  static const EventChannel  _gravityStream  = const EventChannel('awareframework_gravity/event');

  /// Init Gravity Sensor with GravitySensorConfig
  GravitySensor(GravitySensorConfig config):this.convenience(config);
  GravitySensor.convenience(config) : super(config){
    super.setMethodChannel(_gravityMethod);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> get onDataChanged{
     return super.getBroadcastStream(_gravityStream, "on_data_changed").map((dynamic event) => Map<String,dynamic>.from(event));
  }

  @override
  void cancelAllEventChannels() {
    super.cancelBroadcastStream("on_data_changed");
  }
}

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

/// Make an AwareWidget
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


class GravityCardState extends State<GravityCard> {

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {

      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          var buffer = widget.bufferSize;
          double x = event['x'];
          double y = event['y'];
          double z = event['z'];
          StreamLineSeriesChart.add(data:x, into:widget.dataLine1, id:"x", buffer: buffer);
          StreamLineSeriesChart.add(data:y, into:widget.dataLine2, id:"y", buffer: buffer);
          StreamLineSeriesChart.add(data:z, into:widget.dataLine3, id:"z", buffer: buffer);
        }
      });
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
