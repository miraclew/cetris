//
//  MatchScene.m
//  Cetris
//
//  Created by Wan Wei on 14/7/26.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "MatchScene.h"
#import "PlayerHud.h"
#import "Car.h"
#import "Terrain.h"

static const uint32_t PLAYER_CATEGORY = 0x1 << 0;
static const uint32_t HILL_CATEGORY = 0x1 << 1;
static const uint32_t BLOCK_CATEGORY = 0x1 << 2;
static const uint32_t BULLET_CATEGORY = 0x1 << 3;

@interface PlayerComponents : NSObject
@property (nonatomic, strong) PlayerHud* Hud;
@property (nonatomic, strong) Car* Car;
@property (nonatomic, strong) Player* Player;
@end

@implementation PlayerComponents

@end

@implementation MatchScene {
    Game* _game;
    NSMutableDictionary* _playerNodes;
    
    Terrain* terrain;
}

-(instancetype)initWithSize:(CGSize)size Game:(Game*)game {
    if (self == [super initWithSize:size]) {
        _game = game;
        _playerNodes = [[NSMutableDictionary alloc] init];
        self.backgroundColor = [SKColor grayColor];
    }
    
    return self;
}


-(Car*)addPlayerNode:(Player*) player {
    Car* node = [Car carWithId:player.playerId IsLeft:player.isLeft];
    node.name = [NSString stringWithFormat:@"%lld", player.playerId];
    node.position = CGPointMake([self translatePoint:player.position].x, self.size.height-100);
    node.physicsBody.categoryBitMask = PLAYER_CATEGORY;
    node.physicsBody.restitution = 0.0;

    [self addChild:node];
    return node;
}

-(PlayerHud*)addHudNode:(Player*) player {
    int HUD_PADDING = 80;
    
    PlayerHud* hud = [[PlayerHud alloc] initWithPlayer:player];
    if (player.isLeft) {
        hud.position = CGPointMake(HUD_PADDING, self.size.height-HUD_PADDING-hud.size.height);
    } else {
        hud.position = CGPointMake(self.size.width - HUD_PADDING - 100, self.size.height - HUD_PADDING-hud.size.height);
    }
    
    [self addChild:hud];
    return hud;
}

-(CGPoint)translatePoint:(CGPoint)point {
    return CGPointMake(point.x * self.size.width, point.y * self.size.height);
}

-(void)fireMissile:(CGPoint) position Velocity:(CGVector) velocity{
    NSLog(@"fireMissle pos:%f/%f velocity: %f/%f", position.x, position.y, velocity.dx, velocity.dy);
    
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(10, 10)];
    bullet.name = @"Bullet";
    bullet.position = position;
    [bullet addChild:[self newMissileNode] ];
    [self addChild:bullet];
    
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
//    bullet.physicsBody.categoryBitMask = bulletCategory;
//    bullet.physicsBody.contactTestBitMask = bottomCategory | blockCategory | boxCategory;
    //    [bullet runAction:fireSound];
    CGFloat factor = 1000;
    bullet.physicsBody.velocity = CGVectorMake(velocity.dx * factor, velocity.dy * factor);
}

-(SKNode *)newMissileNode {
    SKEmitterNode *missile = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"missile" ofType:@"sks"]];
    missile.targetNode     = self;
    missile.name           = @"missle";
    
    return missile;
}

- (SKEmitterNode*) newExplosionNode: (CFTimeInterval) explosionDuration {
    SKEmitterNode *explosion     = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"sks"]];
    explosion.targetNode         = self;
    explosion.numParticlesToEmit = explosionDuration * explosion.particleBirthRate;
    CFTimeInterval totalTime     = explosionDuration + explosion.particleLifetime+explosion.particleLifetimeRange/2;
    [explosion runAction:[SKAction sequence:@[[SKAction waitForDuration:totalTime], [SKAction removeFromParent]]]];
    return explosion;
}

-(void)explodeAtPoint:(CGPoint)point {
    SKEmitterNode *explosion = [self newExplosionNode:0.1f];
    explosion.position       = point;
    [self addChild:explosion];
}

-(PlayerComponents *)getPlayerNode:(int64_t)playerId {
    return [_playerNodes objectForKey:@(playerId)];
}

#pragma mark -
#pragma mark ClientDelegate

-(void)didConnected {
}

-(void)didLostConnection:(NSError *)error {
}

-(void)didConnectError:(NSError *)error {
}

-(void)didStateChange:(ClientState)state {
}

-(void)matchInit:(NSArray *)players KeyPoints:(NSArray *)points {
    for (Player* p in players) {
        PlayerComponents * pc = [[PlayerComponents alloc] init];
        pc.Car = [self addPlayerNode:p];
        pc.Hud = [self addHudNode:p];
        pc.Player = p;
        [_playerNodes setObject:pc forKey:@(p.playerId)];
    }
    
    terrain = [[Terrain alloc] initWithSize:self.size Points:points];
    terrain.physicsBody.categoryBitMask = HILL_CATEGORY;
    terrain.name = @"Buttom";
    [self addChild:terrain];
}

-(void)matchEnd:(int) points {
    
}

-(void)matchTurn:(int64_t)playerId {
    
}

-(void)playerMove:(int64_t)playerId position:(CGPoint)position{
    
}

-(void)playerFire:(int64_t)playerId velocity:(CGVector)velocity{
    Car* car = [self getPlayerNode:playerId].Car;
    CGPoint position = CGPointMake(car.position.x, car.position.y +15);
    [self fireMissile:position Velocity:velocity];
}

-(void)playerHit:(int64_t)p1 p2:(int64_t)p2 damage:(int)damage{
    PlayerComponents* pc = [self getPlayerNode:p2];
    PlayerHud* hud = pc.Hud;
    hud.Health = pc.Player.health;
}

-(void)playerHealth:(int64_t)playerId health:(int)health{
    
}



@end
