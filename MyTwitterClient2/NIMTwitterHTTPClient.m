//
//  NIMTwitterHTTPClient.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMTwitterHTTPClient.h"
#import "NIMTweet.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
#pragma clang diagnostic ignored "-Wauto-import"
#import "OAuth.h"
#pragma clang diagnostic pop

static NSString *const NIMTwitterHTTPClientBaseURLString = @"https://api.twitter.com/1.1/";
static NSString *const NIMTwitterHTTPClientConsumerKey = @"83ZNM9vmZiMOo9EfMlM4fU9CG";
static NSString *const NIMTwitterHTTPClientConsumerSecret = @"LusD3WSbsilUIfvJ8Kt6XDe5NXP2krPsyaOr7LpnrZo7dtKx3e";
static NSString *const NIMTwitterHTTPClientAccessToken = @"47601564-Q3n72hpbHyOYgtBWuN4E0i04IHCQ3xhdx3MYcQ6CU";
static NSString *const NIMTwitterHTTPClientAccessTokenSecret = @"LQ4OkOX49k3PFGCBB6LFknAqbXpqUfgwMplPiDMoY5GFZ";

@implementation NIMTwitterHTTPClient

- (void)searchTweetsCompletionBlock:(void (^)(NSArray *tweets, NSError *error))completionBlock
{
#warning построение URL
    NSString *URLString = [[[NSURL URLWithString:NIMTwitterHTTPClientBaseURLString]
                            URLByAppendingPathComponent:@"search/tweets.json"]
                           absoluteString];
    NSDictionary *parameters = @{ @"q" : @"iOS",
                                  @"result_type" : @"recent",
                                  @"lang" : @"en" };
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", URLString, @"lang=en&q=iOS&result_type=recent"]];

    OAuth *oAuth = [[OAuth alloc] initWithConsumerKey:NIMTwitterHTTPClientConsumerKey andConsumerSecret:NIMTwitterHTTPClientConsumerSecret];
    oAuth.oauth_token = NIMTwitterHTTPClientAccessToken;
    oAuth.oauth_token_secret = NIMTwitterHTTPClientAccessTokenSecret;
    oAuth.oauth_token_authorized = YES;
    NSString *OAuthHeaderValue = [oAuth oAuthHeaderForMethod:@"GET" andUrl:URLString andParams:parameters];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:OAuthHeaderValue forHTTPHeaderField:@"Authorization"];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *taskError) {
#warning проверка ошибок

        if (taskError) {
            if (completionBlock) completionBlock(nil, taskError);
            return;
        }

        NSError *JSONError;
        NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        if (!JSONDictionary) {
            if (completionBlock) completionBlock(nil, JSONError);
            return;
        }

        NSMutableArray *tweets = [NSMutableArray array];
        NSArray *tweetsJSON = JSONDictionary[@"statuses"];
        for (NSDictionary *statusJSON in tweetsJSON) {
            [tweets addObject:[[NIMTweet alloc] initWithJSONDictionary:statusJSON]];
        }

        if (completionBlock) completionBlock(tweets, nil);
    }];
    [task resume];
}

@end
