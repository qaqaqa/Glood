//
//  Node+CoreDataProperties.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/27.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Node.h"

NS_ASSUME_NONNULL_BEGIN

@interface Node (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *roomId;
@property (nullable, nonatomic, retain) NSString *lastMessageId;
@property (nullable, nonatomic, retain) NSString *beginMessageId;
@property (nullable, nonatomic, retain) NSString *accountId;

@end

NS_ASSUME_NONNULL_END
