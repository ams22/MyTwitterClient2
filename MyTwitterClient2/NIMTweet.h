//
//  NIMTweet.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import Foundation;

@class NIMUser;

@interface NIMTweet : NSObject <NSCopying>

@property (nonatomic, copy) NSString *idStr;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NIMUser *user;

@end

@interface NIMTweet (Parsing)

/**
 Валидация входных данных не производится, предполагаем, что они всегда
 корректные
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
