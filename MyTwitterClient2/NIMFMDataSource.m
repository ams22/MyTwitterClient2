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
#import <FMDB/FMDB.h>

@interface NIMFMDataSource ()

@property (nonatomic, strong) FMDatabase *database;

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

- (instancetype)init {
    if (self = [super init]) {
        NSString *cacheFilename = [self cacheFilename];
        NSLog(@"cacheFilename = %@", cacheFilename);
        _database = [FMDatabase databaseWithPath:cacheFilename];
        BOOL opened = [_database open];
        if (!opened) {
            return nil;
        }
        BOOL created = [self createTables];
        if (!created) {
            return nil;
        }
    }
    return self;
}

- (BOOL)createTables {
    NSString *sql =
    @"CREATE TABLE IF NOT EXISTS user (id_str TEXT PRIMARY KEY, name TEXT, profile_image_url TEXT, screen_name TEXT);"
    "CREATE TABLE IF NOT EXISTS tweet (id_str TEXT PRIMARY KEY, created_at TIMESTAMP, txt TEXT, user TEXT, FOREIGN KEY(user) REFERENCES user(id_str));";

    return [self.database executeStatements:sql];
}

#pragma mark - Public Interface

- (NSString *)cacheFilename {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"cached-tweets.db"];
}

- (void)fetchCachedTweets:(NIMFMDataSourceTweetsResultsBlock)resultsBlock
{
    if (!resultsBlock) {
        return;
    }

    FMResultSet *s = [self.database executeQuery:@"SELECT t.id_str t_id_str, t.created_at t_created_at, t.txt t_txt, t.user t_user, u.id_str u_id_str, u.name u_name, u.profile_image_url u_profile_image_url, u.screen_name u_screen_name FROM tweet t JOIN user u ON t.user = u.id_str ORDER BY t.created_at DESC"];
    if (!s) {
        resultsBlock(nil, nil);
        return;
    }

    NSMutableArray *tweets = [NSMutableArray array];
    while ([s next]) {
        NIMUser *user = [[NIMUser alloc] init];
        user.idStr = [s stringForColumn:@"u_id_str"];
        user.name = [s stringForColumn:@"u_name"];
        user.profileImageURL = [NSURL URLWithString:[s stringForColumn:@"u_profile_image_url"]];
        user.screenName = [s stringForColumn:@"u_screen_name"];

        NIMTweet *tweet = [[NIMTweet alloc] init];
        tweet.idStr = [s stringForColumn:@"t_id_str"];
        tweet.createdAt = [s dateForColumn:@"t_created_at"];
        tweet.text = [s stringForColumn:@"t_txt"];
        tweet.user = user;

        [tweets addObject:tweet];
    }

    [s close];

    resultsBlock(tweets, nil);
}

- (void)storeCachedTweets:(NSArray *)tweets
          completionBlock:(NIMFMDataSourceUpdateCompletionBlock)completionBlock
{
    BOOL ok;

    // Deduplicate users
    NSMutableSet *users = [NSMutableSet set];
    for (NIMTweet *tweet in tweets) {
        [users addObject:tweet.user];
    }

    ok = [self.database beginTransaction];
    if (!ok) {
        if (completionBlock) {
            completionBlock(NO, nil);
        }
        return;
    }

    ok = [self.database executeUpdate:@"DELETE FROM tweet"];
    if (!ok) goto cleanup;

    ok = [self.database executeUpdate:@"DELETE FROM user"];
    if (!ok) goto cleanup;

    for (NIMUser *user in users) {
        NSDictionary *userDictionary = @{ @"id_str" : user.idStr,
                                          @"name" : user.name ?: [NSNull null],
                                          @"profile_image_url" : user.profileImageURL ?: [NSNull null],
                                          @"screen_name" : user.screenName ?: [NSNull null] };
        ok = [self.database executeUpdate:@"INSERT INTO user (id_str, name, profile_image_url, screen_name) VALUES (:id_str, :name, :profile_image_url, :screen_name)"
                  withParameterDictionary:userDictionary];
        if (!ok) goto cleanup;
    }

    for (NIMTweet *tweet in tweets) {
        NSDictionary *tweetDictionary = @{ @"id_str" : tweet.idStr,
                                           @"created_at" : tweet.createdAt ?: [NSNull null],
                                           @"txt" : tweet.text ?: [NSNull null],
                                           @"user" : tweet.user.idStr ?: [NSNull null] };
        ok = [self.database executeUpdate:@"INSERT INTO tweet (id_str, created_at, txt, user) VALUES (:id_str, :created_at, :txt, :user)"
                  withParameterDictionary:tweetDictionary];
        if (!ok) goto cleanup;
    }

cleanup:
    if (ok) {
        [self.database commit];
    }
    else {
        [self.database rollback];
    }
    if (completionBlock) {
        completionBlock(ok, nil);
    }
}

@end
