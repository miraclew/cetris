//
//  PDSocketManager.m
//  Cetris
//
//  Created by Wan Wei on 14/7/15.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "PDSocketManager.h"

#define KEY_COMPLETE_HANDLER @"xxxxcc"
#define KEY_REQUEST @"ososoccc"

#define REQUEST_HEADER_TAG 1
#define REQUEST_TAG 2

@implementation PDSocketManager

- (id)init
{
    self = [super init];
    if (self)
    {
        _isRunning = NO;
        _requests = [[NSMutableArray alloc] init];
        
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                             delegateQueue:dispatch_get_main_queue()];
        NSError *error;
        [_socket connectToHost:@"192.168.1.192" onPort:9876 error:&error];
        if (error != nil)
        {
            @throw [NSException exceptionWithName:@"GCDAsyncSocket"
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Instance methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)sendRequest:(Request *)request onCompleted:(void (^)(Response *))completeHandler
{
    NSDictionary *req = @{KEY_REQUEST: request,
                          KEY_COMPLETE_HANDLER: completeHandler};
    [_requests addObject:req];
    
    NSData *requestData = request.data;
    int32_t length = [requestData length];
    length = htonl(length);
    NSData *lengthData = [NSData dataWithBytes:&length length:sizeof(int32_t)];
    
    NSMutableData *data = [[NSMutableData alloc] initWithData:lengthData];
    [data appendData:requestData];
    [_socket writeData:data withTimeout:30 tag:REQUEST_TAG];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - GCDAsyncSocketDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == REQUEST_TAG)
    {
        if (!_isRunning)
        {
            _isRunning = YES;
            [_socket readDataToLength:sizeof(int32_t) withTimeout:30 tag:REQUEST_HEADER_TAG];
        }
    }
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    switch (tag) {
        case REQUEST_HEADER_TAG:
        {
            int length;
            [data getBytes:&length length:sizeof(int32_t)];
            length = ntohl(length);
            NSLog(@"will reading %d bytes", length);
            [_socket readDataToLength:length withTimeout:30 tag:REQUEST_TAG];
            break;
        }
            
        case REQUEST_TAG:
        {
            NSDictionary *requestInfo = [_requests objectAtIndex:0];
            [_requests removeObject:requestInfo];
            
            Response *response = [Response parseFromData:data];
            
            void (^completeHandler)(Response *) = requestInfo[KEY_COMPLETE_HANDLER];
            completeHandler(response);
            
            if ([_requests count] > 0)
            {
                [_socket readDataToLength:sizeof(int32_t) withTimeout:-1 tag:REQUEST_HEADER_TAG];
            }
            else
            {
                _isRunning = NO;
            }
            break;
        }
            
        default:
            break;
    }
}

@end