//
//  NIMTweet.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMTweet.h"
#import "NIMUser.h"

#warning отделить парсинг в отдельную категорию

@implementation NIMTweet

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
#warning валидация
        _idStr = [dictionary[@"id_str"] copy];
        _createdAt = [[[self class] JSONDateFormatter] dateFromString:dictionary[@"created_at"]];
        _text = [dictionary[@"text"] copy];
        _user = [[NIMUser alloc] initWithJSONDictionary:dictionary[@"user"]];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NIMTweet *copy = [[[self class] allocWithZone:zone] init];
    copy.idStr = self.idStr;
    copy.createdAt = self.createdAt;
    copy.text = self.text;
    copy.user = self.user;

    return copy;
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"NIMTweet %@ @%@ %@", self.idStr, self.user.screenName, self.text];
}

@end
