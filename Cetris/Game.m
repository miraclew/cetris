//
//  Game.m
//  Cetris
//
//  Created by Wan Wei on 14/7/23.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "Game.h"
#import "DefaultClient.h"
#import "MatchScene.h"
#import "StartScene.h"

@implementation Game {
    DefaultClient *_defaultClient;
    MatchScene* _matchScene;
    StartScene* _startScene;
    
    NSArray* _players;
    NSArray* _keyPoints;
    
    PlayerTeam _turn;
    int64_t _turnPlayerId;
    PlayerTeam _winner;
    CGFloat _width;
    CGFloat _heigth;
}

-(void)start {
    _state = GS_INIT;
    NSLog(@"Screen size: %f/%f", self.view.bounds.size.width, self.view.bounds.size.height);
    [self presentScene:@"StartScene"];

    _defaultClient = [[DefaultClient alloc] initWithDelegate:self];
    _client = _defaultClient;
    [_defaultClient connectWith:@"Scron" passWord:@"bot"];
    
}

-(SKScene*)presentScene:(NSString*)className {
    CGFloat width,height;
    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        width = self.view.bounds.size.width;
        height = self.view.bounds.size.height;
    } else {
        height = self.view.bounds.size.width;
        width = self.view.bounds.size.height;
    }
    
    _startScene = [[NSClassFromString(className) alloc] initWithSize:CGSizeMake(1024, 768) Game:self];
    if ((int)width == 1024) {
        _startScene.scaleMode = SKSceneScaleModeAspectFill;
    } else {
        _startScene.xScale = width/1024.0f;
        _startScene.yScale = height/768.0f;
    }
    [self.view presentScene:_startScene];
    return _startScene;
}

-(void)matchEnter {
    [_defaultClient enter];
}

-(void)matchFinish {
    SKScene *scene = [[StartScene alloc] initWithSize:self.view.bounds.size Game:self];
    SKTransition *transition = [SKTransition flipHorizontalWithDuration:0.5];
    [self.view presentScene:scene transition:transition];
}

-(Player*) getPlayer:(int64_t)playerId {
    for (Player* p in _players) {
        if (p.playerId == playerId) {
            return p;
        }
    }
    return nil;
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

-(void)authComplete:(BOOL)success UserId:(int64_t)userId{
    if (success) {
        _state = GS_READY;
        _playerId = userId;
        [_startScene ready];
    }
}

-(void)matchInit:(NSArray *)players KeyPoints:(NSArray *)points {
    NSLog(@"matchInit");
    _players = players;
    _keyPoints = points;
    
    _matchScene = (MatchScene*) [self presentScene:@"MatchScene"];
    [_matchScene matchInit:players KeyPoints:points];
    _state = GS_GAMING;
}

-(void)matchEnd:(int) points {
    _state = GS_OVER;
    [_matchScene matchEnd:points];
}

-(void)matchTurn:(int64_t)playerId {
    [_matchScene matchTurn:playerId];
}

-(void)playerMove:(int64_t)playerId position:(CGPoint)position{
    [_matchScene playerMove:playerId position:position];
}

-(void)playerFire:(int64_t)playerId position:(CGPoint)position velocity:(CGVector)velocity{
    [_matchScene playerFire:playerId position:position velocity:velocity];
}

-(void)playerHit:(int64_t)p1 p2:(int64_t)p2 damage:(int)damage{
    Player* player2 = [self getPlayer:p2];
    player2.health -= damage;
    if (player2.health < 0) {
        player2.health = 0;
    }
    [_matchScene playerHit:p1 p2:p2 damage:damage];
}

@end
