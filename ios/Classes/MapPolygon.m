//
// Created by Luis Jara on 06/09/18.
//

#import "MapPolygon.h"
#import "Hole.h"
#import "UIColor+Extensions.h"


@implementation MapPolygon {

}
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSArray *pointsMapList = dictionary[@"points"];
        NSMutableArray *pointsList=[NSMutableArray new];
        for(NSDictionary *pointDic in pointsMapList){
            double latitude=[pointDic[@"latitude"] doubleValue];
            double longitude=[pointDic[@"longitude"] doubleValue];
            CLLocation *location= [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [pointsList addObject:location];
        }
        NSArray *holesMapList = dictionary[@"holes"];
        NSMutableArray *holesList=[NSMutableArray new];
        for(NSDictionary *holeDic in holesMapList){
            [holesList addObject:[Hole holeFromDictionary:holeDic]];
        }
        self.points = pointsList;
        self.holes = holesList;
        self.identifier = dictionary[@"id"];
        self.strokeWidth = [dictionary[@"strokeWidth"] doubleValue];
        self.fillColor = [UIColor colorFromDictionary:dictionary[@"fillColor"]];
        self.strokeColor = [UIColor colorFromDictionary:dictionary[@"strokeColor"]];
    }
    return self;
}

+ (instancetype)polygonFromDictionary:(NSDictionary *)dictionary {
    return [[MapPolygon alloc] initWithDictionary:dictionary];
}
@end
