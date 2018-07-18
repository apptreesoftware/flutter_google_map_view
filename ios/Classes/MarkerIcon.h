//
// Created by Luis Jara on 06/09/18.
//

#import <Foundation/Foundation.h>

@interface MarkerIcon : NSObject
@property (nonatomic, retain)NSString* asset;
@property (nonatomic)double width;
@property (nonatomic)double height;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (instancetype)markerIconFromDictionary:(NSDictionary *)dictionary;

@end
