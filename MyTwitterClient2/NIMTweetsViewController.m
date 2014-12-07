//
//  NIMTweetsViewController.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMTweetsViewController.h"
#import "NIMTweetCell.h"
#import "NIMTwitterHTTPClient.h"
#import "NIMTweet.h"
#import "NIMSettings.h"
#import "NIMFMDataSource.h"

#warning <#message#>
//static NSTimeInterval const kRefreshInterval = 60.0;
static NSTimeInterval const kRefreshInterval = 15.0;
static NSTimeInterval const kTimerLabelRefreshInterval = 0.5;

@interface NIMTweetsViewController ()

@property (nonatomic, strong) NIMTwitterHTTPClient *twitterClient;
@property (nonatomic, strong) NIMFMDataSource *dataSource;
@property (nonatomic, copy) NSArray *tweets;
@property (nonatomic, weak) UILabel *timerLabel;
@property (nonatomic, weak) NSTimer *refreshTimer;
@property (nonatomic, weak) NSTimer *labelTimer;
@property (nonatomic, copy) NIMSettings *settings;

@end

@implementation NIMTweetsViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    UILabel *timerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    timerLabel.text = [self timerLabelText];
    [timerLabel sizeToFit];

    UIBarButtonItem *timerItem = [[UIBarButtonItem alloc] initWithCustomView:timerLabel];
    self.navigationItem.leftBarButtonItem = timerItem;
    self.timerLabel = timerLabel;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Настройки могли обновиться
    self.settings = nil;
    [self.tableView reloadData];

    // Сначала покажем закэшированное
    [self.dataSource fetchCachedTweets:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweets = tweets;
        }

        // Потом попробуем загрузить по сети
        [self refreshTweets];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

#warning проверить, достаточно ли инвалидировать только здесь или нужно еще что-то предусмотреть
    [self.refreshTimer invalidate];
    [self.labelTimer invalidate];
}

#pragma mark -

- (NIMSettings *)settings
{
    if (!_settings) {
        _settings = [[NSUserDefaults standardUserDefaults] nim_settings];
    }
    return _settings;
}

- (NIMTwitterHTTPClient *)twitterClient
{
    if (!_twitterClient) {
        _twitterClient = [[NIMTwitterHTTPClient alloc] init];
    }
    return _twitterClient;
}

- (NIMFMDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NIMFMDataSource defaultDataSource];
    }
    return _dataSource;
}

- (void)refreshTweets
{
    [self.refreshTimer invalidate];
    [self.labelTimer invalidate];

    self.timerLabel.text = @"↺";

    [self.twitterClient searchTweetsCompletionBlock:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            self.tweets = tweets;
            [self.dataSource storeCachedTweets:tweets completionBlock:nil];
        }

        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval target:self selector:@selector(refreshTweets) userInfo:nil repeats:NO];
        self.labelTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerLabelRefreshInterval target:self selector:@selector(timerLabelTick) userInfo:nil repeats:YES];
    }];
}

- (void)setTweets:(NSArray *)tweets
{
    _tweets = [tweets copy];
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
}

- (void)timerLabelTick
{
    self.timerLabel.text = [self timerLabelText];
}

- (NSString *)timerLabelText
{
    NSString *timeText = @"--:--";
    if (self.refreshTimer.fireDate) {
        NSTimeInterval interval = MAX(0.0, [self.refreshTimer.fireDate timeIntervalSinceNow]);
        timeText = [NSString stringWithFormat:@"%lus", (unsigned long)interval];
    }

    return [NSString stringWithFormat:@"↻ %@", timeText];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NIMTweetCell" forIndexPath:indexPath];
    NIMTweet *tweet = self.tweets[indexPath.row];
    [cell configureWithTweet:tweet
                 showAvatars:!self.settings.hideAvatars];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NIMTweetCell preferredHeight];
}

@end
