//
// Created by Luis Jara on 06/09/18.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Hole : NSObject
@property (nonatomic, retain) NSMutableArray *points;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (instancetype)holeFromDictionary:(NSDictionary *)dictionary;
@end
