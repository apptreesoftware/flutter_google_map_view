//
// Created by Luis Jara on 06/09/18.
//

#import "Hole.h"
#import "UIColor+Extensions.h"


@implementation Hole {

}
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSMutableArray *pointList=[NSMutableArray new];
        NSArray *pointsMapList = dictionary[@"points"];
        for(NSDictionary *pointDic in pointsMapList){
            double latitude=[pointDic[@"latitude"] doubleValue];
            double longitude=[pointDic[@"longitude"] doubleValue];
            CLLocation *location= [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [pointList addObject:location];
        }
        self.points = pointList;
    }
    return self;
}

+ (instancetype)holeFromDictionary:(NSDictionary *)dictionary {
    return [[Hole alloc] initWithDictionary:dictionary];
}
@end
