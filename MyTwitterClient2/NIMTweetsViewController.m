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

@interface NIMTweetsViewController ()

@property (nonatomic, strong) NIMTwitterHTTPClient *twitterClient;
@property (nonatomic, copy) NSArray *tweets;

@end

@implementation NIMTweetsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.twitterClient searchTweetsCompletionBlock:^(NSArray *tweets, NSError *error) {
        self.tweets = tweets;
    }];
}

#pragma mark -

- (NIMTwitterHTTPClient *)twitterClient
{
    if (!_twitterClient) {
        _twitterClient = [[NIMTwitterHTTPClient alloc] init];
    }
    return _twitterClient;
}

- (void)setTweets:(NSArray *)tweets
{
    _tweets = [tweets copy];
    if ([self isViewLoaded]) {
        [self.tableView reloadData];
    }
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
    [cell configureWithTweet:tweet];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NIMTweetCell preferredHeight];
}

@end
