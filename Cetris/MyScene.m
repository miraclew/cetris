//
//  MyScene.m
//  Cetriso.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"
#import "Terrain.h"

#define NA_ENEMY_LABEL   @"enemy"
#define NA_MISSILE_LABEL @"missile"
#define NA_TARGET_KEY    @"target"

static const uint32_t boxCategory = 0x1 << 0;
static const uint32_t bottomCategory = 0x1 << 1;
static const uint32_t blockCategory = 0x1 << 2;
static const uint32_t bulletCategory = 0x1 << 3;

typedef enum : NSUInteger {
    None,
    A,
    B,
} Player;

typedef enum : NSUInteger {
    NONE,
    DIRECTION,
    LUANCH,
} ControlMode;

@interface MyScene() {
    CGPoint _controlOrigin;
    ControlMode _mode;
    SKNode *_draggedNode;
}

@property SKSpriteNode *control;
@property SKSpriteNode *pointer;

@end

@implementation MyScene {
    SKSpriteNode *boxA;
    SKSpriteNode *boxB;
    SKLabelNode *healthLabelA;
    SKLabelNode *healthLabelB;
    SKNode *hud;
    int healthA;
    int healthB;
    Player turn;
    Player winner;
    SKLabelNode *topCenterLabel;
    BOOL isGameOver;
    
    // Sounds
    SKAction *fireSound;
    SKAction *explosionSound;
    SKAction *gameOverSound;
    
    // Terrain
    Terrain *terrain;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        [self initBase];
        
        terrain = [[Terrain alloc] initWithSize:size];
        terrain.physicsBody.categoryBitMask = bottomCategory;
        terrain.name = @"Buttom";
        [self addChild:terrain];
        
        [self addPlayers];
        self.physicsWorld.contactDelegate = self;
        
        [self addHud];
        
        [self addControl];
    }
    return self;
}

-(void)addControl{
    _controlOrigin = CGPointMake(60, 60);
    _control = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(20, 20)];
    _control.name = @"Control";
    _control.position = _controlOrigin;
    [self addChild:_control];
    
    _pointer = [SKSpriteNode spriteNodeWithColor:[UIColor purpleColor] size:CGSizeMake(10, 10)];
    [_pointer setHidden:YES];
    [self addChild:_pointer];
}

-(void)initBase{
    healthA = 100;
    healthB = 100;
    turn = A;
    isGameOver = NO;
    winner = None;
    fireSound = [SKAction playSoundFileNamed:@"box.wav" waitForCompletion:NO];
    explosionSound = [SKAction playSoundFileNamed:@"nitro.wav" waitForCompletion:NO];
    gameOverSound = [SKAction playSoundFileNamed:@"win.wav" waitForCompletion:NO];
    self.backgroundColor = [SKColor grayColor];
}

-(void)addHud {
    hud = [SKNode node];
    int padding = 20;
    healthLabelA = [SKLabelNode labelNodeWithFontNamed:@"System"];
    healthLabelA.fontColor = [SKColor whiteColor];
    healthLabelA.fontSize = 20.0f;
    healthLabelA.position = CGPointMake(padding + 20, self.size.height-padding);
    [self addChild:healthLabelA];
    healthLabelB = [SKLabelNode labelNodeWithFontNamed:@"System"];
    healthLabelB.position = CGPointMake(self.size.width - padding - 20, self.size.height - padding);
    healthLabelB.fontSize = 20.0f;
    healthLabelB.fontColor = [SKColor whiteColor];
    [self addChild:healthLabelB];
    
    topCenterLabel = [SKLabelNode labelNodeWithFontNamed:@"System"];
    topCenterLabel.fontSize = 20.0f;
    topCenterLabel.fontColor = [SKColor whiteColor];
    topCenterLabel.position = CGPointMake(self.size.width/2, self.size.height -padding);
    [self addChild:topCenterLabel];
    
    SKLabelNode *backNode = [SKLabelNode labelNodeWithFontNamed:@"System"];
    backNode.text = @"返回";
    backNode.fontSize = 20.0f;
    backNode.name = @"BackButton";
    backNode.position = CGPointMake(self.size.width - 50, 20);
    [self addChild:backNode];
}

-(void)addPlayers {
    CGSize boxSize = CGSizeMake(20, 10);
    
    boxA = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:boxSize];
    boxA.name = @"BoxA";
    boxA.position = CGPointMake(15 + self.size.width/4, self.size.height);
    [self addChild:boxA];
    boxA.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:boxSize];
    boxA.physicsBody.categoryBitMask = boxCategory;
    
    boxB = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:boxSize];
    boxB.name = @"BoxB";
    boxB.position = CGPointMake(15 + self.size.width*3/4, self.size.height);
    boxB.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:boxSize];
    boxB.physicsBody.categoryBitMask = boxCategory;
    boxB.userData = [NSMutableDictionary dictionary];
    [self addChild:boxB];
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    NSLog(@"%@ <-> %@", contact.bodyA.node.name, contact.bodyB.node.name);
    if ((secondBody.categoryBitMask & bulletCategory) != 0)
    {
        if ((firstBody.categoryBitMask & boxCategory) != 0) {
            if ([firstBody.node.name isEqualToString:@"BoxA"]) {
                healthA -= 20;
                if (healthA <= 0) {
                    healthA = 0;
                    winner = B;
                    [self gameOver];
                }
            } else {
                healthB -= 20;
                if (healthB <= 0) {
                    healthB = 0;
                    winner = A;
                    [self gameOver];
                }
            }
            
            NSLog(@"attack %@", firstBody.node.name);
        }
        [self explodeAtPoint:contact.contactPoint];

        [secondBody.node runAction:[SKAction removeFromParent]];
    }
}

