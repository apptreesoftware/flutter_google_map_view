//
// Created by Matthew Smith on 10/30/17.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface MapAnnotation : NSObject
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) UIColor *color;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (instancetype)annotationFromDictionary:(NSDictionary *)dictionary;

@end

@interface ClusterAnnotation : MapAnnotation
@property (nonatomic, assign) int clusterCount;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end