//
//  MatchScene.m
//  Cetris
//
//  Created by Wan Wei on 14/7/26.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "MatchScene.h"
#import "PlayerHud.h"
#import "Terrain.h"
#import "FireControl.h"

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
    
    SKShapeNode *_missileCurve;
    FireControl *_fireControl;
    PlayerComponents* _myComponnets;

    Terrain* terrain;
    // Sounds
    SKAction *fireSound;
    SKAction *explosionSound;
    SKAction *gameOverSound;
    int64_t _prevTurnPlayer;
}

-(instancetype)initWithSize:(CGSize)size Game:(Game*)game {
    if (self == [super initWithSize:size]) {
        _game = game;
        _prevTurnPlayer = 0;
        _playerNodes = [[NSMutableDictionary alloc] init];
        self.backgroundColor = [SKColor grayColor];
        
        _fireControl = [FireControl controlWithRadius:120 FireBlock:^(id object) {
//            NSLog(@"fire block");
            FireControl *fc = (FireControl *) object;
            CGPoint position = CGPointMake(_myComponnets.Car.position.x, _myComponnets.Car.position.y +15);
            [self fireMissile:position Velocity:fc.controlVector];
            [_myComponnets.Car takeTurn:NO];
        } VectorChangeBlock:^(id object) {
            
        }];
        _fireControl.position = CGPointMake(120, 120);
        [self addChild:_fireControl];
        
        fireSound = [SKAction playSoundFileNamed:@"box.wav" waitForCompletion:NO];
        explosionSound = [SKAction playSoundFileNamed:@"nitro.wav" waitForCompletion:NO];
        gameOverSound = [SKAction playSoundFileNamed:@"win.wav" waitForCompletion:NO];

        self.physicsWorld.contactDelegate = self;
    }
    
    return self;
}

-(Car*)addPlayerNode:(Player*) player {
    Car* node = [Car carWithId:player.playerId IsLeft:player.isLeft];
    node.name = [NSString stringWithFormat:@"%lld", player.playerId];
    node.position = CGPointMake([self translatePoint:player.position].x, self.size.height-100);
    node.physicsBody.categoryBitMask = PLAYER_CATEGORY;
    node.physicsBody.restitution = 0.0;
    node.delegate = self;

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
    //NSLog(@"fireMissle pos:%f/%f velocity: %f/%f", position.x, position.y, velocity.dx, velocity.dy);
    
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(10, 10)];
    bullet.name = @"Bullet";
    bullet.position = position;
    [bullet addChild:[self newMissileNode] ];
    [self addChild:bullet];
    
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
    bullet.physicsBody.categoryBitMask = BULLET_CATEGORY;
    bullet.physicsBody.contactTestBitMask = HILL_CATEGORY | BLOCK_CATEGORY | PLAYER_CATEGORY;
    [bullet runAction:fireSound];
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

-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    NSLog(@"%@ <-> %@", contact.bodyA.node.name, contact.bodyB.node.name);
    int64_t p1 = _prevTurnPlayer;
    int64_t p2 = 0;
    if ((secondBody.categoryBitMask & BULLET_CATEGORY) != 0)
    {
        if ((firstBody.categoryBitMask & PLAYER_CATEGORY) != 0) {
            if ([firstBody.node.name isEqualToString:@"PlayerA"]) {
            } else {
            }
            
            p2 = [firstBody.node.name intValue];
//            NSLog(@"attack %@", firstBody.node.name);
        }
        
        //
        if (p2 == _game.playerId || p1 >= 5) {
            
        }
        NSLog(@"p1 %lld -> p2 %lld", p1, p2);
        [_game.client hit:p1 p2:p2 damage:20.0];
        
        [self explodeAtPoint:contact.contactPoint];
        [secondBody.node runAction:[SKAction removeFromParent]];
    }
}

-(void)gameOver {
//    SKSpriteNode *winnerNode;
//    SKSpriteNode *loserNode;
//    
//    [loserNode removeFromParent];
//    [winnerNode runAction:[SKAction moveToX:self.size.width/2 duration:1]];
    
    SKLabelNode *backMenu = [SKLabelNode labelNodeWithFontNamed:@"System"];
    backMenu.name = @"BackButton";
    backMenu.fontColor = [SKColor whiteColor];
    backMenu.text = @"返回";
    backMenu.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:backMenu];
    
    [self runAction:gameOverSound];
}

#pragma mark -
#pragma mark touch event

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"MatchScene.touchesEnded");
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    
    if ([node.name isEqualToString:@"BackButton"]) {
        SKAction *buttonClick = [SKAction playSoundFileNamed:@"pushbtn.wav" waitForCompletion:NO];
        [self runAction:buttonClick];
        
        if (_game.state == GS_OVER) {
            [_game matchFinish];
        }
    }
}

#pragma mark -
#pragma mark CarDelegate

-(void)didPositionChanged:(SKSpriteNode *)car Position:(CGPoint)position {
//    int64_t playerId = [car.name intValue];
    [_game.client move:position.x y:position.y];
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
        if (p.playerId == _game.playerId) {
            _myComponnets = pc;
        }
    }
    
    terrain = [[Terrain alloc] initWithSize:self.size Points:points];
    terrain.physicsBody.categoryBitMask = HILL_CATEGORY;
    terrain.name = @"Buttom";
    [self addChild:terrain];
}

-(void)matchEnd:(int) points {
    [self gameOver];
}

-(void)matchTurn:(int64_t)playerId {
    if (_prevTurnPlayer != 0) {
        Car* car = [self getPlayerNode:_prevTurnPlayer].Car;
        [car takeTurn:NO];
    }
    
    NSLog(@"matchTurn: %lld", playerId);
    Car* car = [self getPlayerNode:playerId].Car;
    [car takeTurn:YES];
    _prevTurnPlayer = playerId;
}

-(void)playerMove:(int64_t)playerId position:(CGPoint)position{
    Car* car = [self getPlayerNode:playerId].Car;
    [car runAction:[SKAction moveToX:[self translatePoint:position].x duration:1]];
}

-(void)playerFire:(int64_t)playerId velocity:(CGVector)velocity{
    Car* car = [self getPlayerNode:playerId].Car;
    CGPoint position = CGPointMake(car.position.x, car.position.y +15);
    if (!car.isLeft) {
        velocity.dx = - velocity.dx;
    }
    [car takeTurn:NO];
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
