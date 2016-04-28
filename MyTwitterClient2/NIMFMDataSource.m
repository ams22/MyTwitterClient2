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
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "CDTweet+CoreDataProperties.h"
#import "CDUser+CoreDataProperties.h"

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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    // Deduplicate users
    NSMutableSet *users = [NSMutableSet set];
    for (NIMTweet *tweet in tweets) {
        [users addObject:tweet.user];
    }

    NSMutableDictionary *cdUsers = [NSMutableDictionary dictionary];

    for (NIMUser *user in users) {
        CDUser *cdUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        cdUser.idStr = user.idStr;
        cdUser.name = user.name;
        cdUser.profileImageURL = user.profileImageURL.absoluteString;
        cdUser.screenName = user.screenName;

        cdUsers[user.idStr] = cdUser;
    }

    for (NIMTweet *tweet in tweets) {
        CDTweet *cdTweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:context];
        cdTweet.idStr = tweet.idStr;
        cdTweet.createdAt = tweet.createdAt;
        cdTweet.text = tweet.text;
        cdTweet.user = cdUsers[tweet.user.idStr];
    }

    BOOL saved = [context save:NULL];

    if (completionBlock) {
        completionBlock(saved, nil);
    }
}

@end
