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

@interface MapViewController : UIViewController <GMSMapViewDelegate>

- (id)initWithPlugin:(MapViewPlugin *)plugin;

- (void)shutdown;

- (void)setCamera:(CLLocationCoordinate2D)location zoom:(float)zoom;
- (void)updateAnnotations:(NSArray *)annotations;
- (void)zoomToAnnotations;
- (void)setLocationEnabled:(BOOL) enabled;

@property (readonly) float zoomLevel;
@property (readonly) CLLocationCoordinate2D centerLocation;

@end
