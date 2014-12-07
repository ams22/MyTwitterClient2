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
#import "GCOAuth.h"
#pragma clang diagnostic pop

NSString *const NIMTwitterHTTPClientErrorDomain = @"NIMTwitterHTTPClientErrorDomain";
NSString *const NIMTwitterHTTPClientErrorResponseKey = @"NIMTwitterHTTPClientErrorResponse";

static NSString *const NIMTwitterHTTPClientConsumerKey = @"83ZNM9vmZiMOo9EfMlM4fU9CG";
static NSString *const NIMTwitterHTTPClientConsumerSecret = @"LusD3WSbsilUIfvJ8Kt6XDe5NXP2krPsyaOr7LpnrZo7dtKx3e";
static NSString *const NIMTwitterHTTPClientAccessToken = @"47601564-Q3n72hpbHyOYgtBWuN4E0i04IHCQ3xhdx3MYcQ6CU";
static NSString *const NIMTwitterHTTPClientAccessTokenSecret = @"LQ4OkOX49k3PFGCBB6LFknAqbXpqUfgwMplPiDMoY5GFZ";

@implementation NIMTwitterHTTPClient

- (NSURLSessionTask *)searchTweetsCompletionBlock:(NIMTwitterHTTPClientTweetsCompletionBlock)completionBlock
{
    NSDictionary *parameters = @{ @"q" : @"iOS",
                                  @"result_type" : @"recent",
                                  @"lang" : @"en" };

    NSURLRequest *request = [GCOAuth URLRequestForPath:@"/1.1/search/tweets.json"
                                         GETParameters:parameters
                                                scheme:@"https"
                                                  host:@"api.twitter.com"
                                           consumerKey:NIMTwitterHTTPClientConsumerKey
                                        consumerSecret:NIMTwitterHTTPClientConsumerSecret
                                           accessToken:NIMTwitterHTTPClientAccessToken
                                           tokenSecret:NIMTwitterHTTPClientAccessTokenSecret];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *taskError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (taskError) {
                if (completionBlock) completionBlock(nil, taskError);
                return;
            }

            NSError *JSONError;
            id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
            if (!JSONDictionary) {
                if (completionBlock) completionBlock(nil, JSONError);
                return;
            }

            NSHTTPURLResponse *HTTPResponse = (id)response;
            if ([HTTPResponse statusCode] != 200) {
                NSDictionary *userInfo = JSONDictionary ? @{ NIMTwitterHTTPClientErrorResponseKey : JSONDictionary } : nil;
                NSError *error = [NSError errorWithDomain:NIMTwitterHTTPClientErrorDomain
                                                     code:[HTTPResponse statusCode]
                                                 userInfo:userInfo];
                if (completionBlock) completionBlock(nil, error);
                return;
            }

            NSMutableArray *tweets = [NSMutableArray array];
            NSArray *tweetsJSON = JSONDictionary[@"statuses"];
            for (NSDictionary *statusJSON in tweetsJSON) {
                [tweets addObject:[[NIMTweet alloc] initWithJSONDictionary:statusJSON]];
            }
            
            if (completionBlock) completionBlock(tweets, nil);
        });
    }];
    [task resume];

    return task;
}

@end
