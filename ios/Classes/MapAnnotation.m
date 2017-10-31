//
// Created by Matthew Smith on 10/30/17.
//

#import "MapAnnotation.h"


@implementation MapAnnotation {

}
- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.title = dictionary[@"title"];
        self.coordinate = CLLocationCoordinate2DMake([dictionary[@"latitude"] intValue], [dictionary[@"longitude"] intValue]);
    }
    return self;
}

+ (instancetype)annotationFromDictionary:(NSDictionary *)dictionary {
    NSString *type = dictionary[@"type"];
    if (!type) {
        return nil;
    }
    if ([type isEqualToString:@"cluster"]) {
        return [[ClusterAnnotation alloc] initWithDictionary:dictionary];
    } else if ([type isEqualToString:@"pin"]) {
        return [[MapAnnotation alloc] initWithDictionary:dictionary];
    }
    return nil;
}

@end

@implementation ClusterAnnotation {
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.clusterCount = [dictionary[@"clusterCount"] intValue];
    }
    return self;
}


@end