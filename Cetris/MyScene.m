//
//  MyScene.m
//  Cetriso.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "MyScene.h"

static const uint32_t boxCategory = 0x1 << 0;
static const uint32_t bottomCategory = 0x1 << 1;
static const uint32_t blockCategory = 0x1 << 2;

@implementation MyScene {
    SKSpriteNode *box;
    SKSpriteNode *boxB;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        
        CGRect bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        
        box = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(30, 30)];
        box.position = CGPointMake(15, 100);
        [self addChild:box];
        
        // setup physics
        box.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 30)];
        
        boxB = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(30, 30)];
        boxB.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
        boxB.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 30)];
        [self addChild:boxB];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
//
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(10, 100)];
//        sprite.position = CGPointMake(location.x, 1);
//        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
//        
//        SKAction *action = [SKAction moveByX:-10 y:0 duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//        
//
        //    [box.physicsBody applyForce:CGVectorMake(1, 1)];
        
        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(10, 10)];
        bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
        bullet.position = CGPointMake(box.position.x + 15, box.position.y +15);
        [self addChild:bullet];
        
        CGVector vector = CGVectorMake(location.x/self.frame.size.width * 10, location.y/self.frame.size.height * 10);
        [bullet.physicsBody applyImpulse:vector];
        
//        CGVector vector = CGVectorMake(location.x - box.position.x > 0 ? 5 : -5, 20);
//        [box.physicsBody applyImpulse:vector];
        
        
    }


}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
