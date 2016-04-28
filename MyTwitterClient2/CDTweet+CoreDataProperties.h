//
//  CDTweet+CoreDataProperties.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 27/04/16.
//  Copyright © 2016 Nikolay Morev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDTweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDTweet (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idStr;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) CDUser *user;

@end

NS_ASSUME_NONNULL_END
