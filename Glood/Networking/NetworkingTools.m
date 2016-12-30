//
//  NetworkingTools.m
//  Sparxo Checkin
//
//  Created by sparxo-dev-ios-1 on 16/4/25.
//  Copyright © 2016年 sparxo. All rights reserved.
//

#import "NetworkingTools.h"
#import "AFNetworking.h"

@implementation NetworkingTools

+ (AFHTTPRequestOperationManager *)sharedManager {
    static AFHTTPRequestOperationManager * manager = nil;
    if (!manager) {
        manager = [AFHTTPRequestOperationManager manager];
    }
    
    return manager;
}

@end
