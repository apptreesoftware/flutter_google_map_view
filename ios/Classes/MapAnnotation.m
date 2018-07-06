//
// Created by Matthew Smith on 10/30/17.
//

#import "MapAnnotation.h"
#import "UIColor+Extensions.h"
#import "MarkerIcon.h"

@implementation MapAnnotation {

}
- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.identifier = dictionary[@"id"];
        self.title = dictionary[@"title"];
        self.draggable= [dictionary[@"draggable"] boolValue];
        self.rotation= [dictionary[@"rotation"] doubleValue];
        if([dictionary objectForKey:@"markerIcon"]!=nil){
            self.icon = [MarkerIcon markerIconFromDictionary:dictionary[@"markerIcon"]];
        }
        self.coordinate = CLLocationCoordinate2DMake([dictionary[@"latitude"] doubleValue], [dictionary[@"longitude"] doubleValue]);
        self.color = [UIColor colorFromDictionary:dictionary[@"color"]];
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
