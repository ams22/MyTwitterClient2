//
//  NIMTwitterHTTPClient.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import Foundation;

typedef void (^NIMTwitterHTTPClientTweetsCompletionBlock)(NSArray *tweets, NSError *error);

extern NSString *const NIMTwitterHTTPClientErrorDomain;
extern NSString *const NIMTwitterHTTPClientErrorResponseKey;

@interface NIMTwitterHTTPClient : NSObject

/**
 @param completionBlock tweets - массив NIMTweet-ов или nil, если произошла ошибка error
 */
- (NSURLSessionTask *)searchTweetsCompletionBlock:(NIMTwitterHTTPClientTweetsCompletionBlock)completionBlock;

@end
