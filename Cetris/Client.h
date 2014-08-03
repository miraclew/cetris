//
//  Client.h
//  Cetris
//
//  Created by Wan Wei on 14/7/19.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

typedef enum : NSUInteger {
    DISCONNECTED,
    CONNECTED,
    READY,
    GAMING,
} ClientState;

// Server API
@protocol Client

-(instancetype) initWithDelegate:(id)delegate;

-(void)connectWith:(NSString *)userName passWord:(NSString *)password;

-(ClientState)state;

-(void)enter;

-(void)move:(Float32)x y:(Float32)y;

-(void)fire:(Float32)x y:(Float32)y;

-(void)hit:(int64_t)p1 p2:(int64_t)p2 damage:(Float32)damage;

-(void)exit;

@end

// Server callbacks
@protocol ClientDelegate
@optional

-(void)didConnected;
-(void)didLostConnection:(NSError *)error;
-(void)didConnectError:(NSError *)error;

-(void)didStateChange:(ClientState)state;

-(void)authComplete:(BOOL)success UserId:(int64_t) userId;
-(void)matchInit:(NSArray *)players KeyPoints:(NSArray *)points;
-(void)matchEnd:(int) points;
-(void)matchTurn:(int64_t)playerId;
-(void)playerMove:(int64_t)playerId position:(CGPoint)position;
-(void)playerFire:(int64_t)playerId velocity:(CGVector)velocity;
-(void)playerHit:(int64_t)p1 p2:(int64_t)p2 damage:(int)damage;
-(void)playerHealth:(int64_t)playerId health:(int)health;

@end