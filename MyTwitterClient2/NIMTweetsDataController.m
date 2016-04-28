//
//  NIMTweetsDataController.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 07.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMTweetsDataController.h"
#import "NIMTwitterHTTPClient.h"
#import "NIMFMDataSource.h"
#import "NIMTweet.h"
#import "NIMUser.h"
#import <SDWebImage/SDWebImagePrefetcher.h>
#import <SDWebImage/SDWebImageManager.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "CDUser+CoreDataProperties.h"
#import "CDTweet+CoreDataProperties.h"

static NSTimeInterval const kRefreshInterval = 60.0;

@interface NIMTweetsDataController ()

@property (nonatomic, weak) NSTimer *refreshTimer;
@property (nonatomic, readwrite, copy) NSArray *tweets;
@property (nonatomic, weak) NSURLSessionTask *fetchTask;
@property (nonatomic) BOOL updating;

@end

@implementation NIMTweetsDataController

- (NIMTwitterHTTPClient *)twitterClient
{
    if (!_twitterClient) {
        _twitterClient = [[NIMTwitterHTTPClient alloc] init];
    }
    return _twitterClient;
}

- (NIMFMDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NIMFMDataSource defaultDataSource];
    }
    return _dataSource;
}

- (void)setTweets:(NSArray *)tweets
{
    _tweets = [tweets copy];
    [self.delegate tweetsDataControllerDidChangeContents:self];
}

- (void)startUpdating
{
    NSAssert(!self.updating, @"Already updating.");

    self.updating = YES;

    // Сначала покажем закэшированное

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"text LIKE iOS"];

    NSArray *tweets = [context executeFetchRequest:request error:NULL];

//    [self.dataSource fetchCachedTweets:^(NSArray *tweets, NSError *error) {
//        if (tweets) {
//            self.tweets = tweets;
//        }
//
//        // Потом попробуем загрузить по сети
//        [self refreshTweets];
//    }];
}

- (void)stopUpdating
{
    self.updating = NO;
    [self.fetchTask cancel];
    [self.refreshTimer invalidate];
}

- (void)refreshTweets
{
    [self.refreshTimer invalidate];
    
    self.fetchTask = [self.twitterClient searchTweetsCompletionBlock:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweets = tweets;
            [self.dataSource storeCachedTweets:tweets completionBlock:nil];

            // Сохраним в кэше все изображения, чтобы в оффлайне были видны даже
            // те картинки, которые не подгрузились в ячейке, так как
            // соответствующая ячейка не была отображена.

            NSMutableSet *avatarURLs = [NSMutableSet set];
            for (NIMTweet *tweet in tweets) {
                NSURL *URL = tweet.user.profileImageURL;
                if (![[SDWebImageManager sharedManager] cachedImageExistsForURL:URL]) {
                    [avatarURLs addObject:URL];
                }
            }
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:[avatarURLs allObjects]];
        }

        if (self.updating) {
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval target:self selector:@selector(refreshTweets) userInfo:nil repeats:NO];
        }
    }];
}

- (NSTimeInterval)timeUntilNextFetch
{
    return MAX(0.0, [self.refreshTimer.fireDate timeIntervalSinceNow]);
}

- (BOOL)fetching
{
    return !!self.fetchTask;
}

@end
