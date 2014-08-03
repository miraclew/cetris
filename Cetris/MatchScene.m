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
    SKSpriteNode* _moveLeft;
    SKSpriteNode* _moveRight;
    SKSpriteNode* _angleLeft;
    SKSpriteNode* _angleRight;
    SKSpriteNode* _fireButton;
    SKLabelNode* _exitButton;
    
    CGFloat _angle;
    int _move;
    CGFloat _power;
    Terrain* terrain;
    // Sounds
    SKAction *fireSound;
    SKAction *explosionSound;
    SKAction *gameOverSound;
    SKAction *changeAngleSound;
    int64_t _prevTurnPlayer;
}

-(instancetype)initWithSize:(CGSize)size Game:(Game*)game {
    if (self == [super initWithSize:size]) {
        _game = game;
        _prevTurnPlayer = 0;
        _move = 0;
        _power = 0.0f;
        _playerNodes = [[NSMutableDictionary alloc] init];
        self.backgroundColor = [SKColor grayColor];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        _fireControl = [FireControl controlWithRadius:120 FireBlock:^(id object) {
//            NSLog(@"fire blockvvv                                                                                           ");
            FireControl *fc = (FireControl *) object;
            CGPoint position = CGPointMake(_myComponnets.Car.position.x, _myComponnets.Car.position.y +15);
            [self fireMissile:position Velocity:fc.controlVector];
            [_myComponnets.Car takeTurn:NO];
        } VectorChangeBlock:^(id object) {
            
        }];
        _fireControl.position = CGPointMake(120, 120);
        _fireControl.zPosition = 100;
        
//        [self addControls];
        
        fireSound = [SKAction playSoundFileNamed:@"box.wav" waitForCompletion:NO];
        explosionSound = [SKAction playSoundFileNamed:@"nitro.wav" waitForCompletion:NO];
        gameOverSound = [SKAction playSoundFileNamed:@"win.wav" waitForCompletion:NO];
        changeAngleSound = [SKAction playSoundFileNamed:@"10.wav" waitForCompletion:NO];
        self.physicsWorld.contactDelegate = self;
    }
    
    return self;
}

-(void)addControls{
    _moveLeft = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(40, 30)];
    _moveLeft.name = @"MoveLeft";
    _moveLeft.position = CGPointMake(200, 30);
    [self addChild:_moveLeft];
    _moveRight = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(40, 30)];
    _moveRight.name = @"MoveRight";
    _moveRight.position = CGPointMake(245, 30);
    [self addChild:_moveRight];
    
    _angleLeft = [SKSpriteNode spriteNodeWithColor:[SKColor purpleColor] size:CGSizeMake(40, 30)];
    _angleLeft.name = @"AngleLeft";
    _angleLeft.position = CGPointMake(200, 80);
    [self addChild:_angleLeft];
    
    _angleRight = [SKSpriteNode spriteNodeWithColor:[SKColor purpleColor] size:CGSizeMake(40,30)];
    _angleRight.name = @"AngleRight";
    _angleRight.position = CGPointMake(245, 80);
    [self addChild:_angleRight];
    
    _fireButton = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(60, 60)];
    _fireButton.name = @"FireButton";
    _fireButton.position = CGPointMake(320, 60);
    [self addChild:_fireButton];
    
    _exitButton = [SKLabelNode labelNodeWithFontNamed:@"System"];
    _exitButton.name = @"ExitButton";
    _exitButton.position = CGPointMake(30, 20);
    _exitButton.text = @"退出";
    [self addChild:_exitButton];
}

