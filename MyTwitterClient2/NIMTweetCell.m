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

#warning variable height
#warning конфигурирование объектом модели вынести в категорию?

@interface NIMTweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;

@end

@implementation NIMTweetCell

- (void)prepareForReuse
{

}

- (void)configureWithTweet:(NIMTweet *)tweet
{
    self.usernameLabel.text = [NSString stringWithFormat:@"%@ at %@", tweet.user.screenName, tweet.createdAt];
    self.tweetTextLabel.text = tweet.text;
}

+ (CGFloat)preferredHeight
{
    return 88.f;
}

@end
