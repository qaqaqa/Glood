//
//  Mic+CoreDataProperties.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/26.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Mic.h"

NS_ASSUME_NONNULL_BEGIN

@interface Mic (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accountId;
@property (nullable, nonatomic, retain) NSString *avatarImage;
@property (nullable, nonatomic, retain) NSString *fromUserName;
@property (nullable, nonatomic, retain) NSNumber *isRead;
@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) NSString *messageId;
@property (nullable, nonatomic, retain) NSString *roomId;
@property (nullable, nonatomic, retain) NSNumber *time;
@property (nullable, nonatomic, retain) NSString *userId;

@end

NS_ASSUME_NONNULL_END
