//
//  NIMTweetsDataController.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 07.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import Foundation;

@class NIMTweetsDataController;

@protocol NIMTweetsDataControllerDelegate <NSObject>

- (void)tweetsDataControllerDidChangeContents:(NIMTweetsDataController *)controller;

@end

@interface NIMTweetsDataController : NSObject

@property (nonatomic, weak) id<NIMTweetsDataControllerDelegate> delegate;
@property (nonatomic, readonly, copy) NSArray *tweets;
@property (nonatomic, readonly) BOOL fetching;
@property (nonatomic, readonly) NSTimeInterval timeUntilNextFetch;

- (void)startUpdating;
- (void)stopUpdating;

@end
