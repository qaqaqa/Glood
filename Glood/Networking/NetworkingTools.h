//
//  NetworkingTools.h
//  Sparxo Checkin
//
//  Created by sparxo-dev-ios-1 on 16/4/25.
//  Copyright © 2016年 sparxo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetworkingTools : NSObject

+ (AFHTTPRequestOperationManager *)sharedManager;

@end