//
//  PushClient.m
//  quan-iphone
//
//  Created by Wan Wei on 14-4-22.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "PushClient.h"
#import "MessageProcessor.h"

@interface PushClient() <SRWebSocketDelegate>

@end

@implementation PushClient {
    SRWebSocket *_webSocket;
    NSString *_token;
    NSInteger _retryTimeout;
    NSInteger _pingInterval;
    NSTimer *_pingTimer;
    MessageProcessor *_processor;
}

+ (PushClient *)sharedClient {
    static PushClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[PushClient alloc] init];
    });
    return __instance;
}

- (id) init {
    self = [super init];
    if (self) {
        _processor = [[MessageProcessor alloc] init];
        _retryTimeout = 0;
        _pingInterval = 10;
    }
    
    return self;
}

- (SRReadyState)state {
    if (_webSocket == nil) {
        return SR_CLOSED;
    }
    return _webSocket.readyState;
}

- (void) connectWithToken:(NSString *)token {
    _token = token;
    [self reconnect:nil];
}

- (void)disconnect {
    if (_webSocket) {
        [_webSocket close];
    }
}

- (void)reconnect:(id) sender {
    if (_webSocket != nil) {
        _webSocket.delegate = nil;
    }
    
    // connect websocket
    NSString *url = [NSString stringWithFormat:@"ws://%@/?token=%@", kPushServer, _token];
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:url] protocols:@[@"mp-v1"]];
    _webSocket.delegate = self;
    [_webSocket open];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWsStateChanged object:self userInfo:nil];
}

- (void)pingServer {
    [_webSocket send:@"ping"];
}

// websocket delegates
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"success connected.");
    [[NSNotificationCenter defaultCenter] postNotificationName:kWsStateChanged object:self userInfo:nil];

    _retryTimeout = 0;
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:_pingInterval target:self selector:@selector(pingServer) userInfo:nil repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"webSocket didFailWithError: %@",error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kWsStateChanged object:self userInfo:nil];
    [self scheduleConnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"webSocket didCloseWithCode: code=%ld reason=%@", (long)code, reason);
    [[NSNotificationCenter defaultCenter] postNotificationName:kWsStateChanged object:self userInfo:nil];
    [self scheduleConnect];
}

- (void)scheduleConnect {
    [_pingTimer invalidate];
    
    [NSTimer scheduledTimerWithTimeInterval:_retryTimeout target:self selector:@selector(reconnect:) userInfo:nil repeats:NO];
    _retryTimeout = MIN(60, _retryTimeout+5);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (dict != nil) {
        MPMessage *msg = [[MPMessage alloc] initWithClassName:@"messages"];
        msg.objectId = dict[@"id"];
        msg.type = [dict[@"type"] intValue];
        msg.subType = [dict[@"sub_type"] intValue];
        msg.channelId = dict[@"channel_id"];
        msg.senderId = dict[@"sender_id"];
        msg.mimeType = dict[@"mime_type"];
        msg.content = dict[@"content"];
        msg.assObjectId = dict[@"ass_object_id"];
        msg.status = [dict[@"status"] intValue];
        msg.ack = [dict[@"ack"] intValue];
        msg.sentAt = dict[@"created_at"];
        msg.senderName = dict[@"sender_name"];;
        msg.senderAvatar = dict[@"sender_avatar"];;
        
        [_processor process:msg];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWebSocketMessageReceived object:msg];
    }
    NSLog(@"message: %@", message);
}

@end
