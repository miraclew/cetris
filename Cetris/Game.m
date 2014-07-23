//
//  Game.m
//  Cetris
//
//  Created by Wan Wei on 14/7/23.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "Game.h"
#import "DefaultClient.h"

@implementation Game {
    DefaultClient *_defaultClient;
    GameState _state;
}

-(void)start {
    _state = GS_INIT;
    _defaultClient = [[DefaultClient alloc] initWithDelegate:self];
    [_defaultClient connectWith:@"Scron" passWord:@"bot"];
    
}

#pragma mark -
#pragma mark ClientDelegate

-(void)didConnected {
    
}

-(void)didLostConnection:(NSError *)error{
    
}

-(void)didConnectError:(NSError *)error {
    
}

-(void)didStateChange:(ClientState)state {
    
}

-(void)matchInit:(NSArray *)players KeyPoints:(NSArray *)points {
    
}
-(void)matchEnd:(int) points {
    
}
-(void)matchTurn:(int64_t)playerId {
    
}
-(void)playerMove:(int64_t)playerId position:(CGPoint)position{
    
}
-(void)playerFire:(int64_t)playerId velocity:(CGVector)velocity{
    
}
-(void)playerHit:(int64_t)p1 p2:(int64_t)p2 damage:(int)damage{
    
}
-(void)playerHealth:(int64_t)playerId health:(int)health{
    
}

@end
