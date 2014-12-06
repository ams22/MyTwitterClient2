//
//  NIMSettings.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 06.12.14.
//  Copyright (c) 2014 Nikolay Morev. All rights reserved.
//

@import Foundation;

@interface NIMSettings : NSObject <NSCopying>

@property (nonatomic) BOOL hideAvatars;

@end

@interface NSUserDefaults (NIMSettings)

- (NIMSettings *)nim_settings;
- (void)nim_setSettings:(NIMSettings *)settings;

@end
