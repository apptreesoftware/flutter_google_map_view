//
// Created by Luis Jara on 06/09/18.
//

#import "MapPolyline.h"
#import "UIColor+Extensions.h"


@implementation MapPolyline {

}
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSMutableArray *pointList=[NSMutableArray new];
        self.identifier = dictionary[@"id"];
        NSArray *pointsMapList = dictionary[@"points"];
        for(NSDictionary *pointDic in pointsMapList){
            double latitude=[pointDic[@"latitude"] doubleValue];
            double longitude=[pointDic[@"longitude"] doubleValue];
            CLLocation *location= [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [pointList addObject:location];
        }
        self.points = pointList;
        self.width = [dictionary[@"width"] doubleValue];
        self.color = [UIColor colorFromDictionary:dictionary[@"color"]];
    }
    return self;
}

+ (instancetype)polylineFromDictionary:(NSDictionary *)dictionary {
    return [[MapPolyline alloc] initWithDictionary:dictionary];
}
@end
