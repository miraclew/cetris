//
//  Client.h
//  Cetris
//
//  Created by Wan Wei on 14/7/19.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

typedef enum : NSUInteger {
    INITIAL,
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

-(void)attacked:(int64_t)p1 damage:(Float32)damage;


@end

// Server callbacks
@protocol ClientDelegate

-(void)didConnected;
-(void)didLostConnection:(NSError *)error;
-(void)didConnectError:(NSError *)error;

-(void)matchBegin:(NSArray *)players KeyPoints:(NSArray *)points;
-(void)matchEnd:(int) points;
-(void)matchTurn;
-(void)playerMove:(int64_t)playerId position:(CGPoint)position;
-(void)playerFire:(int64_t)playerId velocity:(CGVector)velocity;
-(void)playerHealth:(int64_t)playerId health:(int)health;

@end