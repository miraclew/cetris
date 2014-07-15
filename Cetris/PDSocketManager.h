//
//  PDSocketManager.h
//  Cetris
//
//  Created by Wan Wei on 14/7/15.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

//#import "Protocol.pb.h"

@interface PDSocketManager : NSObject<GCDAsyncSocketDelegate>
{
@private
    NSMutableArray *_requests;
    BOOL _isRunning;
    
    GCDAsyncSocket *_socket;
}

- (void)sendRequest:(Request *)request onCompleted:(void (^)(Response *))completeHandler;

@end