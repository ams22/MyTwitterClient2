//
//  NIMSettingsViewController.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMSettingsViewController.h"
#import "NIMSettings.h"

@interface NIMSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *showAvatarsSwitch;
@property (nonatomic, copy) NIMSettings *settings;

@end

@implementation NIMSettingsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.settings = [[NSUserDefaults standardUserDefaults] nim_settings];
    self.showAvatarsSwitch.on = !self.settings.hideAvatars;
}

- (IBAction)showAvatarsSwitchToggled:(UISwitch *)swtch
{
    self.settings.hideAvatars = !swtch.on;
    [[NSUserDefaults standardUserDefaults] nim_setSettings:self.settings];
}

// Явное задание высоты ячейки необходимо, чтобы заглушить сообщение в консоли:
// 2014-12-07 21:58:48.718 MyTwitterClient2[11032:3072228] Warning once only: Detected a case where constraints ambiguously suggest a height of zero for a tableview cell's content view. We're considering the collapse unintentional and using standard height instead.
// Еще можно было бы добавить вертикальные констрейнты, но IB не позволяет этого сделать.

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end
