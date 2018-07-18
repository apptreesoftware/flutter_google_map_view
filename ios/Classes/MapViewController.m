//
//  MapViewController.m
//  map_view
//
//  Created by Matthew Smith on 10/30/17.
//

#import "MapViewController.h"
#import "MapAnnotation.h"
#import "MapPolyline.h"
#import "MapPolygon.h"
#import "Hole.h"
#import "MapViewPlugin.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController ()

@property (nonatomic, retain) GMSMapView *mapView;
@property (nonatomic, retain) NSMutableArray *markers;
@property (nonatomic, retain) NSMutableArray *polylines;
@property (nonatomic, retain) NSMutableArray *polygons;
@property (nonatomic) BOOL _locationEnabled;
@property (nonatomic) BOOL _locationButton;
@property (nonatomic) BOOL _compassButton;
@property (nonatomic) BOOL observingLocation;
@property (nonatomic, assign) MapViewPlugin *plugin;
@property (nonatomic, retain) NSArray *navigationItems;
@property (nonatomic, retain) GMSCameraPosition *initialCameraPosition;
@property (nonatomic, retain) NSMutableDictionary *markerIDLookup;
@property (nonatomic, retain) NSMutableDictionary *polylineIDLookup;
@property (nonatomic, retain) NSMutableDictionary *polygonIDLookup;
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
        self.polylineIDLookup = [NSMutableDictionary dictionary];
        self.polygonIDLookup = [NSMutableDictionary dictionary];
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

- (void)setMapOptions:(BOOL)myLocationEnabled
       locationButton:(BOOL)myLocationButton
        compassButton:(BOOL)compassButton{
    self._locationEnabled = myLocationEnabled;
    self._locationButton = myLocationButton;
    self._compassButton = compassButton;
}

