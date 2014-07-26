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
    MyScene* _matchScene;
    GameOverScene* _gameOverScence;
}

-(void)start {
    _state = GS_INIT;
    _defaultClient = [[DefaultClient alloc] initWithDelegate:self];
    [_defaultClient connectWith:@"Scron" passWord:@"bot"];
}

-(Player*) getPlayer:(int64_t)playerId {
    return _players[playerId];
}

-(Player *) getTeamA {
    for (Player* p in _players) {
        if (p.isLeft) {
            return p;
        }
    }
    return nil;
}

-(Player *) getTeamB {
    for (Player* p in _players) {
        if (!p.isLeft) {
            return p;
        }
    }
    return nil;
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
        _state = GS_READY;
        [_defaultClient enter];
    }
}

-(void)matchInit:(NSArray *)players KeyPoints:(NSArray *)points {
    NSLog(@"matchInit");
    _players = players;
    _keyPoints = points;
    
    _matchScene = [[MyScene alloc] initWithSize:self.view.bounds.size];
    _matchScene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [_view presentScene:_matchScene];
    _state = GS_GAMING;
}

-(void)matchEnd:(int) points {
    _state = GS_OVER;
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
