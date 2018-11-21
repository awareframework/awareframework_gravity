import Flutter
import UIKit
import SwiftyJSON
import com_awareframework_ios_sensor_gravity
import com_awareframework_ios_sensor_core
import awareframework_core

public class SwiftAwareframeworkGravityPlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler, GravityObserver {

    var gravitySensor:GravitySensor?
    
    public func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor? {
        if self.sensor == nil {
            if let config = call.arguments as? Dictionary<String,Any>{
                let json = JSON.init(config)
                self.gravitySensor = GravitySensor.init(GravitySensor.Config(json))
            }else{
                self.gravitySensor = GravitySensor.init(GravitySensor.Config())
            }
            self.gravitySensor?.CONFIG.sensorObserver = self
            return self.gravitySensor
        }else{
            return nil
        }
    }

    public override init() {
        super.init()
        super.initializationCallEventHandler = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        // add own channel
        super.setChannels(with: registrar,
                          instance: SwiftAwareframeworkGravityPlugin(),
                          methodChannelName: "awareframework_gravity/method",
                          eventChannelName: "awareframework_gravity/event")

    }

    public func onDataChanged(data: GravityData) {
        for handler in self.streamHandlers {
            if handler.eventName == "on_data_changed" {
                handler.eventSink(data.toDictionary())
            }
        }
    }
}
