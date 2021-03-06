//
//  NIMUser.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import Foundation;

@interface NIMUser : NSObject <NSCopying>

@property (nonatomic, copy) NSString *idStr;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *profileImageURL;
@property (nonatomic, copy) NSString *screenName;

@end

@interface NIMUser (Parsing)

/**
 Валидация входных данных не производится, предполагаем, что они всегда
 корректные
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end