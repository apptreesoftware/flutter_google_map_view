//
// Created by Matthew Smith on 11/7/17.
//

#import "UIColor+Extensions.h"


@implementation UIColor (Extensions)
+ (UIColor *)colorFromDictionary:(NSDictionary *)dictionary {
    CGFloat r = [dictionary[@"r"] intValue]/255.0;
    CGFloat g = [dictionary[@"g"] intValue]/255.0;
    CGFloat b = [dictionary[@"b"] intValue]/255.0;
    CGFloat a = [dictionary[@"a"] intValue]/255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
@end