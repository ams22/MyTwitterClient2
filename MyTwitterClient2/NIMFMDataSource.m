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

- (void)fetchCachedTweets:(NIMFMDataSourceTweetsResultsBlock)resultsBlock
{
    if (!resultsBlock) {
        return;
    }
    resultsBlock(@[], nil);
}

- (void)storeCachedTweets:(NSArray *)tweets
          completionBlock:(NIMFMDataSourceUpdateCompletionBlock)completionBlock
{
    if (completionBlock) {
        completionBlock(YES, nil);
    }
}

@end
