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

@implementation NIMUser (NIMFMDataSource)

- (NSDictionary *)nim_FMDSDictionary
{
    return @{ @"id_str" : self.idStr,
              @"name" : self.name,
              @"profile_image_url" : [self.profileImageURL absoluteString],
              @"screen_name" : self.screenName };
}

+ (instancetype)nim_userWithFMResultSet:(FMResultSet *)s
{
    NIMUser *user = [[NIMUser alloc] init];
    user.idStr = [s stringForColumn:@"u_id_str"];
    user.name = [s stringForColumn:@"u_name"];
    user.profileImageURL = [NSURL URLWithString:[s stringForColumn:@"u_profile_image_url"]];
    user.screenName = [s stringForColumn:@"u_screen_name"];

    return user;
}

@end

@implementation NIMTweet (NIMFMDataSource)

- (NSDictionary *)nim_FMDSDictionary
{
    return @{ @"id_str" : self.idStr,
              @"created_at" : self.createdAt,
              @"txt" : self.text,
              @"user" : self.user.idStr };
}

+ (instancetype)nim_tweetWithFMResultSet:(FMResultSet *)s
{
    NIMTweet *tweet = [[NIMTweet alloc] init];
    tweet.idStr = [s stringForColumn:@"t_id_str"];
    tweet.createdAt = [s dateForColumn:@"t_created_at"];
    tweet.text = [s stringForColumn:@"t_txt"];
    tweet.user = [NIMUser nim_userWithFMResultSet:s];

    return tweet;
}

@end

@interface NIMFMDataSource ()

@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation NIMFMDataSource

+ (NSString *)defaultDatabasePath
{
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheDirectory stringByAppendingPathComponent:@"cache.sqlite"];

    return path;
}

+ (instancetype)defaultDataSource
{
    return [[self alloc] initWithDatabasePath:[self defaultDatabasePath]];
}

- (instancetype)initWithDatabasePath:(NSString *)path
{
    if (self = [super init]) {
        _databasePath = [path copy];
        _queue = dispatch_queue_create("MyTwitterClient2.DataSource", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    [_database close];
}

- (FMDatabase *)database
{
    if (![_database goodConnection]) _database = nil;
    if (!_database) {
        _database = [[FMDatabase alloc] initWithPath:self.databasePath];
        if (![_database open]) {
            _database = nil;
        }
        if (![self createTables]) {
            _database = nil;
        }
    }
    
    return _database;
}

#pragma mark - Statements

- (BOOL)createTables
{
    NSString *sql =
    @"CREATE TABLE IF NOT EXISTS user (id_str TEXT PRIMARY KEY, name TEXT, profile_image_url TEXT, screen_name TEXT);"
    "CREATE TABLE IF NOT EXISTS tweet (id_str TEXT PRIMARY KEY, created_at TIMESTAMP, txt TEXT, user TEXT, FOREIGN KEY(user) REFERENCES user(id_str));";

    return [self.database executeStatements:sql];
}

- (NSArray *)cachedTweets
{
    FMResultSet *s = [self.database executeQuery:@"SELECT t.id_str t_id_str, t.created_at t_created_at, t.txt t_txt, t.user t_user, u.id_str u_id_str, u.name u_name, u.profile_image_url u_profile_image_url, u.screen_name u_screen_name FROM tweet t JOIN user u ON t.user = u.id_str ORDER BY t.created_at DESC"];
    if (!s) {
        return nil;
    }

    NSMutableArray *tweets = [NSMutableArray array];
    while ([s next]) {
        NIMTweet *tweet = [NIMTweet nim_tweetWithFMResultSet:s];
        [tweets addObject:tweet];
    }

    [s close];

    return tweets;
}

- (BOOL)storeCachedTweets:(NSArray *)tweets
{
    BOOL ok;

    // Deduplicate users
    NSMutableSet *users = [NSMutableSet set];
    for (NIMTweet *tweet in tweets) {
        [users addObject:tweet.user];
    }

    ok = [self.database beginTransaction];
    if (!ok) return NO;

    ok = [self.database executeUpdate:@"DELETE FROM tweet"];
    if (!ok) goto cleanup;

    ok = [self.database executeUpdate:@"DELETE FROM user"];
    if (!ok) goto cleanup;

    for (NIMUser *user in users) {
        ok = [self.database executeUpdate:@"INSERT INTO user (id_str, name, profile_image_url, screen_name) VALUES (:id_str, :name, :profile_image_url, :screen_name)"
                  withParameterDictionary:[user nim_FMDSDictionary]];
        if (!ok) goto cleanup;
    }

    for (NIMTweet *tweet in tweets) {
        ok = [self.database executeUpdate:@"INSERT INTO tweet (id_str, created_at, txt, user) VALUES (:id_str, :created_at, :txt, :user)"
                  withParameterDictionary:[tweet nim_FMDSDictionary]];
        if (!ok) goto cleanup;
    }

cleanup:
    if (ok) {
        [self.database commit];
        return YES;
    }
    else {
        [self.database rollback];
        return NO;
    }
}

#pragma mark - Public Interface

- (void)fetchCachedTweets:(void (^)(NSArray *, NSError *))resultsBlock
{
    dispatch_async(self.queue, ^{
        NSArray *tweets = [self cachedTweets];
        if (resultsBlock) {
            NSError *error = [self.database hadError] ? [self.database lastError] : nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                resultsBlock(tweets, error);
            });
        }
    });
}

- (void)storeCachedTweets:(NSArray *)tweets
          completionBlock:(void (^)(BOOL, NSError *))completionBlock
{
    dispatch_async(self.queue, ^{
        BOOL ok = [self storeCachedTweets:tweets];
        if (completionBlock) {
            NSError *error = [self.database hadError] ? [self.database lastError] : nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(ok, error);
            });
        }
    });
}

@end
