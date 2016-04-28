//
//  CDUser.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 27/04/16.
//  Copyright © 2016 Nikolay Morev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDTweet;

NS_ASSUME_NONNULL_BEGIN

@interface CDUser : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "CDUser+CoreDataProperties.h"
