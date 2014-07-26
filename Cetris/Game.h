//
//  Game.h
//  Cetris
//
//  Created by Wan Wei on 14/7/23.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//
//  The Game class control the scene transition and networking

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Client.h"

typedef enum : NSUInteger {
    GS_INIT, // connecting or authenticating
    GS_READY, // conntected,
    GS_GAMING, //
    GS_OVER,
} GameState;

typedef enum : NSUInteger {
    None,
    A,
    B,
} PlayerTeam;

typedef enum : NSUInteger {
    Single,
    OffLine,
    Online,
} GameMode;

@interface Game : NSObject<ClientDelegate>

@property (nonatomic, weak)SKView* view;
@property (nonatomic, strong)id<Client> client;

@property (nonatomic, assign) int64_t playerId;

-(void)start;
-(Player*) getPlayer:(int64_t)playerId;
-(Player *) getTeamA;
-(Player *) getTeamB;

@end
