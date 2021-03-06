//
//  DefaultClient.m
//  Cetris
//
//  Created by Wan Wei on 14/7/19.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
// http://stackoverflow.com/questions/10277576/google-protocol-buffers-on-ios


#import "DefaultClient.h"
#import "missle.pb.h"
#import "Player.h"

#define TAG_FIXED_LENGTH_HEADER 1
#define TAG_RESPONSE_BODY 2
#define TAG_MSG 12

#define HEADER_LENGTH 8

#define HOST @"192.168.1.103"
//#define HOST @"127.0.0.1"
#define HTTP_PORT 8080
#define TCP_PORT 8081

struct Header {
    UInt16 code;
    UInt16 length;
    UInt32 crc32;
};

@implementation DefaultClient {
    GCDAsyncSocket *_socket;
    id _delegate;
    NSString *_token;
    ClientState _state;
    NSString *_username;
    NSString *_password;
    pb::Code _code;
    int64_t _matchId;
    int64_t _playerId;
}

-(instancetype) initWithDelegate:(id)delegate {
    if (self == [super init]) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _delegate = delegate;
        _state = DISCONNECTED;
    }
    return  self;
}

#pragma mark -
#pragma mark Client api

-(void)connectWith:(NSString *)userName passWord:(NSString *)password{
    NSError *err = nil;
    NSString *host = HOST;
    uint16_t port = TCP_PORT;

    _username = userName;
    _password = password;
    if (![_socket connectToHost:host onPort:port error:&err]) {
        NSLog(@"Connect Error:%@", err);
    }
}

-(ClientState)state{
    return _state;
}

-(void)setState:(ClientState)state {
    _state = state;
    if ([_delegate respondsToSelector:@selector(didStateChange:)]) {
        [_delegate didStateChange:state];
    }
}

-(void)enter{
    pb::CMatchEnter enter;
    [self send:pb::C_MATCH_ENTER Message:&enter];
}

-(void)move:(Float32)x y:(Float32)y{
    pb::CPlayerMove move;
    pb::Point *point = move.mutable_position();
    point->set_x(x);
    point->set_y(y);
    move.set_matchid(_matchId);
    [self send:pb::C_PLAYER_MOVE Message:&move];
}

-(void)fire:(CGPoint)position velocity:(CGVector)velocity {
    pb::CPlayerFire fire;
    pb::Point *vel = fire.mutable_velocity();
    vel->set_x(velocity.dx);
    vel->set_y(velocity.dy);
    
    pb::Point *pos = fire.mutable_position();
    pos->set_x(position.x);
    pos->set_y(position.y);
    
    fire.set_matchid(_matchId);
    [self send:pb::C_PLAYER_FIRE Message:&fire];
}

-(void)hit:(int64_t)p1 p2:(int64_t)p2 damage:(Float32)damage{
    pb::CPlayerHit hit;
    hit.set_matchid(_matchId);
    hit.set_p1(p1);
    hit.set_p2(p2);
    hit.set_damage(damage);
    [self send:pb::C_PLAYER_HIT Message:&hit];
}

-(void)exit {
    pb::CMatchExit exit;
    exit.set_matchid(_matchId);
    [self send:pb::C_MATCH_EXIT Message:&exit];
}

-(void)send:(pb::Code)code Message:(::google_public::protobuf::Message *)msg {
    std::string ps = msg->SerializeAsString();

    Header header;
    header.code = code;
    header.length = ps.size();

//    NSData *data1 = [NSData dataWithBytes:(char *)&header length:HEADER_LENGTH];
//    NSData *data2 = [NSData dataWithBytes:ps.c_str() length:ps.size()];
//    NSLog(@"send head: %@", data1);
//    NSLog(@"send body: %@", data2);
    
    [_socket writeData:[NSData dataWithBytes:(char *) &header length:HEADER_LENGTH] withTimeout:-1 tag:0];
    [_socket writeData:[NSData dataWithBytes:ps.c_str() length:ps.size()] withTimeout:-1 tag:0];
}


#pragma mark -
#pragma mark GCDAsyncSocketDelegate

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"DisConnect Error: %@", err);
    [self setState:DISCONNECTED];
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"Cool, I'm connected! That was easy.");
    [self setState:CONNECTED];
    // start auth
    pb::CAuth auth;
    auth.set_username([_username UTF8String]);
    auth.set_password([_password UTF8String]);
    std::string ps = auth.SerializeAsString();

    [self send:pb::C_AUTH Message:&auth];
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
        [sock readDataToLength:HEADER_LENGTH withTimeout:-1 tag:TAG_FIXED_LENGTH_HEADER];
    }
}

