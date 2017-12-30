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
@property (nonatomic, retain) NSMutableDictionary *markerIDLookup;
@property (nonatomic, assign) int mapViewType;
@end

@implementation MapViewController

- (id)initWithPlugin:(MapViewPlugin *)plugin
     navigationItems:(NSArray *)items cameraPosition:(GMSCameraPosition *)cameraPosition {
    self = [super init];
    if (self) {
        self.plugin = plugin;
        self.navigationItems = items;
        self.initialCameraPosition = cameraPosition;
        self.markerIDLookup = [NSMutableDictionary dictionary];
        self.title = plugin.mapTitle;
        self.mapViewType = plugin.mapViewType;
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
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:self.initialCameraPosition];
    self.view = self.mapView;

    // Creates a marker in the center of the map.
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = self._locationEnabled;
    if (self._locationEnabled) {
        [self monitorLocationChanges];
    }

    self.mapView.mapType = self.mapViewType;
    [self.plugin onMapReady];
}

- (void)setCamera:(CLLocationCoordinate2D)location zoom:(float)zoom {
    [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:location zoom:zoom]];
}

- (void)updateAnnotations:(NSArray *)annotations {
    [self.mapView clear];
    [self.markerIDLookup removeAllObjects];
    for (MapAnnotation *annotation in annotations) {
        GMSMarker *marker = [self createMarkerForAnnotation:annotation];
        marker.map = self.mapView;
        [self.markers addObject:marker];
        self.markerIDLookup[marker.userData] = marker;
    }
}

- (void)addAnnotation:(MapAnnotation *)annotation {
    GMSMarker *marker = [self createMarkerForAnnotation:annotation];
    marker.map = self.mapView;
    self.markerIDLookup[marker.userData] = marker;
}

- (void)removeAnnotation:(MapAnnotation *)annotation {
    GMSMarker *marker = self.markerIDLookup[annotation.identifier];
    if (marker) {
        marker.map = nil;
        self.markerIDLookup[annotation.identifier] = nil;
    }
}

- (GMSMarker *)createMarkerForAnnotation:(MapAnnotation *)annotation {
    GMSMarker *marker = [GMSMarker new];
    if ([annotation isKindOfClass:[ClusterAnnotation class]]) {
        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation *)annotation;
        marker.position = annotation.coordinate;
        marker.title = annotation.title;
        marker.snippet = [NSString stringWithFormat:@"%i", clusterAnnotation.clusterCount];
        marker.icon = [GMSMarker markerImageWithColor:annotation.color];
        marker.userData = annotation.identifier;
    } else {
        marker.position = annotation.coordinate;
        marker.title = annotation.title;
        marker.icon = [GMSMarker markerImageWithColor:annotation.color];
        marker.userData = annotation.identifier;
    }
    return marker;
}

- (void)zoomTo:(NSArray *)annotations padding:(float)padding {
    GMSCoordinateBounds *coordinateBounds;

    if (annotations.count == 1) {
        GMSMarker *marker = self.markerIDLookup[annotations[0]];
        if (!marker) {
            return;
        }
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:marker.position zoom: 18]];
        return;
    }
    for (NSString *annotation in annotations) {
        GMSMarker *marker = self.markerIDLookup[annotation];
        if (!marker) {
            continue;
        }
        if (!coordinateBounds) {
            coordinateBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:marker.position coordinate:marker.position];
            continue;
        }
        coordinateBounds = [coordinateBounds includingCoordinate:marker.position];
    }
    if (coordinateBounds && coordinateBounds.isValid) {
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:coordinateBounds withPadding:padding];
        [self.mapView animateWithCameraUpdate:cameraUpdate];
    }
}

- (void)zoomToAnnotations:(int)padding {
    GMSCoordinateBounds *coordinateBounds;
    for (GMSMarker *marker in self.markerIDLookup.allValues) {
        if (!coordinateBounds) {
            coordinateBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:marker.position coordinate:marker.position];
            continue;
        }
        coordinateBounds = [coordinateBounds includingCoordinate:marker.position];
    }
    if (self.mapView.myLocation) {
        if (coordinateBounds == nil) {
            GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setTarget:self.mapView.myLocation.coordinate
                                                                  zoom: 12];
            [self.mapView animateWithCameraUpdate:cameraUpdate];
            return;
        }
        coordinateBounds = [coordinateBounds includingCoordinate:self.mapView.myLocation.coordinate];
    }
    if (coordinateBounds && coordinateBounds.isValid) {
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:coordinateBounds
                                                    withPadding:padding];
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
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self.plugin infoWindowTapped:marker.userData];
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
    for (GMSMarker *marker in self.markerIDLookup.allValues) {
        if ([bounds containsCoordinate:marker.position]) {
            [visibleMarkers addObject:marker.userData];
        }
    }
    return visibleMarkers;
}

@end