-(Car*)addPlayerNode:(Player*) player {
    Car* node = [Car carWithId:player.playerId IsLeft:player.isLeft IsMe:player.playerId == _game.playerId];
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
    
    PlayerHud* hud = [[PlayerHud alloc] initWithPlayer:player IsMe:player.playerId == _game.playerId];
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
    [_game.client fire:velocity.dx y:velocity.dy];
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

-(void)movePositionWithX:(CGFloat)deltaX {
//    if (deltaX > 0) {
//        
//        [_myComponnets.Car.physicsBody applyImpulse:CGVectorMake(2, 0)];
//    } else {
//    }
    
//    [_myComponnets.Car runAction:[SKAction moveToX:deltaX duration:1] completion:^{
//        CGPoint pos = _myComponnets.Car.position;
//        [self playerMove:_game.playerId position:pos];
//    }];
}

-(void)changeAngle:(CGFloat)angle {
    _myComponnets.Car.towerRotation += angle;
    [self runAction:changeAngleSound];
}

#pragma mark -
#pragma mark collide event

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

#pragma mark -
#pragma mark touch event

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    NSLog(@"TouchedBegin: %@", node.name);
    if ([node.name isEqualToString:@"MoveLeft"]) {
        _move = -1;
        [self movePositionWithX:-50.0];
    } else if ([node.name isEqualToString:@"MoveRight"]) {
        [self movePositionWithX:50.0];
        _move = 1;
    } else if ([node.name isEqualToString:@"AngleLeft"]) {
        [self changeAngle:0.1];
    } else if ([node.name isEqualToString:@"AngleRight"]) {
        [self changeAngle:-0.1];
    } else if ([node.name isEqualToString:@"FireButton"]) {
        if(_prevTurnPlayer == _game.playerId) {
            CGPoint position = CGPointMake(_myComponnets.Car.position.x, _myComponnets.Car.position.y +25);
            CGFloat power = 1;
            CGFloat x = cosf(_myComponnets.Car.towerRotation) * power;
            CGFloat y = sinf(_myComponnets.Car.towerRotation) * power;
            [self fireMissile:position Velocity:CGVectorMake(x, y)];
        }
    } else if ([node.name isEqualToString:@"ExitButton"]) {
        [_game.client exit];
        [_game matchFinish];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    _move = 0;
//    NSLog(@"MatchScene.touchesEnded");
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
    terrain.zPosition = -1;
    [self addChild:terrain];
    
//    [self addChild:_fireControl];
    _angle = _myComponnets.Player.isLeft ? 45 : 135;
    [self addControls];
}

-(void)matchEnd:(int) points {
    [self gameOver];
}

-(void)matchTurn:(int64_t)playerId {
    if (_prevTurnPlayer != 0) {
        Car* car = [self getPlayerNode:_prevTurnPlayer].Car;
        car.zRotation = 0;
        [car takeTurn:NO];
    }
    
    NSLog(@"matchTurn: %lld", playerId);
    Car* car = [self getPlayerNode:playerId].Car;
    [car takeTurn:YES];
    _prevTurnPlayer = playerId;
    
//    _myComponnets.Car.zRotation = 0.0;
}

-(void)playerMove:(int64_t)playerId position:(CGPoint)position{
    Car* car = [self getPlayerNode:playerId].Car;
    [car runAction:[SKAction moveToX:[self translatePoint:position].x duration:1]];
}

-(void)playerFire:(int64_t)playerId velocity:(CGVector)velocity{
    Car* car = [self getPlayerNode:playerId].Car;
    CGPoint position = CGPointMake(car.position.x, car.position.y +15);
//    if (!car.isLeft) {
//        velocity.dx = - velocity.dx;
//    }
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


-(void)update:(NSTimeInterval)currentTime {
    
    CGFloat rotation = _myComponnets.Car.zRotation + M_PI_2;
    CGFloat thrust = 10;
    CGVector thrustVector = CGVectorMake(thrust*cosf(rotation),
                                         thrust*sinf(rotation));
    if (_move > 0) {
//        _myComponnets.Car.physicsBody.friction = 0.1f;
        NSLog(@"moveRight: %f/%f", thrustVector.dx, thrustVector.dy);
        
//        [_myComponnets.Car.physicsBody applyForce:thrustVector];
        [_myComponnets.Car.physicsBody applyForce:CGVectorMake(20, 0)];
    } else if(_move < 0) {
//        _myComponnets.Car.physicsBody.friction = 0.1f;
        CGVector thrustVector = CGVectorMake(-thrust*cosf(rotation),
                                             thrust*sinf(rotation));
        NSLog(@"moveLeft: %f/%f", thrustVector.dx, thrustVector.dy);
//        [_myComponnets.Car.physicsBody applyForce:thrustVector];
        [_myComponnets.Car.physicsBody applyForce:CGVectorMake(-20, 0)];
    } else {
//        _myComponnets.Car.physicsBody.friction = 1.0f;
    }
}

@end
