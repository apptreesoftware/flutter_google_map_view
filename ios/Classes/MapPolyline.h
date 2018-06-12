//
// Created by Luis Jara on 06/09/18.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MapPolyline : NSObject
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic) double width;
@property (nonatomic, retain) UIColor *color;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (instancetype)polylineFromDictionary:(NSDictionary *)dictionary;
@end
