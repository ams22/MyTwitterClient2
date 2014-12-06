//
//  NIMTwitterHTTPClient.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import Foundation;

@interface NIMTwitterHTTPClient : NSObject

- (void)searchTweetsCompletionBlock:(void (^)(NSArray *tweets, NSError *error))completionBlock;

@end
