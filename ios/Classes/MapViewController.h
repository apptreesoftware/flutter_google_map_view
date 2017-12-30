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

@interface MapViewController : UIViewController <GMSMapViewDelegate>

- (id)initWithPlugin:(MapViewPlugin *)plugin
     navigationItems:(NSArray *)items
      cameraPosition:(GMSCameraPosition *)cameraPosition;

- (void)shutdown;

- (void)setCamera:(CLLocationCoordinate2D)location zoom:(float)zoom;
- (void)updateAnnotations:(NSArray *)annotations;

- (void)addAnnotation:(MapAnnotation *)annotation;
- (void)removeAnnotation:(MapAnnotation *)annotation;

- (void)zoomTo:(NSArray *)annotations padding:(float)padding;
- (void)zoomToAnnotations:(int)padding;

- (NSArray *)visibleMarkers;

- (void)setLocationEnabled:(BOOL) enabled;

@property (readonly) float zoomLevel;
@property (readonly) CLLocationCoordinate2D centerLocation;

@end
