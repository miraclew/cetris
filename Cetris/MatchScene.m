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
#import "ProgressBar.h"
#import "Tank.h"

static const uint32_t PLAYER_CATEGORY = 0x1 << 0;
static const uint32_t HILL_CATEGORY = 0x1 << 1;
static const uint32_t BLOCK_CATEGORY = 0x1 << 2;
static const uint32_t BULLET_CATEGORY = 0x1 << 3;

@interface PlayerComponents : NSObject
@property (nonatomic, strong) PlayerHud* Hud;
@property (nonatomic, strong) Tank* Tank;
@property (nonatomic, strong) Player* Player;
@end

@implementation PlayerComponents

@end

@implementation MatchScene {
    Game* _game;
    NSMutableDictionary* _playerNodes;
    
    SKShapeNode *_missileCurve;
    PlayerComponents* _myComponnets;
    ProgressBar* _powerBar;
    // Buttons
    SKSpriteNode* _moveLeft;
    SKSpriteNode* _moveRight;
    SKSpriteNode* _angleLeft;
    SKSpriteNode* _angleRight;
    SKSpriteNode* _fireButton;
    SKLabelNode* _exitButton;
    
    BOOL _fireButtonTouched;
    
    CGFloat _angle;
    int _move;
    CGFloat _powerStep;
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
        _powerStep = 0.01f;
        _fireButtonTouched = NO;
        _playerNodes = [[NSMutableDictionary alloc] init];
        self.backgroundColor = [SKColor grayColor];
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
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
    _fireButton.position = CGPointMake(320, 50);
    [self addChild:_fireButton];
    
    _powerBar = [[ProgressBar alloc] initWithColor:[UIColor blueColor] size:CGSizeMake(100, 10)];
    _powerBar.position = CGPointMake(320, 100);
    _powerBar.percent = _powerStep;
    [self addChild:_powerBar];

    _exitButton = [SKLabelNode labelNodeWithFontNamed:@"System"];
    _exitButton.name = @"ExitButton";
    _exitButton.position = CGPointMake(30, 20);
    _exitButton.text = @"退出";
    [self addChild:_exitButton];
    
}

-(Tank*)addPlayerNode:(Player*) player {
    Tank* node = [[Tank alloc] initWithPosition:CGPointMake([self translatePoint:player.position revert:NO].x, self.size.height-100)];
    node.collisionBitmask = PLAYER_CATEGORY;
    node.name = [NSString stringWithFormat:@"%lld", player.playerId];
    node.physicsBody.categoryBitMask = PLAYER_CATEGORY;
    node.physicsBody.restitution = 0.0;

    [self addChild:node];
    for (SKPhysicsJoint* joint in node.joints) {
        [self.physicsWorld addJoint:joint];
    }

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

-(CGPoint)translatePoint:(CGPoint)point revert:(BOOL)revert {
    if (revert) {
        return CGPointMake(point.x / self.size.width, point.y / self.size.height);
    } else
        return CGPointMake(point.x * self.size.width, point.y * self.size.height);
}

-(void)fireMissile:(CGPoint) position Velocity:(CGVector) velocity{
    //NSLog(@"fireMissle pos:%f/%f velocity: %f/%f", position.x, position.y, velocity.dx, velocity.dy);
    CGFloat yOffset = 80.0;
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(10, 10)];
    bullet.name = @"Bullet";
    bullet.position = CGPointMake(position.x, position.y +yOffset);
    [bullet addChild:[self newMissileNode] ];
    [self addChild:bullet];
    
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
    bullet.physicsBody.categoryBitMask = BULLET_CATEGORY;
    bullet.physicsBody.contactTestBitMask = HILL_CATEGORY | BLOCK_CATEGORY | PLAYER_CATEGORY;
    [bullet runAction:fireSound];
    CGFloat factor = 1000;
    bullet.physicsBody.mass = 0.1;
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

-(void)gameOver:(CGFloat)points {
    SKLabelNode *backMenu = [SKLabelNode labelNodeWithFontNamed:@"System"];
    backMenu.name = @"BackButton";
    backMenu.fontColor = [SKColor whiteColor];
    backMenu.text = [NSString stringWithFormat:@"你%@ 得分 %d 返回", points>0?@"赢了":@"输了", (int)points];
    backMenu.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:backMenu];
    
    [self runAction:gameOverSound];
}

