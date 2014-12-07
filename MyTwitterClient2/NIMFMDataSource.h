//
//  NIMFMDataSource.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 07.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import Foundation;

@interface NIMFMDataSource : NSObject

- (instancetype)initWithDatabasePath:(NSString *)path;

+ (instancetype)defaultDataSource;

- (void)fetchCachedTweets:(void (^)(NSArray *tweets, NSError *error))resultsBlock;

- (void)storeCachedTweets:(NSArray *)tweets
          completionBlock:(void (^)(BOOL success, NSError *error))completionBlock;

@end
