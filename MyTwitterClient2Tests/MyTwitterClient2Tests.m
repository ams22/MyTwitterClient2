//
//  MyTwitterClient2Tests.m
//  MyTwitterClient2Tests
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import UIKit;
@import XCTest;

#import "NIMTwitterHTTPClient.h"
#import "NIMFMDataSource.h"

@interface MyTwitterClient2Tests : XCTestCase

@end

@implementation MyTwitterClient2Tests

// Интеграционный тест для отладки.
- (void)testExample {
    XCTestExpectation *response = [self expectationWithDescription:@"response"];

    NIMTwitterHTTPClient *client = [[NIMTwitterHTTPClient alloc] init];
    NIMFMDataSource *dataSource = [NIMFMDataSource defaultDataSource];

    [client searchTweetsCompletionBlock:^(NSArray *tweets, NSError *error) {
        [dataSource storeCachedTweets:tweets completionBlock:^(BOOL success, NSError *error) {
            [dataSource fetchCachedTweets:^(NSArray *tweets, NSError *error) {
                [response fulfill];
            }];
        }];
    }];

    [self waitForExpectationsWithTimeout:999 handler:nil];
}

@end