-(void)gameOver {
    isGameOver = YES;
    
    SKSpriteNode *winnerNode;
    SKSpriteNode *loserNode;
    if (winner == A) {
        winnerNode = boxA;
        loserNode = boxB;
    } else {
        winnerNode = boxB;
        loserNode = boxA;
    }
    
    [loserNode removeFromParent];
    [winnerNode runAction:[SKAction moveToX:self.size.width/2 duration:1]];
    
    SKLabelNode *backMenu = [SKLabelNode labelNodeWithFontNamed:@"System"];
    backMenu.name = @"BackButton";
    backMenu.fontColor = [SKColor whiteColor];
    backMenu.text = @"返回";
    backMenu.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:backMenu];
    
    [self runAction:gameOverSound];
}

-(SKNode *)newMissileNode {
    SKEmitterNode *missile = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"missile" ofType:@"sks"]];
    missile.targetNode     = self;
    missile.name           = NA_MISSILE_LABEL;
    
    return missile;
}

- (SKEmitterNode*) newExplosionNode: (CFTimeInterval) explosionDuration {
    SKEmitterNode *explosion     = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"sks"]];
    explosion.targetNode         = self;
    explosion.numParticlesToEmit = explosionDuration * explosion.particleBirthRate;
    CFTimeInterval totalTime     = explosionDuration + explosion.particleLifetime+explosion.particleLifetimeRange/2;
    [explosion runAction:[SKAction sequence:@[explosionSound, [SKAction waitForDuration:totalTime], [SKAction removeFromParent]]]];
    return explosion;
}

-(void)explodeAtPoint:(CGPoint)point {
    SKEmitterNode *explosion = [self newExplosionNode:0.1f];
    explosion.position       = point;
    [self addChild:explosion];
}

-(void)goToMenu {
    SKScene *scene = [[GameOverScene alloc] initWithSize:self.size];
    SKTransition *transition = [SKTransition flipHorizontalWithDuration:0.5];
    [self.view presentScene:scene transition:transition];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInNode:self];
    SKNode *node = [self nodeAtPoint:[[touches anyObject] locationInNode:self]];
    
    if ([node.name isEqualToString:@"Control"]) {
        _draggedNode = node;
    }

    if ([node.name isEqualToString:@"BackButton"]) {
        SKAction *buttonClick = [SKAction playSoundFileNamed:@"pushbtn.wav" waitForCompletion:NO];
        [self runAction:buttonClick];
        
        [self goToMenu];
    }
    
    if (isGameOver) {
        return;
    }
    
    [self fireMissile:location];
}

-(void)fireMissile:(CGPoint) location{
    CGPoint position;
    CGVector vector;
    if (turn == A) {
        position = CGPointMake(boxA.position.x, boxA.position.y +25);
        vector = CGVectorMake(location.x/self.frame.size.width * 10, location.y/self.frame.size.height * 10);
        turn = B;
    } else {
        position = CGPointMake(boxB.position.x, boxB.position.y +25);
        vector = CGVectorMake(-location.x/self.frame.size.width * 10, location.y/self.frame.size.height * 10);
        turn = A;
    }

    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(10, 10)];
    bullet.name = @"Bullet";
    bullet.position = position;
    [bullet addChild:[self newMissileNode] ];
    [self addChild:bullet];
    
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
    bullet.physicsBody.categoryBitMask = bulletCategory;
    bullet.physicsBody.contactTestBitMask = bottomCategory | blockCategory | boxCategory;
    [bullet runAction:fireSound];
    [bullet.physicsBody applyImpulse:vector];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    healthLabelA.text = [NSString stringWithFormat:@"红: %d", healthA];
    healthLabelB.text = [NSString stringWithFormat:@"绿: %d", healthB];
    
    if (isGameOver) {
        if (healthA == 0) {
            topCenterLabel.text = [NSString stringWithFormat:@"绿方赢了!"];
        } else {
            topCenterLabel.text = [NSString stringWithFormat:@"红方赢了!"];
        }
    } else {
        if (turn == A) {
            topCenterLabel.text = [NSString stringWithFormat:@"等待红方发射"];
        } else {
            topCenterLabel.text = [NSString stringWithFormat:@"等待绿方发射"];
        }
    }
}

-(void)applyConstraints {
    [self applyPlayerConstraints:boxA];
    [self applyPlayerConstraints:boxB];
}

-(void)applyPlayerConstraints:(SKSpriteNode *) player {
    if (player.position.x < 0) {
        player.position = CGPointMake(0, player.position.y);
    }
    if (player.position.x > self.size.width) {
        player.position = CGPointMake(self.size.width, player.position.y);
    }
}

-(void)didSimulatePhysics {
    [self applyConstraints];
}

@end