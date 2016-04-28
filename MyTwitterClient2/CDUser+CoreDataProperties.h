//
//  CDUser+CoreDataProperties.h
//  MyTwitterClient2
//
//  Created by Nikolay Morev on 27/04/16.
//  Copyright © 2016 Nikolay Morev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idStr;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *profileImageURL;
@property (nullable, nonatomic, retain) NSString *screenName;
@property (nullable, nonatomic, retain) NSSet<CDTweet *> *tweets;

@end

@interface CDUser (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(CDTweet *)value;
- (void)removeTweetsObject:(CDTweet *)value;
- (void)addTweets:(NSSet<CDTweet *> *)values;
- (void)removeTweets:(NSSet<CDTweet *> *)values;

@end

NS_ASSUME_NONNULL_END
