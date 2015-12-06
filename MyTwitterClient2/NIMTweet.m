//
//  NIMTweet.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMTweet.h"
#import "NIMUser.h"

@implementation NIMTweet

- (id)copyWithZone:(NSZone *)zone
{
    NIMTweet *copy = [[[self class] allocWithZone:zone] init];
    copy.idStr = self.idStr;
    copy.createdAt = self.createdAt;
    copy.text = self.text;
    copy.user = self.user;

    return copy;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (![object isKindOfClass:[NIMTweet class]]) return NO;
    return [self.idStr isEqualToString:[object idStr]];
}

- (NSUInteger)hash
{
    return [self.idStr hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"NIMTweet %@ @%@ %@", self.idStr, self.user.screenName, self.text];
}

@end

@implementation NIMTweet (Parsing)

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _idStr = [dictionary[@"id_str"] copy];

        NSString *createdAt = dictionary[@"created_at"];
        if (createdAt) {
            _createdAt = [[[self class] JSONDateFormatter] dateFromString:createdAt];
        }
        
        _text = [dictionary[@"text"] copy];
        _user = [[NIMUser alloc] initWithJSONDictionary:dictionary[@"user"]];
    }
    return self;
}

+ (NSDateFormatter *)JSONDateFormatter
{
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    });

    return _dateFormatter;
}

@end
