#import <Flutter/Flutter.h>
#import <CoreLocation/CoreLocation.h>
@class MapViewController;

@class GMSCameraPosition;

@interface MapViewPlugin : NSObject<FlutterPlugin>

@property (nonatomic, assign) UIViewController *host;
@property (nonatomic, assign) FlutterMethodChannel *channel;
@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain) NSString *mapTitle;
- (void)onMapReady;
- (void)locationDidUpdate:(CLLocation *)location;
- (void)annotationTapped:(NSString *)identifier;
- (void)mapTapped:(CLLocationCoordinate2D)coordinate;
- (void)cameraPositionChanged:(GMSCameraPosition *)position;
@end
