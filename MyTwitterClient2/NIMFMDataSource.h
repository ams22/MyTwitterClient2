//
//  NIMFMDataSource.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 07.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import Foundation;

typedef void (^NIMFMDataSourceTweetsResultsBlock)(NSArray *tweets, NSError *error);
typedef void (^NIMFMDataSourceUpdateCompletionBlock)(BOOL success, NSError *error);

@interface NIMFMDataSource : NSObject

- (instancetype)initWithDatabasePath:(NSString *)path;

//! Singleton с дефолтным путем к базе данные в директории Library/Caches
+ (instancetype)defaultDataSource;

/**
 @param resultsBlock tweets - массив NIMTweet-ов или nil, если произошла ошибка error
 */
- (void)fetchCachedTweets:(NIMFMDataSourceTweetsResultsBlock)resultsBlock;

/**
 @param tweets массив NIMTweet-ов
 */
- (void)storeCachedTweets:(NSArray *)tweets
          completionBlock:(NIMFMDataSourceUpdateCompletionBlock)completionBlock;

@end
