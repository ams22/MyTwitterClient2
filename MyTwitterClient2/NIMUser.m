//
//  NIMUser.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMUser.h"

@implementation NIMUser

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
#warning валидация
        _idStr = [dictionary[@"id_str"] copy];
        _name = [dictionary[@"name"] copy];
        _profileImageURL = [NSURL URLWithString:dictionary[@"profile_image_url"]];
        _screenName = [dictionary[@"screen_name"] copy];
    }
    return self;
}

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

@end
