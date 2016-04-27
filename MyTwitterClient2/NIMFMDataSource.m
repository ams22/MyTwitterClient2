//
//  NIMFMDataSource.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 07.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMFMDataSource.h"
#import "NIMTweet.h"
#import "NIMUser.h"

@interface NIMFMDataSource ()

@end

@implementation NIMFMDataSource

+ (instancetype)defaultDataSource
{
    static NIMFMDataSource *_defaultDataSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultDataSource = [[self alloc] init];
    });

    return _defaultDataSource;
}

#pragma mark - Public Interface

- (NSString *)cacheFilename {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"tweets-cache"];
}

- (void)fetchCachedTweets:(NIMFMDataSourceTweetsResultsBlock)resultsBlock
{
    if (!resultsBlock) {
        return;
    }
    NSArray *tweets = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cacheFilename]];
    resultsBlock(tweets, nil);
}

- (void)storeCachedTweets:(NSArray *)tweets
          completionBlock:(NIMFMDataSourceUpdateCompletionBlock)completionBlock
{
    BOOL saved = [NSKeyedArchiver archiveRootObject:tweets toFile:[self cacheFilename]];
    if (completionBlock) {
        completionBlock(saved, nil);
    }
}

@end
