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

    self.settings = nil;
    self.showAvatarsSwitch.on = !self.settings.hideAvatars;
}

- (NIMSettings *)settings
{
    if (!_settings) {
        _settings = [[NSUserDefaults standardUserDefaults] nim_settings];
    }
    return _settings;
}

- (IBAction)showAvatarsSwitchToggled:(UISwitch *)swtch
{
    self.settings.hideAvatars = !swtch.on;
    [[NSUserDefaults standardUserDefaults] nim_setSettings:self.settings];
}

@end
