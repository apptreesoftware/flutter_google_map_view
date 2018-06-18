//
// Created by Luis Jara on 06/09/18.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MapPolygon : NSObject
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic, retain) NSMutableArray *holes;
@property (nonatomic) double strokeWidth;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, retain) UIColor *strokeColor;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (instancetype)polygonFromDictionary:(NSDictionary *)dictionary;
@end
