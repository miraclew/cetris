//
//  MyScene.m
//  Cetriso.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "MyScene.h"

#define NA_ENEMY_LABEL   @"enemy"
#define NA_MISSILE_LABEL @"missile"
#define NA_TARGET_KEY    @"target"

static const uint32_t boxCategory = 0x1 << 0;
static const uint32_t bottomCategory = 0x1 << 1;
static const uint32_t blockCategory = 0x1 << 2;
static const uint32_t bulletCategory = 0x1 << 3;

@implementation MyScene {
    SKSpriteNode *boxA;
    SKSpriteNode *boxB;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        
        CGRect bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        
        boxA = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(30, 30)];
        boxA.position = CGPointMake(15, 100);
        [self addChild:boxA];
        
        // setup physics
        boxA.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 30)];
        boxA.physicsBody.categoryBitMask = boxCategory;
        boxA.userData = [NSMutableDictionary dictionary];
        boxA.userData[@"Box"] = @"A";
        
        boxB = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(30, 30)];
        boxB.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
        boxB.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 30)];
        boxB.physicsBody.categoryBitMask = boxCategory;
        boxB.userData = [NSMutableDictionary dictionary];
        boxB.userData[@"Box"] = @"B";
        [self addChild:boxB];
        
        self.physicsWorld.contactDelegate = self;
    }
    return self;
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
    
    if ((secondBody.categoryBitMask & bulletCategory) != 0)
    {
        if ((firstBody.categoryBitMask & boxCategory) != 0 && [firstBody.node.userData[@"Box"] isEqualToString:@"B"]) {
            NSLog(@"attack %@", firstBody.node.userData[@"Box"]);
        }
        [self explodeAtPoint:contact.contactPoint];

//        SKAction *wait = [SKAction waitForDuration: 1];
//        SKAction *removeNode = [SKAction removeFromParent];
//        SKAction *sequence = [SKAction sequence:@[wait, removeNode]];
//        
//        [secondBody.node runAction:sequence];
    }
    
}

-(SKNode *)newMissileNode {
    SKEmitterNode *missile = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"missile" ofType:@"sks"]];
    missile.targetNode     = self;
    missile.name           = NA_MISSILE_LABEL;
    missile.physicsBody    = [SKPhysicsBody bodyWithCircleOfRadius:1.0f];
    
    // Setup physics interaction
    missile.physicsBody.categoryBitMask    = bulletCategory;
    missile.physicsBody.collisionBitMask   = 0;
    missile.physicsBody.contactTestBitMask = bottomCategory | blockCategory | boxCategory;;
    
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
//        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(10, 10)];
//        bullet.position = CGPointMake(boxA.position.x + 20, boxA.position.y +20);
//        [self addChild:bullet];
//        
//        bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
//        bullet.physicsBody.categoryBitMask = bulletCategory;
//        bullet.physicsBody.contactTestBitMask = bottomCategory | blockCategory | boxCategory;
//        CGVector vector = CGVectorMake(location.x/self.frame.size.width * 10, location.y/self.frame.size.height * 10);
//        [bullet.physicsBody applyImpulse:vector];
        SKNode *missile = [self newMissileNode];
        missile.position = CGPointMake(boxA.position.x + 20, boxA.position.y +20);
        CGVector vector = CGVectorMake(location.x/self.frame.size.width * 10, location.y/self.frame.size.height * 10);
        [missile.physicsBody applyImpulse:vector];
        [self addChild:missile];
    }


}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
