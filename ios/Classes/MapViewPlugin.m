#import "MapViewPlugin.h"
#import "MapViewController.h"
#import "MapAnnotation.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation MapViewPlugin

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"com.apptreesoftware.map_view"
                  binaryMessenger:[registrar messenger]];
    UIViewController *host = UIApplication.sharedApplication.delegate.window.rootViewController;
    MapViewPlugin *instance = [[MapViewPlugin alloc] initWithHost:host channel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)initWithHost:(UIViewController *)host channel:(FlutterMethodChannel *)channel {
    if (self = [super init]) {
        self.host = host;
        self.channel = channel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"show" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        NSString *apiKey = args[@"apiKey"];
        if (apiKey) {
            [GMSServices provideAPIKey:apiKey];
        }
        MapViewController *vc = [[MapViewController alloc] initWithPlugin:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.host presentViewController:navController animated:true completion:nil];
        self.mapViewController = vc;
        [self.mapViewController setLocationEnabled:[call.arguments[@"showUserLocation"] boolValue]];
        result(@YES);
    } else if ([@"setAnnotations" isEqualToString:call.method]) {
        [self handleSetAnnotations:call.arguments];
        result(@YES);
    } else if ([@"setCamera" isEqualToString:call.method]) {
        [self handleSetCamera:call.arguments];
        result(@YES);
    } else if ([@"zoomToFit" isEqualToString:call.method]) {
        [self.mapViewController zoomToAnnotations];
        result(@YES);
    } else if ([@"getCenter" isEqualToString:call.method]) {
        CLLocationCoordinate2D location = self.mapViewController.centerLocation;
        result(@{@"latitude": @(location.latitude), @"longitude": @(location.longitude)});
    } else if ([@"getZoomLevel" isEqualToString:call.method]) {
        result(@(self.mapViewController.zoomLevel));
    } else if ([@"dismiss" isEqualToString:call.method]) {
        if (self.mapViewController) {
            [self.host dismissViewControllerAnimated:true completion:nil];
        }
        [self.mapViewController shutdown];
        self.mapViewController = nil;
        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleSetAnnotations:(NSArray *)annotations {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *aDict in annotations) {
        MapAnnotation *annotation = [MapAnnotation annotationFromDictionary:aDict];
        if (annotation) {
            [array addObject:annotation];
        }
    }
    [self.mapViewController updateAnnotations:array];
}

- (void)handleDismiss {
    [self.mapViewController shutdown];
    [self.mapViewController.navigationController dismissViewControllerAnimated:true completion:nil];
    self.mapViewController = nil;
}

- (void)handleSetCamera:(NSDictionary *)cameraUpdate {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([cameraUpdate[@"latitude"] doubleValue], [cameraUpdate[@"longitude"] doubleValue]);
    [self.mapViewController setCamera:coordinate zoom:[cameraUpdate[@"zoom"] floatValue]];
}

- (void)locationDidUpdate:(CLLocation *)location {
    [self.channel invokeMethod:@"locationUpdated" arguments:@{@"latitude": @(location.coordinate.latitude), @"longitude": @(location.coordinate.longitude)}];
}

- (void)annotationTapped:(NSString *)identifier {
    [self.channel invokeMethod:@"annotationTapped" arguments:identifier];
}

- (void)mapTapped:(CLLocationCoordinate2D)coordinate {
    [self.channel invokeMethod:@"mapTapped" arguments:@{@"latitude": @(coordinate.latitude), @"longitude": @(coordinate.longitude)}];
}

- (void)cameraPositionChanged:(GMSCameraPosition *)position {
    [self.channel invokeMethod:@"cameraPositionChanged" arguments:@{
            @"latitude" : @(position.target.latitude),
            @"longitude" : @(position.target.longitude),
            @"zoom" : @(position.zoom)
    }];
}

@end
