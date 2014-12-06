//
//  NIMTwitterHTTPClient.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMTwitterHTTPClient.h"
#import "NIMTweet.h"

static NSString *const NIMTwitterHTTPClientBaseURLString = @"https://api.twitter.com/1.1/";

@implementation NIMTwitterHTTPClient

- (void)searchTweetsCompletionBlock:(void (^)(NSArray *tweets, NSError *error))completionBlock
{
#warning построение URL
    NSString *URLString = [[[NSURL URLWithString:NIMTwitterHTTPClientBaseURLString]
                            URLByAppendingPathComponent:@"search/tweets.json"]
                           absoluteString];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", URLString, @"q=iOS&result_type=recent"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
#warning генерация токена
    [request setValue:@"OAuth oauth_consumer_key=\"83ZNM9vmZiMOo9EfMlM4fU9CG\", oauth_nonce=\"c70eb68a760294553b42a9891e61e9e9\", oauth_signature=\"Gph0832yHU1z2bajCH%2Fz1EWUX6M%3D\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"1417858837\", oauth_version=\"1.0\"" forHTTPHeaderField:@"Authorization"];

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
