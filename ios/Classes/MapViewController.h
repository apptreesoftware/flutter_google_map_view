//
//  MapViewController.h
//  map_view
//
//  Created by Matthew Smith on 10/30/17.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps/GMSMapView.h>

@class MapViewPlugin;
@class MapAnnotation;
@class MapPolyline;
@class MapPolygon;

@interface MapViewController : UIViewController <GMSMapViewDelegate>

- (id)initWithPlugin:(MapViewPlugin *)plugin
     navigationItems:(NSArray *)items
      cameraPosition:(GMSCameraPosition *)cameraPosition;

- (void)shutdown;
- (void)setCamera:(CLLocationCoordinate2D)location zoom:(float)zoom bearing:(CLLocationDirection)bearing tilt:(double)tilt;

- (void)updateAnnotations:(NSArray *)annotations;
- (void)clearAnnotations;
- (void)addAnnotation:(MapAnnotation *)annotation;
- (void)removeAnnotation:(MapAnnotation *)annotation;

- (void)updatePolylines:(NSArray *)polylines;
- (void)clearPolylines;
- (void)addPolyline:(MapPolyline *)polyline;
- (void)removePolyline:(MapPolyline *)polyline;

- (void)updatePolygons:(NSArray *)polylines;
- (void)clearPolygons;
- (void)addPolygon:(MapPolygon *)polyline;
- (void)removePolygon:(MapPolygon *)polyline;

- (void)zoomTo:(NSArray *)annotations padding:(float)padding;
- (void)zoomToAnnotations:(int)padding;

- (NSArray *)visibleMarkers;
- (NSArray *)visiblePolylines;
- (NSArray *)visiblePolygons;

- (void)setMapOptions:(BOOL)myLocationEnabled
       locationButton:(BOOL)myLocationButton
        compassButton:(BOOL)compassButton;

@property (readonly) float zoomLevel;
@property (readonly) CLLocationCoordinate2D centerLocation;

@end