#pragma mark -
#pragma mark Payload parsing

-(int) parseHeader:(NSData *)data {
    const struct Header* header = (const struct Header*)[data bytes];
    
    _code = (pb::Code) header->code;
    return (int) header->length;
}

-(void)handleResponseBody:(NSData *)data {
    int length = (int)[data length];
    char raw[length];
    [data getBytes:raw length:length];
    if (_code == pb::E_AUTH) {
        pb::EAuth auth;
        auth.ParseFromArray(raw, length);
        if (auth.code() == 0) {
            NSLog(@"Auth OK: userId=%lld", auth.userid());
            _playerId = auth.userid();
            if ([_delegate respondsToSelector:@selector(authComplete:UserId:)]) {
                [_delegate authComplete:YES UserId:auth.userid()];
            }
            
            [self setState:READY];
        } else {
            if ([_delegate respondsToSelector:@selector(authComplete:UserId:)]) {
                [_delegate authComplete:NO UserId:0];
            }
        }
    } else if (_code == pb::E_MATCH_INIT) {
        pb::EMatcInit matchInit;
        matchInit.ParseFromArray(raw, length);
        NSMutableArray *players = [[NSMutableArray alloc] init];
        NSMutableArray *points = [[NSMutableArray alloc] init];
        for (int i=0; i<matchInit.players_size(); i++) {
            pb::Player pbPlayer = matchInit.players(i);
            Player *player = [[Player alloc] init];
            player.playerId = pbPlayer.id();
            player.nickName = [NSString stringWithUTF8String:pbPlayer.nickname().c_str()];
            player.avatar = [NSString stringWithUTF8String:pbPlayer.avatar().c_str()];
            player.isLeft = pbPlayer.isleft();
            player.position = CGPointMake(pbPlayer.position().x(), pbPlayer.position().y());
            player.health = pbPlayer.health();
            [players addObject:player];
        }
        
        for (int i=0; i<matchInit.points_size(); i++) {
            pb::Point pbPoint = matchInit.points(i);
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(pbPoint.x(), pbPoint.y())]];
        }
        _matchId = matchInit.matchid();
        
        if ([_delegate respondsToSelector:@selector(matchInit:KeyPoints:)]) {
            [_delegate matchInit:players KeyPoints:points];
        }
    } else if (_code == pb::E_MATCH_TURN) {
        pb::EMatchTurn turn;
        turn.ParseFromArray(raw, length);
        if ([_delegate respondsToSelector:@selector(matchTurn:)]) {
            [_delegate matchTurn:turn.playerid()];
        }
    } else if (_code == pb::E_MATCH_END) {
        pb::EMatchEnd end;
        end.ParseFromArray(raw, length);
        if ([_delegate respondsToSelector:@selector(matchEnd:)]) {
            [_delegate matchEnd:end.points()];
        }
    } else if (_code == pb::E_PLAYER_MOVE) {
        pb::EPlayerMove move;
        move.ParseFromArray(raw, length);
        if (move.playerid() != _playerId && [_delegate respondsToSelector:@selector(playerMove:position:)]) {
            [_delegate playerMove:move.playerid() position:CGPointMake(move.position().x(), move.position().y())];
        }
    } else if (_code == pb::E_PLAYER_FIRE) {
        pb::EPlayerFire fire;
        fire.ParseFromArray(raw, length);
        if (fire.playerid() != _playerId && [_delegate respondsToSelector:@selector(playerFire:position:velocity:)]) {
            [_delegate playerFire:fire.playerid() position:CGPointMake(fire.position().x(), fire.position().y()) velocity:CGVectorMake(fire.velocity().x(), fire.velocity().y())];
        }
    } else if (_code == pb::E_PLAYER_HIT) {
        pb::EPlayerHit hit;
        hit.ParseFromArray(raw, length);
        // hit.p1() != _playerId && 
        if ([_delegate respondsToSelector:@selector(playerHit:p2:damage:)]) {
            [_delegate playerHit:hit.p1() p2:hit.p2() damage:hit.damage()];
        }
    }
    
}


@end