-(void)changeAngle:(CGFloat)angle {
    _angle += angle;
    _myComponnets.Tank.towerRotation = _angle;
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
        }
        
        //
        if (p2 == _game.playerId) {
            NSLog(@"Hit: p1 %lld -> p2 %lld", p1, p2);
            [_game.client hit:p1 p2:p2 damage:20.0];
        }
        
        [self explodeAtPoint:contact.contactPoint];
        [secondBody.node runAction:[SKAction removeFromParent]];
    }
}

-(BOOL)isMyTurn {
//    return _prevTurnPlayer == _game.playerId;
    return YES;
}

#pragma mark -
#pragma mark touch event

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    NSLog(@"TouchedBegin: %@", node.name);
    if ([node.name isEqualToString:@"MoveLeft"]) {
        if([self isMyTurn]) {
            _move = -1;
        }
    } else if ([node.name isEqualToString:@"MoveRight"]) {
        if([self isMyTurn]) {
            _move = 1;
        }
    } else if ([node.name isEqualToString:@"AngleLeft"]) {
        [self changeAngle:1];
    } else if ([node.name isEqualToString:@"AngleRight"]) {
        [self changeAngle:-1];
    } else if ([node.name isEqualToString:@"FireButton"]) {
        if([self isMyTurn]) {
            _fireButtonTouched = YES;
        }
    } else if ([node.name isEqualToString:@"ExitButton"]) {
        [_game.client exit];
        [_game matchFinish];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    _move = 0;
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    
    if ([node.name isEqualToString:@"BackButton"]) {
        SKAction *buttonClick = [SKAction playSoundFileNamed:@"pushbtn.wav" waitForCompletion:NO];
        [self runAction:buttonClick];
        
        if (_game.state == GS_OVER) {
            [_game matchFinish];
        }
    } else if ([node.name isEqualToString:@"FireButton"] && _fireButtonTouched) {
        _fireButtonTouched = NO;
        CGFloat power = _powerBar.percent + 0.1;
        CGFloat x = cosf(_myComponnets.Tank.towerRotation) * power * 1.5;
        CGFloat y = sinf(_myComponnets.Tank.towerRotation) * power * 1.5;
        CGVector velocity = CGVectorMake(x, y);
        
        [self fireMissile:_myComponnets.Tank.position Velocity:velocity];
        [_game.client fire:[self translatePoint:_myComponnets.Tank.position revert:YES] velocity:velocity];
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
        pc.Tank = [self addPlayerNode:p];
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
    terrain.physicsBody.friction = 0.8;
    [self addChild:terrain];
    
    _angle = _myComponnets.Player.isLeft ? M_PI_4 : M_PI_4*3;
    [self addControls];
}

-(void)matchEnd:(int) points {
    [self gameOver:points];
}

-(void)matchTurn:(int64_t)playerId {
    if (_prevTurnPlayer != 0) {
        Tank* car = [self getPlayerNode:_prevTurnPlayer].Tank;
        car.zRotation = 0;
        [car takeTurn:NO];
    }
    
    NSLog(@"matchTurn: %lld", playerId);
    Tank* car = [self getPlayerNode:playerId].Tank;
    [car takeTurn:YES];
    _prevTurnPlayer = playerId;
}

-(void)playerMove:(int64_t)playerId position:(CGPoint)position{
    Tank* car = [self getPlayerNode:playerId].Tank;
    car.position = [self translatePoint:position revert:NO];
}

-(void)playerFire:(int64_t)playerId position:(CGPoint)position velocity:(CGVector)velocity{
    Tank* car = [self getPlayerNode:playerId].Tank;
    car.position = [self translatePoint:position revert:NO];
    
    [car takeTurn:NO];
    [self fireMissile:car.position Velocity:velocity];
}

-(void)playerHit:(int64_t)p1 p2:(int64_t)p2 damage:(int)damage{
    PlayerComponents* pc = [self getPlayerNode:p2];
    PlayerHud* hud = pc.Hud;
    hud.Health = pc.Player.health;
}

-(void)playerHealth:(int64_t)playerId health:(int)health{
    
}


-(void)update:(NSTimeInterval)currentTime {
    if (_myComponnets.Tank.zRotation > M_PI_2 || _myComponnets.Tank.zRotation < 0) {
        _myComponnets.Tank.zRotation = 0;
    }
    
    if (_move > 0) {
        [_myComponnets.Tank move:YES];
    } else if(_move < 0) {
        [_myComponnets.Tank move:NO];
    } else {
    }
    
    if (_fireButtonTouched) {
        if (_powerBar.percent >= 1.0) {
            _powerStep = -0.01;
        }
        if (_powerBar.percent <= 0) {
            _powerStep = 0.01;
        }
        
        _powerBar.percent += _powerStep;
    }
}

@end
