//
//  NIMTweetCell.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import UIKit;

@class NIMTweet;

@interface NIMTweetCell : UITableViewCell

- (void)configureWithTweet:(NIMTweet *)tweet
               showAvatars:(BOOL)showAvatars;
+ (CGFloat)preferredHeight;

@end
