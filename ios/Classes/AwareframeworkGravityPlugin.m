#import "AwareframeworkGravityPlugin.h"
#import <awareframework_gravity/awareframework_gravity-Swift.h>

@implementation AwareframeworkGravityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwareframeworkGravityPlugin registerWithRegistrar:registrar];
}
@end
