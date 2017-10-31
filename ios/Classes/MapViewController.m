//
//  MapViewController.m
//  map_view
//
//  Created by Matthew Smith on 10/30/17.
//

#import "MapViewController.h"
#import "MapAnnotation.h"
#import "MapViewPlugin.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController ()

@property (nonatomic, retain) GMSMapView *mapView;
@property (nonatomic, retain) NSMutableArray *markers;
@property (nonatomic) BOOL _locationEnabled;
@property (nonatomic) BOOL observingLocation;
@property (nonatomic, assign) MapViewPlugin *plugin;
@property (nonatomic, retain) NSArray *navigationItems;
@property (nonatomic, retain) GMSCameraPosition *initialCameraPosition;
@end

@implementation MapViewController

- (id)initWithPlugin:(MapViewPlugin *)plugin
     navigationItems:(NSArray *)items cameraPosition:(GMSCameraPosition *)cameraPosition {
    self = [super init];
    if (self) {
        self.plugin = plugin;
        self.navigationItems = items;
        self.initialCameraPosition = cameraPosition;
    }
    return self;
}

- (void)shutdown {
    [self stopMonitoringLocationChanges];
}

- (void)dealloc {
    [self stopMonitoringLocationChanges];
}

- (void)viewDidLoad {
    self.navigationItem.rightBarButtonItems = self.navigationItems;
}

- (void)setLocationEnabled:(BOOL)enabled {
    self._locationEnabled = enabled;
    if (self.mapView) {
        self.mapView.myLocationEnabled = enabled;
        if (enabled) {
            [self monitorLocationChanges];
        } else {
            [self stopMonitoringLocationChanges];
        }
    }
}

- (void)loadView {
    self.markers = [NSMutableArray array];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:self.initialCameraPosition];
    self.view = self.mapView;

    // Creates a marker in the center of the map.
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = self._locationEnabled;
    if (self._locationEnabled) {
        [self monitorLocationChanges];
    }
}

- (void)setCamera:(CLLocationCoordinate2D)location zoom:(float)zoom {
    [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:location zoom:zoom]];
}

- (void)updateAnnotations:(NSArray *)annotations {
    [self.mapView clear];
    [self.markers removeAllObjects];
    self.markers = [NSMutableArray array];
    for (MapAnnotation *annotation in annotations) {
        GMSMarker *marker = [self createMarkerForAnnotation:annotation];
        marker.map = self.mapView;
        [self.markers addObject:marker];
    }
}

- (GMSMarker *)createMarkerForAnnotation:(MapAnnotation *)annotation {
    GMSMarker *marker = [GMSMarker new];
    if ([annotation isKindOfClass:[ClusterAnnotation class]]) {
        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation *)annotation;
        marker.position = annotation.coordinate;
        marker.title = annotation.title;
        marker.snippet = [NSString stringWithFormat:@"%i", clusterAnnotation.clusterCount];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.userData = annotation.identifier;
    } else {
        marker.position = annotation.coordinate;
        marker.title = annotation.title;
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.userData = annotation.identifier;
    }
    return marker;
}

- (void)zoomToAnnotations {
    GMSCoordinateBounds *coordinateBounds;
    for (GMSMarker *marker in self.markers) {
        if (!coordinateBounds) {
            coordinateBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:marker.position coordinate:marker.position];
            continue;
        }
        coordinateBounds = [coordinateBounds includingCoordinate:marker.position];
    }
    if (self.mapView.myLocation) {
        if (coordinateBounds == nil) {
            GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setTarget:self.mapView.myLocation.coordinate zoom: 12];
            [self.mapView animateWithCameraUpdate:cameraUpdate];
            return;
        }
        coordinateBounds = [coordinateBounds includingCoordinate:self.mapView.myLocation.coordinate];
    }
    if (coordinateBounds && coordinateBounds.isValid) {
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:coordinateBounds withEdgeInsets:UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0)];
        [self.mapView animateWithCameraUpdate:cameraUpdate];
    }
}

- (void)monitorLocationChanges {
    if (self.observingLocation) return;
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    self.observingLocation = YES;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"myLocation"]) {
        [self.plugin locationDidUpdate:self.mapView.myLocation];
    }
}


- (void)stopMonitoringLocationChanges {
    if (!self.observingLocation) return;
    [self.mapView removeObserver:self forKeyPath:@"myLocation"];
    self.observingLocation = NO;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self.plugin annotationTapped:marker.userData];
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.plugin mapTapped:coordinate];
}


- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    [self.plugin cameraPositionChanged:position];
}

- (CLLocationCoordinate2D) centerLocation {
    return self.mapView.camera.target;
}

- (float)zoomLevel {
    return self.mapView.camera.zoom;
}

- (NSArray *)visibleMarkers {
    GMSVisibleRegion region = self.mapView.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithRegion:region];
    NSMutableArray *visibleMarkers = [NSMutableArray array];
    for (GMSMarker *marker in self.markers) {
        if ([bounds containsCoordinate:marker.position]) {
            [visibleMarkers addObject:marker.userData];
        }
    }
    return visibleMarkers;
}

@end
