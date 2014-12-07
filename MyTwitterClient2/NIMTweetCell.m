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

static CGFloat const kAvatarWidth = 48.f;

@interface NIMTweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarWidth;

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

@end

@implementation NIMTweetCell (NIMTweets)

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.doesRelativeDateFormatting = YES;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    });

    return _dateFormatter;
}

- (void)configureWithTweet:(NIMTweet *)tweet showAvatars:(BOOL)showAvatars
{
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@ at %@", tweet.user.screenName, [[[self class] dateFormatter] stringFromDate:tweet.createdAt]];
    self.tweetTextLabel.text = tweet.text;

    if (showAvatars) {
        self.avatarWidth.constant = kAvatarWidth;
        [self.avatarImageView sd_setImageWithURL:tweet.user.profileImageURL];
    }
    else {
        self.avatarWidth.constant = 0.f;
    }
}

+ (CGFloat)preferredHeightWithTweet:(NIMTweet *)tweet width:(CGFloat)width
{
    // Эти параметры необходимо синхронизировать со сторибордом
    CGRect textLabelFrame = CGRectMake(64.f, 28.f,
                                       width - 64.f - 8.f, // отступ справа, отступ слева
                                       320.f); // максимальная высота
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *textAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:13.f],
                                      NSParagraphStyleAttributeName : paragraphStyle };
    CGRect boundingRect = [tweet.text boundingRectWithSize:textLabelFrame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttributes context:nil];
    CGFloat height = MAX(64.f, CGRectGetMinY(textLabelFrame) + CGRectGetHeight(boundingRect) + 8.f) + 1.f;

    return height;
}


@end
