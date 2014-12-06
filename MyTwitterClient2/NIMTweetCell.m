//
//  NIMTweetCell.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMTweetCell.h"
#import "NIMTweet.h"
#import "NIMUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
@import QuartzCore;

#warning variable height
#warning конфигурирование объектом модели вынести в категорию?

@interface NIMTweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;

@end

@implementation NIMTweetCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    CALayer *imageLayer = self.avatarImageView.layer;
    imageLayer.masksToBounds = YES;
    imageLayer.borderWidth = 1.f/[UIScreen mainScreen].scale;
    imageLayer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.5f].CGColor;
    imageLayer.cornerRadius = 5.f;
}

- (void)prepareForReuse
{
    [self.avatarImageView sd_cancelCurrentImageLoad];
}

- (void)configureWithTweet:(NIMTweet *)tweet
{
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@ at %@", tweet.user.screenName, tweet.createdAt];
    self.tweetTextLabel.text = tweet.text;
    [self.avatarImageView sd_setImageWithURL:tweet.user.profileImageURL];
}

+ (CGFloat)preferredHeight
{
    return 88.f;
}

@end