- (void) loadMapOptions{
    if (self.mapView) {
        self.mapView.settings.compassButton = self._compassButton;
        if (self._locationEnabled) {
            self.mapView.myLocationEnabled = YES;
            self.mapView.settings.myLocationButton = self._locationButton;
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
    [self loadMapOptions];

    self.mapView.mapType = self.mapViewType;
    [self.plugin onMapReady];
}

- (void)setCamera:(CLLocationCoordinate2D)location zoom:(float)zoom bearing:(CLLocationDirection)bearing tilt:(double)tilt {
    [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:location zoom:zoom bearing:bearing viewingAngle:tilt]];
}

- (void)updateAnnotations:(NSArray *)annotations {
    [self clearAnnotations];
    for (MapAnnotation *annotation in annotations) {
        GMSMarker *marker = [self createMarkerForAnnotation:annotation];
        marker.map = self.mapView;
        [self.markers addObject:marker];
        self.markerIDLookup[marker.userData] = marker;
    }
}
- (void)clearAnnotations {
    for(GMSMarker *marker in self.markerIDLookup.allValues){
        marker.map=nil;
    }
    [self.markerIDLookup removeAllObjects];
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

- (void)updatePolylines:(NSArray *)polylines {
    [self clearPolylines];
    for (MapPolyline *mapPolyline in polylines) {
        GMSPolyline *polyline = [self createPolyline:mapPolyline];
        polyline.map = self.mapView;
        [self.polylines addObject:polyline];
        self.polylineIDLookup[polyline.userData] = polyline;
    }
}

- (void)clearPolylines{
    for(GMSPolyline *polyline in self.polylineIDLookup.allValues){
        polyline.map=nil;
    }
    [self.polylineIDLookup removeAllObjects];
}

- (void)addPolyline:(MapPolyline *)mapPolyline {
    GMSPolyline *polyline = [self createPolyline:mapPolyline];
    polyline.map = self.mapView;
    self.polylineIDLookup[polyline.userData] = polyline;
}

- (void)removePolyline:(MapPolyline *)mapPolyline {
    GMSPolyline *polyline = self.polylineIDLookup[mapPolyline.identifier];
    if (polyline) {
        polyline.map = nil;
        self.polylineIDLookup[mapPolyline.identifier] = nil;
    }
}
- (void)updatePolygons:(NSArray *)polygons {
    [self clearPolygons];
    for (MapPolygon *mapPolygon in polygons) {
        GMSPolygon *polygon = [self createPolygon:mapPolygon];
        polygon.map = self.mapView;
        [self.polygons addObject:polygon];
        self.polygonIDLookup[polygon.userData] = polygon;
    }
}

- (void)clearPolygons{
    for(GMSPolygon *polygon in self.polygonIDLookup.allValues){
        polygon.map=nil;
    }
    [self.polygonIDLookup removeAllObjects];
}

- (void)addPolygon:(MapPolygon *)mapPolygon {
    GMSPolygon *polygon = [self createPolygon:mapPolygon];
    polygon.map = self.mapView;
    self.polygonIDLookup[polygon.userData] = polygon;
}

- (void)removePolygon:(MapPolygon *)mapPolygon {
    GMSPolygon *polygon = self.polylineIDLookup[mapPolygon.identifier];
    if (polygon) {
        polygon.map = nil;
        self.polylineIDLookup[mapPolygon.identifier] = nil;
    }
}

- (GMSMarker *)createMarkerForAnnotation:(MapAnnotation *)annotation {
    GMSMarker *marker = [GMSMarker new];
    if ([annotation isKindOfClass:[ClusterAnnotation class]]) {
        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation *)annotation;
        marker.snippet = [NSString stringWithFormat:@"%i", clusterAnnotation.clusterCount];
    }
    UIImage* image;
    if(annotation.icon!=nil){
        @try {
            NSString* path=[self.plugin getAssetPath:annotation.icon.asset];
            NSData* imagedata=[NSData dataWithContentsOfFile:path];
            image = [UIImage imageWithData:imagedata scale:3.0f];
            double width=annotation.icon.width;
            double height=annotation.icon.height;
            if(width==0)
                width = image.size.width;
            if(height==0)
                height=image.size.height;
            image = [self resizeImage:image scaledToSize:CGSizeMake(width, height)];
        }@catch(NSException* e){
            NSLog(@"Exception: %@",e);
        }
    }
    if(image!=nil){
        marker.icon = image;
    }else{
        marker.icon = [GMSMarker markerImageWithColor:annotation.color];
    }
    marker.position = annotation.coordinate;
    marker.title = annotation.title;
    marker.rotation = annotation.rotation;
    marker.userData = annotation.identifier;
    marker.draggable = annotation.draggable;
    return marker;
}

- (GMSPolyline *)createPolyline:(MapPolyline *)mapPolyline {
    GMSPolyline *polyline = [GMSPolyline new];
    GMSMutablePath *gmsMutablePath=[GMSMutablePath path];
    for(CLLocation *point in mapPolyline.points){
        [gmsMutablePath addCoordinate:point.coordinate];
    }
    polyline.tappable = YES;
    polyline.path = gmsMutablePath;
    polyline.strokeWidth = mapPolyline.width;
    polyline.strokeColor = mapPolyline.color;
    polyline.userData = mapPolyline.identifier;
    return polyline;
}

- (GMSPolygon *)createPolygon:(MapPolygon *)mapPolygon {
    GMSPolygon *polygon = [GMSPolygon new];
    GMSMutablePath *gmsMutablePath=[GMSMutablePath path];
    NSMutableArray *holesList = [NSMutableArray new];
    for(CLLocation *point in mapPolygon.points){
        [gmsMutablePath addCoordinate:point.coordinate];
    }
    for(Hole *hole in mapPolygon.holes){
        GMSMutablePath *holePath=[GMSMutablePath path];
        for(CLLocation *point in hole.points){
            [holePath addCoordinate:point.coordinate];
        }
        [holesList addObject:holePath];
    }
    polygon.tappable = YES;
    polygon.path = gmsMutablePath;
    polygon.holes = holesList;
    polygon.strokeWidth = mapPolygon.strokeWidth;
    polygon.strokeColor = mapPolygon.strokeColor;
    polygon.fillColor = mapPolygon.fillColor;
    polygon.userData = mapPolygon.identifier;
    return polygon;
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
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(nonnull GMSOverlay *)overlay {
    if ([overlay class] == [GMSPolyline class]){
        [self.plugin polylineTapped:overlay.userData];
    }else if ([overlay class] == [GMSPolygon class]){
        [self.plugin polygonTapped:overlay.userData];
    }
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

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(nonnull GMSMarker *)marker{
    [self.plugin annotationDragStart:marker.userData position:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(nonnull GMSMarker *)marker{
    [self.plugin annotationDragEnd:marker.userData position:marker.position];
}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(nonnull GMSMarker *)marker{
    [self.plugin annotationDrag:marker.userData position:marker.position];
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
- (NSArray *)visiblePolylines {
    GMSVisibleRegion region = self.mapView.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithRegion:region];
    NSMutableArray *visiblePolylines = [NSMutableArray array];
    for (GMSPolyline *polyline in self.polylineIDLookup.allValues) {
        GMSPath *path= polyline.path;
        for (int i=0; i<path.count; i++) {
            CLLocationCoordinate2D coordinate= [path coordinateAtIndex:i];
            if ([bounds containsCoordinate:coordinate]) {
                [visiblePolylines addObject:polyline.userData];
                break;
            }
        }
    }
    return visiblePolylines;
}
- (NSArray *)visiblePolygons {
    GMSVisibleRegion region = self.mapView.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithRegion:region];
    NSMutableArray *visiblePolygons = [NSMutableArray array];
    for (GMSPolygon *polygon in self.polygonIDLookup.allValues) {
        GMSPath *path= polygon.path;
        for (int i=0; i<path.count; i++) {
            CLLocationCoordinate2D coordinate= [path coordinateAtIndex:i];
            if ([bounds containsCoordinate:coordinate]) {
                [visiblePolygons addObject:polygon.userData];
                break;
            }
        }
    }
    return visiblePolygons;
}

- (UIImage *)resizeImage:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    if (CGSizeEqualToSize(originalImage.size, size)){
        return originalImage;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
