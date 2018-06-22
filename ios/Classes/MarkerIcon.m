//
// Created by Luis Jara on 06/22/18.
//

#import "MarkerIcon.h"

@implementation MarkerIcon {
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.asset = dictionary[@"asset"];
        self.width = [dictionary[@"width"] doubleValue];
        self.height = [dictionary[@"height"] doubleValue];
    }
    return self;
}

+ (instancetype)markerIconFromDictionary:(NSDictionary *)dictionary {
    return [[MarkerIcon alloc] initWithDictionary:dictionary];
}

@end
