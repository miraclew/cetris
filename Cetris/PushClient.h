//
//  PushClient.h
//  quan-iphone
//
//  Created by Wan Wei on 14-4-22.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@interface PushClient : NSObject

+ (PushClient *)sharedClient;

@property (nonatomic,strong) NSString* token;
@property (nonatomic, readonly) SRReadyState state;

- (void)connectWithToken:(NSString *)token;
- (void)disconnect;

@end
