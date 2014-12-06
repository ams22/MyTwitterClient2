//
//  NIMSettings.m
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

#import "NIMSettings.h"

@implementation NIMSettings

- (id)copyWithZone:(NSZone *)zone
{
    NIMSettings *copy = [[NIMSettings allocWithZone:zone] init];
    copy.hideAvatars = self.hideAvatars;

    return copy;
}

@end

static NSString *const kUserDefaultsSettingsPrefix = @"nim_";
static NSString *const kUserDefaultsHideAvatarsKey = @"hideAvatars";

@implementation NSUserDefaults (NIMSettings)

- (NIMSettings *)nim_settings
{
    NIMSettings *settings = [[NIMSettings alloc] init];

    NSString *hideAvatarsKey = [kUserDefaultsSettingsPrefix stringByAppendingString:kUserDefaultsHideAvatarsKey];
    settings.hideAvatars = [self boolForKey:hideAvatarsKey];

    return settings;
}

- (void)nim_setSettings:(NIMSettings *)settings
{
    NSString *hideAvatarsKey = [kUserDefaultsSettingsPrefix stringByAppendingString:kUserDefaultsHideAvatarsKey];
    [self setBool:settings.hideAvatars forKey:hideAvatarsKey];
    
    [self synchronize];
}

@end
