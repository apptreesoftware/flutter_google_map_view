#import "MapViewPlugin.h"
#import "MapViewController.h"
#import "MapAnnotation.h"
#import "MapPolyline.h"
#import "MapPolygon.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation MapViewPlugin

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"com.apptreesoftware.map_view"
                  binaryMessenger:[registrar messenger]];
    UIViewController *host = UIApplication.sharedApplication.delegate.window.rootViewController;
    MapViewPlugin *instance = [[MapViewPlugin alloc] initWithHost:host channel:channel registrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)initWithHost:(UIViewController *)host channel:(FlutterMethodChannel *)channel registrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    if (self = [super init]) {
        self.host = host;
        self.channel = channel;
        self.registrar = registrar;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"setApiKey" isEqualToString:call.method]) {
        [GMSServices provideAPIKey:call.arguments];
        result(@YES);
    } else if ([@"show" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        NSDictionary *mapOptions = args[@"mapOptions"];
        NSDictionary *cameraDict = mapOptions[@"cameraPosition"];
        self.mapTitle = mapOptions[@"title"];

        if (mapOptions[@"mapViewType"]  != (id) [NSNull null]) {
             NSString *mapViewTypeName = mapOptions[@"mapViewType"];
             int mapType = [self getMapViewType:mapViewTypeName];
             self.mapViewType = mapType;
        }

        MapViewController *vc = [[MapViewController alloc] initWithPlugin:self
                                                          navigationItems:[self buttonItemsFromActions:args[@"actions"]]
                                                           cameraPosition:[self cameraPositionFromDict:cameraDict]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        navController.navigationBar.hidden = [mapOptions[@"hideToolbar"] boolValue];
        navController.navigationBar.translucent = NO;
        [self.host presentViewController:navController animated:true completion:nil];
        self.mapViewController = vc;
        [self.mapViewController setMapOptions:[mapOptions[@"showUserLocation"] boolValue] locationButton:[mapOptions[@"showMyLocationButton"] boolValue] compassButton:[mapOptions[@"showCompassButton"] boolValue]];
        result(@YES);
    } else if ([@"getVisibleMarkers" isEqualToString:call.method]) {
        result(self.mapViewController.visibleMarkers);
    } else if ([@"setAnnotations" isEqualToString:call.method]) {
        [self handleSetAnnotations:call.arguments];
        result(@YES);
    } else if ([@"clearAnnotations" isEqualToString:call.method]) {
        [self.mapViewController clearAnnotations];
        result(@YES);
    } else if ([@"addAnnotation" isEqualToString:call.method]) {
        [self handleAddAnnotation:call.arguments];
        result(@YES);
    } else if ([@"removeAnnotation" isEqualToString:call.method]) {
        [self handleRemoveAnnotation:call.arguments];
        result(@YES);
    } else if ([@"getVisiblePolylines" isEqualToString:call.method]) {
        result(self.mapViewController.visiblePolylines);
    } else if ([@"clearPolylines" isEqualToString:call.method]) {
        [self.mapViewController clearPolylines];
        result(@YES);
    } else if ([@"setPolylines" isEqualToString:call.method]) {
        [self handleSetPolylines:call.arguments];
        result(@YES);
    } else if ([@"addPolyline" isEqualToString:call.method]) {
        [self handleAddPolyline:call.arguments];
        result(@YES);
    } else if ([@"removePolyline" isEqualToString:call.method]) {
        [self handleRemovePolyline:call.arguments];
        result(@YES);
    } else if ([@"getVisiblePolygons" isEqualToString:call.method]) {
        result(self.mapViewController.visiblePolygons);
    } else if ([@"clearPolygons" isEqualToString:call.method]) {
        [self.mapViewController clearPolygons];
        result(@YES);
    } else if ([@"setPolygons" isEqualToString:call.method]) {
        [self handleSetPolygons:call.arguments];
        result(@YES);
    } else if ([@"addPolygon" isEqualToString:call.method]) {
        [self handleAddPolygon:call.arguments];
        result(@YES);
    } else if ([@"removePolygon" isEqualToString:call.method]) {
        [self handleRemovePolygon:call.arguments];
        result(@YES);
    } else if ([@"setCamera" isEqualToString:call.method]) {
        [self handleSetCamera:call.arguments];
        result(@YES);
    } else if ([@"zoomToFit" isEqualToString:call.method]) {
        [self.mapViewController zoomToAnnotations:[((NSNumber *) call.arguments) intValue]];
        result(@YES);
    } else if ([@"zoomToAnnotations" isEqualToString:call.method]) {
        [self handleZoomToAnnotations:call.arguments];
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


- (NSArray *)buttonItemsFromActions:(NSArray *)actions {
    NSMutableArray *buttons = [NSMutableArray array];
    if (actions) {
        for (NSDictionary *action in actions) {
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[action valueForKey:@"title"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(handleToolbar:)];
            button.tag = [[action valueForKey:@"identifier"] intValue];
            [buttons addObject:button];
        }
    }
    return buttons;
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

- (void)handleAddAnnotation:(NSDictionary *)dict {
    MapAnnotation *annotation = [MapAnnotation annotationFromDictionary:dict];
    if (annotation) {
        [self.mapViewController addAnnotation:annotation];
    }
}

- (void)handleRemoveAnnotation:(NSDictionary *)dict {
    MapAnnotation *annotation = [MapAnnotation annotationFromDictionary:dict];
    if (annotation) {
        [self.mapViewController removeAnnotation:annotation];
    }
}
- (void)handleSetPolylines:(NSArray *)polylines {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *aDict in polylines) {
        MapPolyline *polyline=[MapPolyline polylineFromDictionary:aDict];
        if (polyline) {
            [array addObject:polyline];
        }
    }
    [self.mapViewController updatePolylines:array];
}

- (void)handleAddPolyline:(NSDictionary *)dict {
    MapPolyline *polyline = [MapPolyline polylineFromDictionary:dict];
    if (polyline) {
        [self.mapViewController addPolyline:polyline];
    }
}

- (void)handleRemovePolyline:(NSDictionary *)dict {
    MapPolyline *polyline = [MapPolyline polylineFromDictionary:dict];
    if (polyline) {
        [self.mapViewController removePolyline:polyline];
    }
}
- (void)handleSetPolygons:(NSArray *)polygons {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *aDict in polygons) {
        MapPolygon *polygon=[MapPolygon polygonFromDictionary:aDict];
        if (polygon) {
            [array addObject:polygon];
        }
    }
    [self.mapViewController updatePolygons:array];
}

- (void)handleAddPolygon:(NSDictionary *)dict {
    MapPolygon *polygon = [MapPolygon polygonFromDictionary:dict];
    if (polygon) {
        [self.mapViewController addPolygon:polygon];
    }
}

- (void)handleRemovePolygon:(NSDictionary *)dict {
    MapPolygon *polygon = [MapPolygon polygonFromDictionary:dict];
    if (polygon) {
        [self.mapViewController removePolygon:polygon];
    }
}
- (void)handleZoomToAnnotations:(NSDictionary *)zoomToDict {
    NSArray *annotations = zoomToDict[@"annotations"];
    float padding = [zoomToDict[@"padding"] floatValue];
    [self.mapViewController zoomTo:annotations padding:padding];
}

- (void)handleToolbar:(UIBarButtonItem *)item {
    [self.channel invokeMethod:@"onToolbarAction" arguments:@(item.tag)];
}

- (void)handleSetCamera:(NSDictionary *)cameraUpdate {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([cameraUpdate[@"latitude"] doubleValue], [cameraUpdate[@"longitude"] doubleValue]);
    [self.mapViewController setCamera:coordinate zoom:[cameraUpdate[@"zoom"] floatValue] bearing:[cameraUpdate[@"bearing"] doubleValue] tilt:[cameraUpdate[@"tilt"] doubleValue]];
}

- (void)onMapReady {
    [self.channel invokeMethod:@"onMapReady" arguments:nil];
}

- (void)locationDidUpdate:(CLLocation *)location {
    NSInteger time = location.timestamp.timeIntervalSince1970;
    time *= 1000;
    [self.channel invokeMethod:@"locationUpdated" arguments:@{@"latitude": @(location.coordinate.latitude),
                                                              @"longitude": @(location.coordinate.longitude),
                                                              @"time":@(time),
                                                              @"altitude":@(location.altitude),
                                                              @"speed":@(location.speed),
                                                              @"bearing":@(location.course),
                                                              @"horizontalAccuracy":@(location.horizontalAccuracy),
                                                              @"verticalAccuracy":@(location.verticalAccuracy)
                                                              }];
}

- (void)annotationTapped:(NSString *)identifier{
    [self.channel invokeMethod:@"annotationTapped" arguments:identifier];
}
- (void)annotationDragStart:(NSString *)identifier position:(CLLocationCoordinate2D)position {
    [self.channel invokeMethod:@"annotationDragStart" arguments:@{@"id": identifier, @"latitude": @(position.latitude),@"longitude": @(position.longitude)}];
}
- (void)annotationDragEnd:(NSString *)identifier position:(CLLocationCoordinate2D)position {
    [self.channel invokeMethod:@"annotationDragEnd" arguments:@{@"id": identifier, @"latitude": @(position.latitude),@"longitude": @(position.longitude)}];
}
- (void)annotationDrag:(NSString *)identifier position:(CLLocationCoordinate2D)position{
    [self.channel invokeMethod:@"annotationDrag" arguments:@{@"id": identifier, @"latitude": @(position.latitude),@"longitude": @(position.longitude)}];
}
- (void)polylineTapped:(NSString *)identifier {
    [self.channel invokeMethod:@"polylineTapped" arguments:identifier];
}
- (void)polygonTapped:(NSString *)identifier {
    [self.channel invokeMethod:@"polygonTapped" arguments:identifier];
}
- (void)infoWindowTapped:(GMSMarker *)identifier {
    [self.channel invokeMethod:@"infoWindowTapped" arguments:identifier];
}

- (void)mapTapped:(CLLocationCoordinate2D)coordinate {
    [self.channel invokeMethod:@"mapTapped" arguments:@{@"latitude": @(coordinate.latitude), @"longitude": @(coordinate.longitude)}];
}

- (void)cameraPositionChanged:(GMSCameraPosition *)position {
    [self.channel invokeMethod:@"cameraPositionChanged" arguments:@{
            @"latitude": @(position.target.latitude),
            @"longitude": @(position.target.longitude),
            @"bearing": @(position.bearing),
            @"tilt": @(position.viewingAngle),
            @"zoom": @(position.zoom)
    }];
}

- (GMSCameraPosition *)cameraPositionFromDict:(NSDictionary *)dict {
    double latitude = [dict[@"latitude"] doubleValue];
    double longitude = [dict[@"longitude"] doubleValue];
    float zoom = [dict[@"zoom"] floatValue];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(latitude, longitude) zoom:zoom];
    return camera;
}

- (int)getMapViewType:(NSString *)mapViewTypeName {
    int mapType = kGMSTypeNormal;
    if ([@"none" isEqualToString:mapViewTypeName]) {
        mapType = kGMSTypeNone;
    }
    else if ([@"satellite" isEqualToString:mapViewTypeName]) {
        mapType = kGMSTypeSatellite;
    }
    else if ([@"terrain" isEqualToString:mapViewTypeName]) {
        mapType = kGMSTypeTerrain;
    }
    else if ([@"hybrid" isEqualToString:mapViewTypeName]) {
        mapType = kGMSTypeHybrid;
    }
    else if ([@"none" isEqualToString:mapViewTypeName]) {
        mapType = kGMSTypeNone;
    }
    return mapType;
}

-(NSString *) getAssetPath:(NSString *)iconPath{
    NSString* key = [self.registrar lookupKeyForAsset:iconPath];
    NSString* path= [[NSBundle mainBundle] pathForResource:key ofType:nil];
    return path;
}

@end
