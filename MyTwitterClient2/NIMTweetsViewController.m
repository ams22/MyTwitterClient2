//
//  NIMTweetsViewController.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMTweetsViewController.h"
#import "NIMTweetCell.h"
#import "NIMTweet.h"
#import "NIMSettings.h"
#import "NIMTweetsDataController.h"

static NSTimeInterval const kTimerLabelRefreshInterval = 0.5;

@interface NIMTweetsViewController () <NIMTweetsDataControllerDelegate>

@property (nonatomic, strong) NIMTweetsDataController *dataController;
@property (nonatomic, weak) UILabel *timerLabel;
@property (nonatomic, weak) NSTimer *labelTimer;
@property (nonatomic, copy) NIMSettings *settings;

@end

@implementation NIMTweetsViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.dataController = [[NIMTweetsDataController alloc] init];
    self.dataController.delegate = self;

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

    [self.dataController startUpdating];

    NSTimer *labelTimer = [NSTimer timerWithTimeInterval:kTimerLabelRefreshInterval target:self selector:@selector(timerLabelTick) userInfo:nil repeats:YES];
    // Чтобы работало во время скроллинга
    [[NSRunLoop currentRunLoop] addTimer:labelTimer forMode:NSRunLoopCommonModes];
    self.labelTimer = labelTimer;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.dataController stopUpdating];
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

- (void)timerLabelTick
{
    self.timerLabel.text = [self timerLabelText];
    [self.timerLabel sizeToFit];
}

- (NSString *)timerLabelText
{
    if (self.dataController.fetching) {
        return @"↺";
    }
    else {
        NSTimeInterval interval = self.dataController.timeUntilNextFetch;
        NSString *timeText = [NSString stringWithFormat:@"%lus", (unsigned long)interval];

        return [NSString stringWithFormat:@"↻ %@", timeText];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataController.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NIMTweetCell" forIndexPath:indexPath];
    NIMTweet *tweet = self.dataController.tweets[indexPath.row];
    [cell configureWithTweet:tweet
                 showAvatars:!self.settings.hideAvatars];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIMTweet *tweet = self.dataController.tweets[indexPath.row];
    return [NIMTweetCell preferredHeightWithTweet:tweet width:CGRectGetWidth(tableView.bounds)];
}

#pragma mark - NIMTweetsDataControllerDelegate

- (void)tweetsDataControllerDidChangeContents:(NIMTweetsDataController *)controller
{
    [self.tableView reloadData];
}

@end
