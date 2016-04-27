//
//  NIMUser.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMUser.h"

@implementation NIMUser

- (id)copyWithZone:(NSZone *)zone
{
    NIMUser *copy = [[[self class] allocWithZone:zone] init];
    copy.idStr = self.idStr;
    copy.name = self.name;
    copy.profileImageURL = self.profileImageURL;
    copy.screenName = self.screenName;

    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (![object isKindOfClass:[NIMUser class]]) return NO;
    return [self.idStr isEqualToString:[object idStr]];
}

- (NSUInteger)hash
{
    return [self.idStr hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"NIMTweet %@ %@", self.idStr, self.screenName];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _idStr = [aDecoder decodeObjectForKey:@"idStr"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _profileImageURL = [aDecoder decodeObjectForKey:@"profileImageURL"];
        _screenName = [aDecoder decodeObjectForKey:@"screenName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idStr forKey:@"idStr"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.profileImageURL forKey:@"profileImageURL"];
    [aCoder encodeObject:self.screenName forKey:@"screenName"];
}

@end

@implementation NIMUser (Parsing)

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _idStr = [dictionary[@"id_str"] copy];
        _name = [dictionary[@"name"] copy];
        NSString *profileImageURLString = dictionary[@"profile_image_url"];
        // Берем большой вариант аватарки, чтобы красиво смотрелось на ретине
        profileImageURLString = [profileImageURLString stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
        _profileImageURL = [NSURL URLWithString:profileImageURLString];
        _screenName = [dictionary[@"screen_name"] copy];
    }
    return self;
}

@end