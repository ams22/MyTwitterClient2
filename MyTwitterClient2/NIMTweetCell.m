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

static CGFloat const kAvatarWidth = 48;

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
    imageLayer.borderWidth = 1.0/[UIScreen mainScreen].scale;
    imageLayer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    imageLayer.cornerRadius = 5;
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

    self.avatarWidth.constant = showAvatars ? kAvatarWidth : 0;
    // Загружаем картинку независимо от настройки отображения аватара, чтобы она
    // закэшировалась локально
    [self.avatarImageView sd_setImageWithURL:tweet.user.profileImageURL];
}

+ (CGFloat)preferredHeightWithTweet:(NIMTweet *)tweet width:(CGFloat)width
{
    // Эти параметры необходимо синхронизировать со сторибордом
    CGRect textLabelFrame = CGRectMake(64, 28,
                                       width - 64.0 - 8.0, // отступ справа, отступ слева
                                       320); // максимальная высота
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *textAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:13],
                                      NSParagraphStyleAttributeName : paragraphStyle };
    CGRect boundingRect = [tweet.text boundingRectWithSize:textLabelFrame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:textAttributes context:nil];
    CGFloat height = (MAX(64.0, // высота аватара + отступы
                          CGRectGetMinY(textLabelFrame) + CGRectGetHeight(boundingRect)
                          + 8.0) // отступ от низа
                      + 1.0); // разделитель ячеек

    return height;
}


@end
