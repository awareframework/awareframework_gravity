import 'package:test/test.dart';

import 'package:awareframework_gravity/awareframework_gravity.dart';

void main(){
  test("sensor sensor config", (){
    var config = GravitySensorConfig();
    expect(config.debug, false);
  });
}
