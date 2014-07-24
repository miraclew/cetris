//
//  Game.m
//  Cetris
//
//  Created by Wan Wei on 14/7/23.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "Game.h"
#import "DefaultClient.h"
#import "GameOverScene.h"
#import "MyScene.h"

@implementation Game {
    DefaultClient *_defaultClient;
    GameState _state;
    NSArray* _players;
    NSArray* _keyPoints;
    MyScene* _matchScene;
    GameOverScene* _gameOverScence;
}

-(void)start {
    _state = GS_INIT;
    _defaultClient = [[DefaultClient alloc] initWithDelegate:self];
    [_defaultClient connectWith:@"Scron" passWord:@"bot"];
}

#pragma mark -
#pragma mark ClientDelegate

-(void)didConnected {
    NSLog(@"didConnected");
}

-(void)didLostConnection:(NSError *)error{
    NSLog(@"didLostConnection");
}

-(void)didConnectError:(NSError *)error {
    NSLog(@"didConnectError");
}

-(void)didStateChange:(ClientState)state {
    NSLog(@"didStateChange: %d", (int)state);
}

-(void)authComplete:(BOOL)success{
    if (success) {
        [_defaultClient enter];
    }
}

-(void)matchInit:(NSArray *)players KeyPoints:(NSArray *)points {
    NSLog(@"matchInit");
    _players = players;
    _keyPoints = points;
    
    _matchScene = [[MyScene alloc] initWithSize:self.view.bounds.size];
    _matchScene.scaleMode = SKSceneScaleModeAspectFill;
    _matchScene.players = _players;
    _matchScene.keyPoints = _keyPoints;
    
    // Present the scene.
    [_view presentScene:_matchScene];
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
