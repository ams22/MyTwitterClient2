//
//  NIMTweetCell.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import UIKit;

@interface NIMTweetCell : UITableViewCell

@end

@class NIMTweet;

@interface NIMTweetCell (NIMTweets)

- (void)configureWithTweet:(NIMTweet *)tweet
               showAvatars:(BOOL)showAvatars;
+ (CGFloat)preferredHeightWithTweet:(NIMTweet *)tweet
                              width:(CGFloat)width;

@end
