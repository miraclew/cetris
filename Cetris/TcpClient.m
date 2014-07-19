//
//  TcpClient.m
//  Cetris
//
//  Created by Wan Wei on 14/7/19.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "TcpClient.h"
#import "GCDAsyncSocket.h"

#define TAG_FIXED_LENGTH_HEADER 1
#define TAG_RESPONSE_BODY 2
#define TAG_MSG 12

#define HEADER_LENGTH 8

#define HOST @"localhost"
#define PORT 8081

struct Header {
    UInt16 cmd;
    UInt16 length;
    UInt32 crc32;
};

@interface TcpClient() <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *socket;
}

@end

@implementation TcpClient

-(instancetype) init {
    if (self == [super init]) {
        socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return  self;
}

-(void)connect{
    NSError *err = nil;
    NSString *host = HOST;
    uint16_t port = PORT;

    if (![socket connectToHost:host onPort:port error:&err]) {
        NSLog(@"Connect Error:%@", err);
    }
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"DisConnect Error: %@", err);
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"Cool, I'm connected! That was easy.");
    // write some test data
    NSString *requestStr = @"hello";
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:requestData withTimeout:-1 tag:0];
    [sock readDataToLength:HEADER_LENGTH withTimeout:-1 tag:TAG_FIXED_LENGTH_HEADER];
    
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if (tag == TAG_FIXED_LENGTH_HEADER)
    {
        int bodyLength = [self parseHeader:data];
        [sock readDataToLength:bodyLength withTimeout:-1 tag:TAG_RESPONSE_BODY];
    }
    else if (tag == TAG_RESPONSE_BODY)
    {
        // Process the response
        [self handleResponseBody:data];
        
        // Start reading the next response
        [socket readDataToLength:HEADER_LENGTH withTimeout:-1 tag:TAG_FIXED_LENGTH_HEADER];
    }
}

-(int) parseHeader:(NSData *)data {
    const struct Header* header = (const struct Header*)[data bytes];
    
    return (int) header->length;
}

-(void)handleResponseBody:(NSData *)data {
    
}

@end
