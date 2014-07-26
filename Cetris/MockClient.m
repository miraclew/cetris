//
//  MockClient.m
//  Cetris
//
//  Created by Wan Wei on 14/7/26.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "MockClient.h"
#import "Player.h"

@implementation MockClient {
    id _delegate;
    ClientState _state;
}

-(instancetype) initWithDelegate:(id)delegate {
    if (self == [super init]) {
        _delegate = delegate;
        _state = DISCONNECTED;
    }
    return  self;
}


#pragma 
#pragma client api

-(void)connectWith:(NSString *)userName passWord:(NSString *)password {
    if ([_delegate respondsToSelector:@selector(authComplete:UserId:)]) {
        [_delegate authComplete:YES UserId:1];
    }
}

-(ClientState)state {
    return _state;
}

-(void)enter {
    NSArray* nickNames = @[@"Optimus Prime", @"BumbleBee"];
    NSArray* avatars = @[@"http://a.hiphotos.baidu.com/baike/c0%3Dbaike116%2C5%2C5%2C116%2C38/sign=4dc8e79100087bf469e15fbb93ba3c49/08f790529822720e5cae3a2079cb0a46f31fab8c.jpg", @"http://baike.baidu.com/picture/10900924/11204216/0/b2de9c82d158ccbfd2f169e01bd8bc3eb035419f?fr=lemma&ct=single"];
    
    NSMutableArray *players = [[NSMutableArray alloc] init];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (int i=0; i<2; i++) {
        Player *player = [[Player alloc] init];
        player.playerId = i+1;
        player.nickName = nickNames[i];
        player.avatar = avatars[i];
        player.isLeft = YES;
        player.position = CGPointMake(0.1, 0.2);
        [players addObject:player];
    }
    
    for (int i=0; i<2; i++) {
        
    }
    
    if ([_delegate respondsToSelector:@selector(matchInit:KeyPoints:)]) {
        [_delegate matchInit:players KeyPoints:points];
    }
}

-(void)move:(Float32)x y:(Float32)y {
    
}

-(void)fire:(Float32)x y:(Float32)y {
    
}

-(void)hit:(int64_t)p1 p2:(int64_t)p2 damage:(Float32)damage {
    
}


@end
